SERVER_IP := $(shell terraform output -raw server-ip)
SERVER_USER := $(shell terraform output -raw server-user)

.PHONY: backup
backup:
	rsync --recursive --verbose $(SERVER_USER)@$(SERVER_IP):backups .

.PHONY: install
install: .venv/bin/ansible-playbook
	.venv/bin/ansible-playbook --inventory inventory valheim-install.yml

.PHONY: reboot
reboot: backup
	ssh $(SERVER_USER)@$(SERVER_IP) 'sudo systemctl stop valheim'
	ssh $(SERVER_USER)@$(SERVER_IP) 'sudo systemctl reboot'

.PHONY: show-connections
show-connections:
	ssh $(SERVER_USER)@$(SERVER_IP) 'journalctl --unit valheim --grep Connections --lines 1 --output cat --reverse'

.PHONY: show-status
show-status:
	ssh $(SERVER_USER)@$(SERVER_IP) 'systemctl status valheim'

.PHONY: terraform
terraform:
	terraform apply

.PHONY: update
update: .venv/bin/ansible-playbook
	.venv/bin/ansible-playbook --inventory inventory valheim-update.yml

.venv:
	python -m venv .venv
	.venv/bin/pip install --upgrade pip setuptools wheel

.venv/bin/ansible-playbook: .venv
	.venv/bin/pip install ansible

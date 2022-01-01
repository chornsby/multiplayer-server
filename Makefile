SERVER_IP := $(shell terraform output -raw server-ip)
SERVER_USER := $(shell terraform output -raw server-user)

.PHONY: backup
backup:
	rsync --recursive --verbose $(SERVER_USER)@$(SERVER_IP):backups .

.PHONY: install
install: .venv/bin/ansible-playbook
	.venv/bin/ansible-playbook --inventory inventory valheim-install.yml

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

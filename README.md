# Game Server Deployment

A Terraform project for deploying a game like 
[Minecraft: Java Edition server][0] to [Oracle Cloud][1] based on the 
instructions given in an [Oracle blog post][2].

## Getting Started

Download [Terraform](https://www.terraform.io/) and clone this repository.

Create an Oracle Cloud account and generate an API Key for use with the
Terraform provider. You will need to make a `terraform.tfvars` file in the
project with the values from the API Key.

## Usage

Run `terraform init` and `make terraform`. It will tell you if you forgot some
variables otherwise it will create the required network resources and provision
a VM.

Then run `make install` to install the currently configured multiplayer game:
this is currently Valheim. The game will start automatically after installation
as a systemd unit which will be restarted on failure. Additionally, backups are
taken every hour and can be fetched using `make backup`.

To update the game run `make update` which will stop the running game service,
update the software, and then start the game again.

## Acknowledgements

This project was hacked together using bits and pieces from the following blog
posts.

- https://blogs.oracle.com/developers/post/how-to-set-up-and-run-a-really-powerful-free-minecraft-server-in-the-cloud#open-firewall-and-security-list-ports-to-allow-public-access
- https://minecraft.fandom.com/wiki/Tutorials/Setting_up_a_server
- https://teilgedanken.de/Blog/post/setting-up-a-minecraft-server-using-systemd/
- https://valheim.fandom.com/wiki/Hosting_Servers
- https://pimylifeup.com/raspberry-pi-valheim-server/
- https://fedoramagazine.org/systemd-timers-for-scheduling-tasks/
- https://www.reddit.com/r/valheim/comments/lqfx2o/dedicated_server_on_linux_as_service/

[0]: https://www.minecraft.net/en-us/download/server
[1]: https://www.oracle.com/cloud/
[2]:
  https://blogs.oracle.com/developers/post/how-to-set-up-and-run-a-really-powerful-free-minecraft-server-in-the-cloud#open-firewall-and-security-list-ports-to-allow-public-access

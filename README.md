![unlabored](https://github.com/rotkonetworks/unlabored/assets/15621959/8c057833-e22b-4dfd-a92b-20adc9b929ec)
# unlabored
effortless proxmox-ansible infra for blockchains

## Installation:
There is installation script at https://unlabored.rotko.net
```bash
curl -s https://api.github.com/gists/<TODO> | jq -r '.files | first(.[]).content' > install-unlabored && chmod +x install-unlabored && ./install-unlabored
```
This script requires two arguments: the remote host account name and the path to the SSH private key.
It will clone the GitHub repository, set up dependencies in a virtual environment, create SSH shortcuts,
and optionally set up the SSH Agent service for forwarding.

## Example
For example, to install the development environment with a remote host account named "tommi" and
an SSH private key located at "~/.ssh/id_rsa", use the following command:
```bash
./install-unlabored tommi ~/.ssh/id_rsa
```

## Shortcut and Virtual Environment
To set up a shortcut and virtual environment, add the following alias to your bashrc or zshrc:
```bash
alias unlabored='cd ~/src/unlabored && source ../venv/bin/activate'
```
This alias will allow you to quickly navigate to the correct directory and activate the virtual environment.

## Updating SSH configs
```bash
invoke sshconfig
```
This will update your SSH configs to include any changes that have been made to the repository.

## Documentation

1. [Hardware Preparation](docs/hardware-setup.md) - A guide on how to prepare the hardware for the setup process.
2. [Proxmox Maintenance](docs/proxmox-setup.md) - Instructions for managing and maintaining Proxmox servers and environments.
3. [Networking](docs/networking.md) - Thinking networking and firewall solutions
4. [Playbooks](docs/playbooks.md) - An overview of the Ansible playbooks used for various tasks and how to execute them.
5. [Data Sync](docs/data-sync.md) - A tutorial on synchronizing data between servers using `rsync` and `screen` commands.
6. [Hetzner setup - extra](docs/hetzner-setup.md) - Instructions for setting up hetzner robot servers.

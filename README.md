![unlabored](https://github.com/rotkonetworks/unlabored/assets/15621959/8c057833-e22b-4dfd-a92b-20adc9b929ec)
# unlabored
effortless proxmox-ansible infra for blockchains

## Installation:
```bash
sudo apt install python3 python3-venv python3-pip
git clone repo && cd repo
./unlabored <command> -a <account_name> -k <ssh_key_path>
```
The `<command>` can be:

- ```install```: It sets up a Python virtual environment, installs necessary Python packages from `requirements.txt` and `requirements-dev.txt`, Ansible roles from `requirements.yaml`, and a tool from a specific GitHub repository.
- ```setup```: It validates the existence of the SSH key, creates a directory for SSH configurations, exports necessary environment variables and invokes a command to update the SSH configuration.
- ```ssh-agent```: It exports a variable for the SSH agent and sets up the SSH agent service.
- ```all```: It performs all the above steps sequentially (install, setup, ssh-agent).

Please replace `<account_name>` and `<ssh_key_path>` with your username and the path to your SSH private key, respectively.

For instance:
```bash
./unlabored install -a root -k ~/.ssh/ansible_ssh_key
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

## Linting
```bash
inv check
inv ansiblelater
inv ansiblelint
```

## Documentation

1. [Hardware Preparation](docs/hardware-setup.md) - A guide on how to prepare the hardware for the setup process.
2. [Proxmox Maintenance](docs/proxmox-setup.md) - Instructions for managing and maintaining Proxmox servers and environments.
3. [Networking](docs/networking.md) - Thinking networking and firewall solutions
4. [Playbooks](docs/playbooks.md) - An overview of the Ansible playbooks used for various tasks and how to execute them.
5. [Data Sync](docs/data-sync.md) - A tutorial on synchronizing data between servers using `rsync` and `screen` commands.
6. [Hetzner setup - extra](docs/hetzner-setup.md) - Instructions for setting up hetzner robot servers.

![unlabored logo](assets/unlabored-logo.webp)
# unlabored
Effortless Proxmox-Ansible deployment infrastructure for blockchain application.

## Overview

unlabored is designed to streamline the deployment and maintenance of
blockchain infrastructures on Proxmox using Ansible. The project comes with an
array of roles, catering to various blockchain applications and Proxmox
configurations.

## Installation:

1. **Fork the Repository**:
   - First, visit the original repository on GitHub at
   `https://github.com/rotkonetworks/unlabored`.
   - In the top-right corner, you'll see a button labeled "Fork". Click on this
   to create your own copy of the repository.

2. **Install Necessary Dependencies**: Open a terminal and run the following
commands to install necessary software: ```bash sudo apt update sudo apt
install python3 python3-venv python3-pip ```

3. **Clone Your Forked Repository**: Replace `<your_github_username>` with your
actual GitHub username. ```bash git clone
https://github.com/<your_github_username>/unlabored && cd unlabored ```

4. **Install the Unlabored Application**: Run the installation script. Make
sure to replace `<command>`, `<account_name>`, and `<ssh_key_path>` with the
appropriate values.
   ```bash
   ./install_unlabored <command> -a <account_name> -k <ssh_key_path>
   ```

The `<command>` can be:

- ```install```: It sets up a Python virtual environment, installs necessary
  Python packages from `requirements.txt` and `requirements-dev.txt`, Ansible
  roles from `requirements.yaml`, and a tool from a specific GitHub repository.
- ```setup-ssh```: It validates the existence of the SSH key, creates a
  directory for SSH configurations, exports necessary environment variables and
  invokes a command to update the SSH configuration.
- ```ssh-agent```: It exports a variable for the SSH agent and sets up the SSH
  agent service.
- ```all```: It performs all the above steps sequentially (install, setup,
  ssh-agent).

Please replace `<account_name>` and `<ssh_key_path>` with your username and the
path to your SSH private key, respectively.

For instance:
```bash
./install_unlabored install -a root -k ~/.ssh/ansible_ssh_key
```

## Shortcut and Virtual Environment

To set up a shortcut and virtual environment, add the following alias to your bashrc or zshrc:
```bash
alias unlabored='cd /path/to/unlabored && source ../.venv/bin/activate'
```
This alias will allow you to quickly navigate to the correct directory and activate the virtual environment.

## Updating SSH configs
```bash
inv sshconfig
```
This will invoke your SSH configs to include any changes that have been made to the repository.

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
6. [Rotko Networks Infrastructure](https://rotko.net/docs) - Overall docs for infrastructure this script is design to run for.

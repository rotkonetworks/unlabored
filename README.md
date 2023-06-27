![unlabored](https://github.com/rotkonetworks/unlabored/assets/15621959/8c057833-e22b-4dfd-a92b-20adc9b929ec)
# unlabored
effortless proxmox-ansible infra for blockchains

## Installation:
There is installation script at https://unlabored.rotko.net
```bash
curl -s https://api.github.com/gists/<TODO> | jq -r '.files | first(.[]).content' > install-unlabored.sh && chmod +x install-unlabored.sh && ./install-unlabored.sh
```
This script requires two arguments: the remote host account name and the path to the SSH private key.
It will clone the GitHub repository, set up dependencies in a virtual environment, create SSH shortcuts,
and optionally set up the SSH Agent service for forwarding.

### Example
For example, to install the development environment with a remote host account named "tommi" and
an SSH private key located at "~/.ssh/id_rsa", use the following command:
```bash
./install-unlabored.sh tommi ~/.ssh/id_rsa
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

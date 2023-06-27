pip install -r ./requirements.txt
pip install -r ./requirements-dev.txt
ansible-galaxy install -r requirements.yaml
. ./venv/bin/activate

pip install git+https://github.com/hitchhooker/AISTool
export SSH_CONFIG_TARGET=~/.ssh/unlabore/config
export SSH_CONFIG_USER="root"
export SSH_CONFIG_IDENTITY=~/.ssh/unlabore/ansible_ssh_key
if ! grep -qxF "Include ~/.ssh/unlabore/config" ~/.ssh/config; then echo "Include ~/.ssh/unlabore/config" >>~/.ssh/config; fi
inv sshconfig

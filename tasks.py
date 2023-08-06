# flake8: noqa
from invoke import task
from pathlib import Path
import os

assert Path.cwd() == Path(__file__).parent

SSH_CONFIG_TARGET = Path(os.environ.get(
    "SSH_CONFIG_TARGET", "~/.ssh/unlabored/config")).expanduser()
SSH_CONFIG_USER = os.environ.get("SSH_CONFIG_USER", "root")
SSH_CONFIG_IDENTITY = Path(os.environ.get(
    "SSH_CONFIG_IDENTITY", "~/.ssh/unlabored/ansible_ssh_key")).expanduser()


@task
def playbook(ctx, arg="--syntax-check"):
    for playbook in Path("playbooks").glob("*.yaml"):
        ctx.run(f"ansible-playbook -i ./inventory {arg} {playbook}")


@task
def sshconfig(ctx):
    if SSH_CONFIG_IDENTITY.exists():
        ctx.run(
            f"AISTool -o {SSH_CONFIG_TARGET} --backup -u {SSH_CONFIG_USER} -i {SSH_CONFIG_IDENTITY} --forwardagent ./inventory")
    else:
        print(f"File not found: {SSH_CONFIG_IDENTITY}")


@task
def checkplaybooks(ctx):
    playbook(ctx, "--check")


@task
def syntaxcheck(ctx):
    playbook(ctx, "--syntax-check")


@task
def ansiblelint(ctx):
    ctx.run("ansible-lint -c .ansible-lint --offline")


@task
def ansiblelater(ctx):
    ctx.run("ansible-later --rules-dir later_plugins")


@task
def black(ctx):
    ctx.run("black --check --diff --verbose .")


@task
def flake8(ctx):
    ctx.run("flake8 . --select=E9,F63,F7,F82 --show-source --statistics")
    ctx.run("flake8 . --exit-zero --statistics")


@task
def unpin(ctx, target):
    ctx.run(
        f"ssh {target} 'sudo sed -i \'s/pinned=True/pinned=False/g\' /etc/ansible/facts.d/noderole.fact'")
    result = ctx.run(
        f"ssh {target} 'grep \"pinned=False\" /etc/ansible/facts.d/noderole.fact'", warn=True)
    if result.ok:
        print(f"Unpin operation completed on {target}")
    else:
        print(f"Failed to unpin on {target}")


@task
def pin(ctx, target):
    ctx.run(
        f"ssh {target} 'sudo sed -i \'s/pinned=False/pinned=True/g\' /etc/ansible/facts.d/noderole.fact'")
    result = ctx.run(
        f"ssh {target} 'grep \"pinned=True\" /etc/ansible/facts.d/noderole.fact'", warn=True)
    if result.ok:
        print(f"Pin operation completed on {target}")
    else:
        print(f"Failed to pin on {target}")


@task
def yamllint(ctx):
    # paths = [".github/workflows", "playbooks"]:
    paths = ["playbooks"]
    for folder in paths:
        ctx.run(f"yamllint -c ./.yamllint {folder}")


@task(post=[syntaxcheck, ansiblelater, black, flake8, yamllint])
def check(ctx):
    print("Running all checks")

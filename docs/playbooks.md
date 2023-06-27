# Executing playbooks

To execute a playbook, use the following command format:

```bash
ansible-playbook playbooks/{{playbook_name.yml}} -i {{inventory}} <<--check(dryrun)>> <<--limit {hostname}>>
```

Replace the placeholders with appropriate values:
- `{{playbook_name.yml}}`: The name of the playbook you want to run (e.g., `basic_installation.yml`).
- `{{inventory}}`: The inventory file you want to use (e.g., `inventory/hosts.ini`).
- `<<--check(dryrun)>>`: Optional, use `--check` flag to perform a dry run without making actual changes.
- `<<--limit {hostname}>>`: Optional, use `--limit` flag followed by the hostname to apply the playbook to a specific host.

For example, to execute the `basic_installation.yml` playbook:

```bash
ansible-playbook playbooks/basic_installation.yml -i inventory/hosts.ini
```

## Shortcut for running only client updates inside the server

To update or install nodes within a server, you can use the `network.yaml` playbook. Run the command:

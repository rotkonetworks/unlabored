def group_by_domain(hostvars):
    domain_groups = {}

    for host, vars in hostvars.items():
        domain = vars.get("default_public_dns_lb")
        if domain:
            domain_groups.setdefault(domain, []).append(host)

    return domain_groups


def generate_stream_configs(hostvars, domain_groups):
    stream_configs = []

    for domain, hosts in domain_groups.items():
        backend_list = []
        for host in hosts:
            host_data = hostvars.get(host, {})

            # Combining the IP and port.
            backend = f"{host_data['container_ip']}:{host_data['default_secure_rpc_port']}"
            backend_list.append(backend)

        stream_configs.append({"domain": domain, "backends": backend_list})

    return stream_configs


class FilterModule(object):
    """Custom filters for working with data"""

    def filters(self):
        return {"group_by_domain": group_by_domain, "generate_stream_configs": generate_stream_configs}

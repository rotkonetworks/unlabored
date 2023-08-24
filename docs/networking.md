# Networking

Currently we only support port forwarding at host level, but plan is to broaden
port forwarding to be done optionally at router(Mikrotik)

```group_vars/all/all.yaml
default_need_routeros_port_forwarding: False
default_need_iptables_port_forwarding: False
```

If you are running routeros or your own router we recommend modifying our
routeros rolebook compatible with your router. In case you are running server
in a hosted network without managing the router, set
default_need_iptables_port_forwarding to be True and script will manage
iptables correclty for you and your containers.

```group_vars/all/all.yaml
default_hetzner_firewall: False
```

We also have optional strict firewall settings for Hetzner and other policing
ISPs to block all traffic into internal IP range from containers and the host
device.

### Networking Documentation

## Overview

Our networking module primarily facilitates port forwarding at the host level.
We are in the process of extending this feature to allow for optional port
forwarding at the router level, specifically integrating with MikroTik routers.

## Configuration Details

### Port Forwarding

Refer to the configuration snippet below:

```yaml
# group_vars/all/all.yaml
default_need_routeros_port_forwarding: False
default_need_iptables_port_forwarding: False
```

**RouterOS Configuration**:
If your infrastructure utilizes RouterOS or a similar custom router setup, it
is advisable to tailor our routeros rolebook to align with your specific router
configurations.

**Hosted Network Configuration**:
For scenarios where your server resides in a hosted network and you do not have
control over the router, you should set `default_need_iptables_port_forwarding`
to `True`. This ensures that our script will appropriately manage iptables for
your server and associated containers.

### Firewall Configuration

```yaml
# group_vars/all/all.yaml
default_hetzner_firewall: False
```

We provide optional stringent firewall settings tailored for Hetzner and
comparable ISPs with rigorous policing mechanisms. This setting ensures that
all traffic originating from containers and the host device directed towards
the internal IP range is blocked, bolstering security.

## Recommendations

1. **RouterOS Users**: Ensure you thoroughly assess the compatibility and make
   necessary adjustments to our routeros rolebook to suit your infrastructure.
2. **Hosted Network Users**: Explicitly set the
   `default_need_iptables_port_forwarding` flag to maintain seamless
operations.
3. **Security Measures**: For those utilizing Hetzner or similar ISPs, consider
   leveraging our specialized firewall settings to enhance your network's
security posture.

## Conclusion

Ensuring efficient and secure networking is crucial. Tailor the configurations
provided to best fit your operational environment, and always remain abreast of
updates and best practices. Should you have further queries or require
assistance, please refer to our comprehensive documentation or reach out to our
support team.

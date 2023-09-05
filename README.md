# Futur-Tech Niflheim

**Niflheim**, in Norse mythology, is one of the nine realms and represents a primordial realm of ice, cold, mist, and shadows. Symbolically, just as Niflheim encapsulates what's chilling and distant in the Norse cosmology, the Futur-Tech Niflheim project endeavors to isolate and manage potential threats in cyberspace, keeping them distant and quarantined from your network's warmth and safety.

## Nidhogg IP Blacklist

In Norse mythology, Nidhogg is a dragon that gnaws at the roots of Yggdrasil, the World Tree. Much like how Nidhogg threatens the cosmic order, malicious IP addresses can compromise network and system security. This script aims to mitigate such threats by providing a means to manage a blacklist of suspicious or malicious IPs.

Execute the management script `blacklist_ip.sh` using the following syntax:

```bash
./blacklist_ip.sh [add|remove|sort|check_list] [IP_ADDRESS]
```

Options:
- `add IP_ADDRESS`: Adds the specified IP address to the blacklist.
- `remove IP_ADDRESS`: Removes the specified IP address from the blacklist.
- `sort`: Sorts and deduplicates the blacklist.
- `check_list`: Validates all IP addresses in the blacklist.

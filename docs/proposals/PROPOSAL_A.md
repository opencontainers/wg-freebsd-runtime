# Proposal A - FreeBSD Jails

This proposal recommends changes to describe the requirements for mapping an OCI
runtime container to a corresponding FreeBSD jail.

## Modifications

This suggests adding an object to the [FreeBSD-specific section](https://github.com/opencontainers/runtime-spec/blob/main/config.md#platform-specific-configuration) of the [container configuration](https://github.com/opencontainers/runtime-spec/blob/main/config.md) to describe the required parameters for the jail.

## Jail Configuration

Jail parameters and devfs rules for the container's jail

**`devices`** _(array of object, OPTIONAL)_ - devfs rules for this container.

Each element is an object with the following fields:

- **`path`** _(string, REQUIRED)_ - the device path relative to "/dev"
- **`mode`** _(string, OPTIONAL)_ - the device permissions
- **`unhide`** _(bool, OPTIONAL)_ - if set, expose the path in the container

**`jail`** _(object, OPTIONAL)_ jail parameters for this container.

The following parameters can be specified for for the container jail:

- **`parent`** _(string, OPTIONAL)_ - parent jail.
    The value is the name of a jail which should be this container's parent (defaults to none).
- **`host`** _(string, OPTIONAL)_ - allow overriding hostname, domainname, hostuuid and hostid.
    The value can be "new" which allows these values to be overridding in the container or "inherit" to use the host values. If set to "new", the values for hostname and domainname are taken from the base config, if present.
- **`ip4`** _(string, OPTIONAL)_ - control the availability of IPv4 addresses.
    The value can be "new" which allows the addresses listed in **`ip4Addr`** to be used, "inherit" which allows all addresses in the jail's vnet or "disable" to stop use of IPv4 entirely.
- **`ip4Addr`** _(array of string, OPTIONAL)_ - list of IPv4 addresses usable by the jail
- **`ip6`** _(string, OPTIONAL)_ - control the availability of IPv6 addresses.
    The value can be "new" which allows the addresses listed in **`ip6Addr`** to be used, "inherit" which allows all addresses in the jail's vnet or "disable" to stop use of IPv6 entirely.
- **`ip6Addr`** _(array of string, OPTIONAL)_ - list of IPv6 addresses usable by the jail
- **`vnet`** _(string, OPTIONAL)_ - control the vnet used for this jail.
    The value can be "new" which causes a new vnet to be created for the jail or "inherit" which shares the vnet for the parent (or host if there is no parent).
- **`enforceStatfs`** _(integer, OPTIONAL)_ - control visibility of mounts in the jail.
    A value of 0 allows visibility of all host mounts, 1 allows visibility of mounts nested under the container's root and 2 only allows the container root to be visible.
- **`allow`** _(object, OPTIONAL)_ - Some restrictions of the jail environment may be set on a per-jail basis.  With the exception of **`setHostname`** and **`reservedPorts`**, these boolean parameters are off by default.
  - **`setHostname`** _(bool, OPTIONAL)_ - Allow the jail's hostname to be changed.
  - **`rawSockets`** _(bool, OPTIONAL)_ - Allow the jail to use raw sockets to support network utilities such as ping and traceroute.
  - **`chflags`** _(bool, OPTIONAL)_ - Allow the system file flags to be changed.
  - **`mount`** _(array of strings, OPTIONAL)_ - Allow the listed filesystem types to be mounted and unmounted in the jail.
  - **`quotas`** _(bool, OPTIONAL)_ - Allow the filesystem quotas to be changed in the jail.
  - **`readMsgbuf`** _(bool, OPTIONAL)_ - Jailed users may read the kernel message buffer.
  - **`socketAf`** _(bool, OPTIONAL)_ - Allow socket types other than IPv4, IPv6 and unix.
  - **`mlock`** _(bool, OPTIONAL)_ - Allow locking and unlocking of physical pages.
  - **`nfsd`** _(bool, OPTIONAL)_ - Allow the jail to act as an NFS server.
  - **`reservedPorts`** _(bool, OPTIONAL)_ - Allow the jail to bind to ports lower than 1024.
  - **`suser`** _(bool, OPTIONAL)_ - The value of the jail's security.bsd.suser_enabled sysctl. The super-user will be disabled automatically if its parent system has it disabled.  The super-user is enabled by default.
  
### Mapping from jail(8) config file

This table shows how to map settings from a typical jail(8) config file to the proposed JSON format.

| Jail parameter | JSON equivalent      |
| -------------- | -------------------- |
| jid            | -                    |
| name           | see below            |
| path           | root.path            |
| ip4.addr       | freebsd.jail.ip4Addr |
| ip4.saddrsel   | -                    |
| ip4            | freebsd.jail.ip4     |
| ip6.addr       | freebsd.jail.ip6Addr |
| ip6.saddrsel   | -                    |
| ip6            | freebsd.jail.ip6     |
| vnet           | freebsd.jail.vent    |
| host.hostname  | hostname             |
| host           | freebsd.jail.host    |
| sysvmsg        | freebsd.jail.sysvmsg |
| sysvsem        | freebsd.jail.sysvsem |
| sysvshm        | freebsd.jail.sysvshm |
| securelevel    | -                    |
| devfs_ruleset  | see below            |
| children.max   | see below            |
| enforce_statfs | freebsd.jail.enforceStatfs |
| persist        | -                    |
| parent         | freebsd.jail.parent  |
| osrelease      | -                    |
| osreldate      | -                    |
| allow.set_hostname | freebsd.jail.allow.setHostname |
| allow.sysvipc  | freebsd.jail.allow.sysvipc |
| allow.raw_sockers  | freebsd.jail.allow.rawSockets |
| allow.chflags  | freebsd.jail.allow.chflags |
| allow.mount    | freebsd.jail.allow.mount |
| allow.quotas    | freebsd.jail.allow.quotas |
| allow.read_msgbuf | freebsd.jail.allow.readMsgbuf |
| allow.socket_af | freebsd.jail.allow.socketAf |
| allow.mlock    | freebsd.jail.allow.mlock |
| allow.nfsd     | freebsd.jail.allow.nfsd |
| allow.reserved_ports | freebsd.jail.allow.reservedPorts |
| allow.unprivileged_proc_debug | - |
| allow.suser    | freebsd.jail.allow.suser |
| allow.mount.*  | see below            |
| securelevel    | -                    |

The jail name is set to the create command's `container-id` argument.

The `devfs_ruleset` parameter is only required for jails which create new `devfs` mounts - typically OCI runtimes will mount `devfs` on the host.

The `children.max` parameter is managed by the OCI runtime e.g when a new container is added to a pod.

The `allow.mount.*` parameter set is extensible - this proposal suggests representing allowed mount types as an array. As with `devfs`, typically the OCI runtime will manage mounts for the container by performing mount operations on the host.

### Example

An example config for a container with its own host and network namespaces. This
container is allowed to see its own mounts and can use raw
sockets. In addition to the minimal set of devices in the container devfs,
`/dev/pf` is exposed, allowing the container to manage firewall rules etc. in its
network namespace.

```json
{
	"ociVersion": "1.1.0",
	"hostname": "mycontainer",
	"process": {
		"cwd": "/",
		"env": ["PATH=/bin:/sbin:/usr/bin:/usr/sbin"],
		"args": ["freebsd-version"]
	}
	"mounts": [
		{
			"destination": "/dev",
			"options": ["ruleset=4"],
			"source": "devfs",
			"type": "devfs"
		},
		{
			"destination": "/dev/fd",
			"source": "fdesc",
			"type": "fdescfs"
		}
	],
	"root": {
		"path": "/path/to/container/root"
	},
	"freebsd": {
		"devices": [
			{
				"path": "pf",
				"mode": "0700",
				"unhide": true
			}
		],
		"jail": {
			"host": "new",
			"vnet": "new",
			"enforceStatfs": 1,
			"allow": {
				"rawSockets": true,
				"chflags": true
			}
		}
	}
}
```

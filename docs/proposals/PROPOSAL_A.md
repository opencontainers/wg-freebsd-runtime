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
- **`mode`** _(integer, OPTIONAL)_ - device permissions as an integer which is interpreted as in chmod(1).

**`jail`** _(object, OPTIONAL)_ jail parameters for this container.

The following parameters can be specified for for the container jail:

- **`parent`** _(string, OPTIONAL)_ - parent jail.
    The value is the name of a jail which should be this container's parent (defaults to none). This can be used to share namespaces such as vnet with another container.
- **`host`** _(string, OPTIONAL)_ - allow overriding hostname, domainname, hostuuid and hostid.
    The value can be "new" which allows these values to be overridden in the container or "inherit" to use the host values (or parent container values). If set to "new", the values for hostname and domainname are taken from the base config, if present.
- **`ip4`** _(string, OPTIONAL)_ - control the availability of IPv4 addresses.
    This is typically left unset if the container has a vnet, set to "inherit" to allow access to host (or parent container) addresses or set to "disable" to stop use of IPv4 entirely.
- **`ip6`** _(string, OPTIONAL)_ - control the availability of IPv6 addresses.
    This is typically left unset if the container has a vnet, set to "inherit" to allow access to host (or parent container) addresses or set to "disable" to stop use of IPv6 entirely.
- **`vnet`** _(string, OPTIONAL)_ - control the vnet used for this container.
    The value can be "new" which causes a new vnet to be created for the container or "inherit" which shares the vnet for the parent container (or host if there is no parent).
- **`sysvmsg`** _(string, OPTIONAL)_ - allow access to SYSV IPC message primitives.
    If set to "inherit", all IPC objects on the system are visible to this container, whether they were created by the container itself, the base system, or other containers.  If set to "new", the container will have its own key namespace, and can only see the objects that it has created; the system (or parent container) has access to the container's objects, but not to its keys.  If set to "disable", the container cannot perform any sysvmsg-related system calls.
- **`sysvsem`** _(string, OPTIONAL)_ - allow access to SYSV IPC semaphore primitives, in the same manner as sysvmsg.
- **`sysvshm`** _(string, OPTIONAL)_ - allow access to SYSV IPC shared memory primitives, in the same manner as sysvmsg.
- **`enforceStatfs`** _(integer, OPTIONAL)_ - control visibility of mounts in the container.
    A value of 0 allows visibility of all host mounts, 1 allows visibility of mounts nested under the container's root and 2 only allows the container root to be visible. If unset, the default value is 2.
- **`allow`** _(object, OPTIONAL)_ - Some restrictions of the container environment may be set on a per-container basis.  With the exception of **`setHostname`** and **`reservedPorts`**, these boolean parameters are off by default.
  - **`setHostname`** _(bool, OPTIONAL)_ - Allow the container's hostname to be changed.
  - **`rawSockets`** _(bool, OPTIONAL)_ - Allow the container to use raw sockets to support network utilities such as ping and traceroute.
  - **`chflags`** _(bool, OPTIONAL)_ - Allow the system file flags to be changed.
  - **`mount`** _(array of strings, OPTIONAL)_ - Allow the listed filesystem types to be mounted and unmounted in the container.
  - **`quotas`** _(bool, OPTIONAL)_ - Allow the filesystem quotas to be changed in the container.
  - **`socketAf`** _(bool, OPTIONAL)_ - Allow socket types other than IPv4, IPv6 and unix.
  - **`reservedPorts`** _(bool, OPTIONAL)_ - Allow the jail to bind to ports lower than 1024.
  - **`suser`** _(bool, OPTIONAL)_ - The value of the jail's security.bsd.suser_enabled sysctl. The super-user will be disabled automatically if its parent system has it disabled.  The super-user is enabled by default.
  
### Mapping from jail(8) config file

This table shows how to map settings from a typical jail(8) config file to the proposed JSON format.

| Jail parameter | JSON equivalent      |
| -------------- | -------------------- |
| jid            | -                    |
| name           | see below            |
| path           | root.path            |
| ip4.addr       | -                    |
| ip4.saddrsel   | -                    |
| ip4            | freebsd.jail.ip4     |
| ip6.addr       | -                    |
| ip6.saddrsel   | -                    |
| ip6            | freebsd.jail.ip6     |
| vnet           | freebsd.jail.vnet    |
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
| allow.read_msgbuf | -                       |
| allow.socket_af | freebsd.jail.allow.socketAf |
| allow.mlock    | - |
| allow.nfsd     | - |
| allow.reserved_ports | freebsd.jail.allow.reservedPorts |
| allow.unprivileged_proc_debug | - |
| allow.suser    | freebsd.jail.allow.suser |
| allow.mount.*  | see below            |

The jail name is set to the create command's `container-id` argument.

Network addresses are typically managed by the host (e.g. using CNI or netavark) to we do not include a mapping for `ip4.addr` or `ip6.addr`.

The `devfs_ruleset` parameter is only required for jails which create new `devfs` mounts - typically OCI runtimes will mount `devfs` on the host. The value is a rule set number - these rule sets are defined on the host, typically via /etc/defaults/devfs.rules and /etc/default/devfs.rules or using the `devfs` command line utility.

The `children.max` parameter is managed by the OCI runtime e.g when a new container shares namespaces with an existing container.

The `allow.mount.*` parameter set is extensible - this proposal suggests representing allowed mount types as an array. As with `devfs`, typically the OCI runtime will manage mounts for the container by performing mount operations on the host.

Jail parameters not supported by this runtime extension are marked with "-". These parameters will have their default values - see the jail(8) man page for details.

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

This example shows a config for a container which is allowed to mount new tmpfs
instances:

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
		"jail": {
			"host": "new",
			"vnet": "new",
			"enforceStatfs": 1,
			"allow": {
				"rawSockets": true,
				"chflags": true,
				"mount": [
					"tmpfs"
				]
			}
		}
	}
}
```

# Proposal A - FreeBSD Jails

This proposal recommends changes to describe the requirements for mapping an OCI
runtime container to a corresponding FreeBSD jail.

## Modifications

This suggests adding an object to the [FreeBSD-specific section](config.md#platform-specific-configuration) of the [container configuration](config.md) to describe the required parameters for the jail.

## <a name="configFreeBSDJail" />Jail Configuration

Jail parameters to use for the container's jail.

**`jail`** *(object, OPTIONAL)* jail parameters for this container.

The following parameters can be specified for for the container jail:

* **`parent`** *(string, OPTIONAL)* - parent jail.
    The value is the name of a jail which should be this container's parent (defaults to none).
* **`host`** *(string, OPTIONAL)* - allow overriding hostname, domainname, hostuuid and hostid.
    The value can be "new" which allows these values to be overridding in the container or "inherit" to use the host values. If set to "new", the values for hostname and domainname are taken from the base config, if present.
* **`ip4`** *(string, OPTIONAL)* - control the availability of IPv4 addresses.
    The value can be "new" which allows the addresses listed in **`ip4Addr`** to be used, "inherit" which allows all addresses in the jail's vnet or "disable" to stop use of IPv4 entirely.
* **`ip4Addr`** *(array of string, OPTIONAL)* - list of IPv4 addresses usable by the jail
* **`ip6`** *(string, OPTIONAL)* - control the availability of IPv6 addresses.
    The value can be "new" which allows the addresses listed in **`ip6Addr`** to be used, "inherit" which allows all addresses in the jail's vnet or "disable" to stop use of IPv6 entirely.
* **`ip6Addr`** *(array of string, OPTIONAL)* - list of IPv6 addresses usable by the jail
* **`vnet`** *(string, OPTIONAL)* - control the vnet used for this jail.
    The value can be "new" which causes a new vnet to be created for the jail or "inherit" which shares the vnet for the parent (or host if there is no parent).
* **`enforceStatfs`** *(integer, OPTIONAL)* - control visibility of mounts in the jail.
    A value of 0 allows visibility of all host mounts, 1 allows visibility of mounts nested under the container's root and 2 only allows the container root to be visible.
* **`allow`** *(object, OPTIONAL)* - Some restrictions of the jail environment may be set on a per-jail basis.  With the exception of **`setHostname`** and **`reservedPorts`**, these boolean parameters are off by default.
  * **`setHostname`** *(bool, OPTIONAL)* - Allow the jail's hostname to be changed.
  * **`rawSockets`** *(bool, OPTIONAL)* - Allow the jail to use raw sockets to support network utilities such as ping and traceroute.
  * **`chflags`** *(bool, OPTIONAL)* - Allow the system file flags to be changed.
  * **`mount`** *(array of strings, OPTIONAL)* - Allow the listed filesystem types to be mounted and unmounted in the jail.
  * **`quotas`** *(bool, OPTIONAL)* - Allow the filesystem quotas to be changed in the jail.
  * **`readMsgbuf`** *(bool, OPTIONAL)* - Jailed users may read the kernel message buffer.
  * **`socketAf`** *(bool, OPTIONAL)* - Allow socket types other than IPv4, IPv6 and unix.
  * **`mlock`** *(bool, OPTIONAL)* - Allow locking and unlocking of physical pages.
  * **`nfsd`** *(bool, OPTIONAL)* - Allow the jail to act as an NFS server.
  * **`reservedPorts`** *(bool, OPTIONAL)* - Allow the jail to bind to ports lower than 1024.
  * **`suser`** *(bool, OPTIONAL)* - The value of the jail's security.bsd.suser_enabled sysctl. The super-user will be disabled automatically if its parent system has it disabled.  The super-user is enabled by default.

### Example
```json
"jail": {
    "parent": "jail-name-or-identifier",
	"host": "new",
    "vnet": "new",
    "enforceStatfs": 1,
	"allow": {
		"rawSockets": true,
		"chflags": true,
		"mount": [
			"devfs",
			"nullfs"
		]
	}
}
```

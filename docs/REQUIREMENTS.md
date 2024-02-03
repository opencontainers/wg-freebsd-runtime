# Requirements

This document contains a list of requirements identified
to be considered in all proposals originating from this WG.

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" are to be interpreted as described in [RFC 2119](https://tools.ietf.org/html/rfc2119) (Bradner, S., "Key words for use in RFCs to Indicate Requirement Levels", BCP 14, RFC 2119, March 1997).

## Definitions

- **Namespace**: A namespace allows a container to have its own isolated
  instance of a system resource. When using FreeBSD jails, this can be network,
  UTS or IPC.

## User Stories

1. As a user, I want control over which namespaces are private to a container
   and which are shared with the host.
2. As a user, I want to be able to define groups of containers which share
   namespaces.
3. As a user, I want control over resources used by a container, in particular
   CPU, memory and possibly network usage.
4. As a user, I want control over which devices are available inside a
   container, for instance to allow a container access to GPU functions or other
   hardware.
5. As a user, I want control over whether a container can mount filesystems and
   which types of filesystems can be mounted.
6. As a user, I want containers to be able to support nesting, for instance to
   allow the use of engines such as Podman or containerd inside the
   container.

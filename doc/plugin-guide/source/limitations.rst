Limitations
===========

* The plugin only supports neutron when specifying network settings. Old legacy mode (nova-network) is not supported

* If a base-os role node is deployed within the environment, the plugin
  installation may fail because the management network is not configured
  (see bug `1515956 <https://bugs.launchpad.net/fuel-plugins/+bug/1515956>`_).

* Prior to version 2.5.0, the plugin requires access to distribution repository,
  external or local mirror, in order to download necessary packages for proper
  installation.
  Since plugin version 2.5.0, the `fuel-mirror` (formerly `fuel-createmirror`) command is supported.


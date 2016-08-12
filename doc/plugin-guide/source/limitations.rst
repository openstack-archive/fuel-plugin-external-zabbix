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


Reduced footprint
-----------------

The Zabbix plugin doesn't support reduced footprint deployment for *Fuel 7.0*
neither for *Fuel 8.0*. This is tracked in Launchpad (see
bug `1610217 <https://bugs.launchpad.net/fuel/+bug/1610217>`_).

The Zabbix plugin version *2.5.1* supports the reduced footprint deployment
**only** with *Fuel 9.0* and **only** by following these steps:

1. Enable the `reduced footprint <https://docs.mirantis.com/openstack/fuel/fuel-master/operations/reduced-footprint-ops.html>`_ feature and deploy all *virt* nodes as 
   described **without** enabling the Zabbix
   plugin in Fuel UI settings.

2. Once the *virt* nodes are successfully deployed, enable Zabbix plugin in
   Fuel UI settings.

3. Deploy your OpenStack environment as usual (controllers, computes, ..).


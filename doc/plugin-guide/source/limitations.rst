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

The Zabbix plugin does not support reduced footprint deployment for Fuel 7.0
and Fuel 8.0. `LP1610217 <https://bugs.launchpad.net/fuel/+bug/1610217>`_

The Zabbix plugin version 2.5.1 supports the reduced footprint deployment
with Fuel 9.x **only**. To deploy a corresponding OpenStack environment:

#. Enable the `reduced footprint <https://docs.mirantis.com/openstack/fuel/fuel-master/operations/reduced-footprint-ops.html>`_
   feature and deploy all ``virt`` nodes **without** enabling the Zabbix
   plugin in the Fuel web UI.

#. Once the ``virt`` nodes are successfully deployed, enable the Zabbix plugin
   in the Fuel web UI.

#. Deploy your OpenStack environment as usual (controller, compute, and other nodes
   as required).

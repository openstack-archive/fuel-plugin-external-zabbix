===================================================
Guide to the Zabbix Plugin extension for Fuel
===================================================

This plugin extends Mirantis OpenStack functionality by adding Zabbix
monitoring system. It installs Zabbix server, frontend and agent components.
The plugin configures Zabbix by adding templates to monitor nodes and OpenStack
services and APIs.

Requirements
============

================================== ===============
Requirement                        Version/Comment
================================== ===============
Fuel                               7.0 and higher
================================== ===============

Release Notes
=============

**2.5.0**

* Enhance :ref:`Ceph` monitoring
* :ref:`tuning` for server and agents
* Add :ref:`MySQL` cluster metrics (wsrep global variables)
* Embed all package dependencies (bug 1483983_)
* Fix HAproxy configuration behind the Zabbix VIP (bug 1510115_)
* Compatibility with MOS 7.0 *(follow-up)*

  * Fix NTP monitoring on controller nodes (bug 1513454_)
  * Monitor `cinder-volume` process (instead of the Pacemaker resource which has
    been removed)
  * Fix trigger for Neutron DHCP/L3 agents (these agents run now on all controllers)

* New process checks

  * nova-conductor
  * nova-novncproxy

* Generate documentation with `Sphinx <http://sphinx-doc.org/>`_

.. _1483983: https://bugs.launchpad.net/fuel/7.0.x/+bug/1483983
.. _1510115: https://bugs.launchpad.net/fuel/+bug/1510115
.. _1513454: https://bugs.launchpad.net/fuel-plugins/+bug/1513454

**2.0.0**

* Fix HA issue when scaling down/up a controller (bug 1506767_)
* Compatibility with MOS 7.0
* Disable user Guest in zabbix
* Use HTTPS Zabbix UI
* Use dedicated VIP for Zabbix server

.. _1506767: https://bugs.launchpad.net/fuel-plugins/+bug/1506767

**1.0.0**

* This is the first release of the plugin.



Limitations
===========

* If a base-os role node is deployed within the environment, the plugin
  installation may fail because the management network is not configured
  (see bug `1515956 <https://bugs.launchpad.net/fuel-plugins/+bug/1515956>`_).

* Prior to version 2.5.0, the plugin requires access to distribution repository,
  external or local mirror, in order to download necessary packages for proper
  installation.
  Since plugin version 2.5.0, the `fuel-createmirror` command is supported.


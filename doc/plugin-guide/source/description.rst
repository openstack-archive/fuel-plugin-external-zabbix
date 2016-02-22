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
Fuel                               7.0 and 8.0
================================== ===============

Release Notes
=============

**2.5.0**

* Compatibility with MOS 8.0
* Service "zabbix_server" was restarted after executing of task "upload_core_repos" (bug 1529642_)
* Monitoring of HAProxy vips doesn't work when the backend name contains dots (bug 1525713_)
* Zabbix plugin should provide zabbix_get command (bug 1525924_)
* fail to deploy with base-os or virt roles (bug 1515956_)
* Enhance :ref:`Ceph` monitoring
* :ref:`tuning` for server and agents
* Add :ref:`MySQL` cluster metrics (wsrep global variables)
* Embed all package dependencies (bug 1483983_)
* Fix HAproxy configuration behind the Zabbix VIP (bug 1510115_)
* Reduced set of HA proxy gathered data to be in sync with LMA (bug 1531834_ + see `LMA metrics <http://fuel-plugin-lma-collector.readthedocs.org/en/latest/appendix_b.html#haproxy>`_)
* Compatibility with MOS 7.0 (follow up)

  * Fix NTP monitoring on controller nodes (bug 1513454_)
  * Monitor `cinder-volume` process (instead of the Pacemaker resource which has
    been removed)
  * Fix trigger for Neutron DHCP/L3 agents (these agents run now on all controllers)
  * Fix Swift container TCP check (bug 1517472_)

* New process checks

  * nova-conductor
  * nova-novncproxy

* Generate documentation with `Sphinx <http://sphinx-doc.org/>`_
* Allow deployment without Horizon (bug 1517005_)
* Skip zabbix agent installation when node has either 'base-os' or 'virt' role (bug 1515956_)

.. _1529642: https://bugs.launchpad.net/fuel-plugins/+bug/1529642
.. _1525713: https://bugs.launchpad.net/fuel-plugins/+bug/1525713
.. _1525924: https://bugs.launchpad.net/fuel-plugins/+bug/1525924
.. _1515956: https://bugs.launchpad.net/fuel-plugins/+bug/1515956
.. _1483983: https://bugs.launchpad.net/fuel/7.0.x/+bug/1483983
.. _1510115: https://bugs.launchpad.net/fuel/+bug/1510115
.. _1513454: https://bugs.launchpad.net/fuel-plugins/+bug/1513454
.. _1517472: https://bugs.launchpad.net/fuel/+bug/1517472
.. _1517005: https://bugs.launchpad.net/fuel/+bug/1517005
.. _1515956: https://bugs.launchpad.net/fuel-plugins/+bug/1515956
.. _1531834: https://bugs.launchpad.net/fuel-plugins/+bug/1531834

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

* If you remove some nodes after initial deployments, their related informations
  will not be removed from the Zabbix collected metrics and you will have to
  remove these manually from the Zabbix UI.

* MySQL database is common with other OpenStack services (see `1531834 <https://bugs.launchpad.net/fuel-plugins/+bug/1531834>`_)
  This has a potential high impact on the disk sizing for /var/lib/mysql even
  though the biggest set of data has been cut down drastically.

* Zabbix server service is located on one of the controller nodes
  therefore and in the exact same manner than `1531834 <https://bugs.launchpad.net/fuel-plugins/+bug/1531834>`_ can impact disk space,
  this can have a significant CPU and/or memory usage on controller nodes for large deployment.


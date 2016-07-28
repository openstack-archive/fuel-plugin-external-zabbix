=============================================
Guide to the Zabbix Plugin extension for Fuel
=============================================

This plugin extends Mirantis OpenStack functionality by adding Zabbix
monitoring system. It installs Zabbix server, frontend and agent components.
The plugin configures Zabbix by adding templates to monitor nodes and OpenStack
services and APIs.

Requirements
============

=========== ================
Requirement Version/Comment
=========== ================
Fuel        7.0, 8.0 and 9.0
=========== ================

Operational limitations
=======================

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


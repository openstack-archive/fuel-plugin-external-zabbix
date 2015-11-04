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

**2.5**

* Add Ceph metrics
* Configuration tunning for server and agents
* Check processes nova-conductor and nova-novncproxy
* Add MySQL cluster metrics (wsrep global variables)
* Embed all package dependencies

**2.0**

* Compatibility with MOS 7.0
* Disable user Guest in zabbix
* Use HTTPS Zabbix UI
* Use dedicated VIP for Zabbix server

**1.0**

* This is the first release of the plugin.



Limitations
===========

Prior to version 2.5, the plugin requires access to distribution repository,
external or local mirror, in order to download necessary packages for proper
installation.

With plugin version 2.5, the `fuel-createmirror` command is supported.

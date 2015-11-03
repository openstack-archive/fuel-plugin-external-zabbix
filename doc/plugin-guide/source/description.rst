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


Limitations
===========

Prior to version 2.5, the plugin requires access to distribution repository,
external or local mirror, in order to download necessary packages for proper
installation.

With plugin version 2.5, the `fuel-createmirror` command is supported.

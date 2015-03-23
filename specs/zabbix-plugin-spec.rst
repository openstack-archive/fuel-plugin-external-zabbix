..
 This work is licensed under the Apache License, Version 2.0.

 http://www.apache.org/licenses/LICENSE-2.0

=============================
Zabbix Fuel plugin
=============================

Zabbix plugin for Fuel extends Mirantis OpenStack functionality
by installing Zabbix monitoring system.
Zabbix is configured to monitor every node and OpenStack services and APIs.

Problem description
===================

Currently, Fuel has no support for monitoring nodes and OpenStack services.
Zabbix plugin aims to provide support for it.

Proposed change
===============

Implement a Fuel plugin that will install and configure the Zabbix monitoring
system in HA configuration. Zabbix server will be installed on Controllers and
Zabbix agent will be installed on every node.

Alternatives
------------

It might have been implemented as part of Fuel core but we decided to make it
as a plugin for several reasons:

* This isn't something that all operators may want to deploy.
* Any new additional functionality makes the project's testing more difficult,
  which is an additional risk for the Fuel release.

Data model impact
-----------------

None

REST API impact
---------------

None

Upgrade impact
--------------

None

Security impact
---------------

None

Notifications impact
--------------------

None

Other end user impact
---------------------

None

Performance Impact
------------------

Zabbix plugin has no direct performance impact on OpenStack, but it consumes
additional resources (CPU, memory, database) and this should be considered and
tested on a test environment before production use.

Other deployer impact
---------------------

None

Developer impact
----------------

None

Implementation
==============

Plugin delivers official Zabbix packages with server, frontend and agent
components. Plugin has several tasks:

* The first task installs Zabbix server and frontend on Controller nodes.
* The second task configures Zabbix server by installing monitoring templates.
* The third task installs Zabbix agent on every node, adds the node to Zabbix
  and links proper templates to the node using Zabbix server API.

Zabbix server is installed on all Controller nodes and is managed by
Pacemaker. It runs in active/passive mode where only one instance is active.
Plugin installs a dedicated resource manager file (OCF) for this.
Plugin configures Haproxy to provide one point of contact to the Zabbix server
API for Zabbix agents and Zabbix frontend.

Assignee(s)
-----------

| Dmitry Klenov <dklenov@mirantis.com> (PM)
| Piotr Misiak <pmisiak@mirantis.com> (developer)
| Szymon Bańka <sbanka@mirantis.com> (developer)
| Alexander Zatserklyany <azatserklyany@mirantis.com> (QA engineer)

Work Items
----------

* Implement the Fuel plugin.
* Implement the Puppet manifests.
* Testing.
* Write the documentation.

Dependencies
============

* Fuel 6.0 and higher.

Testing
=======

* Prepare a test plan.
* Test the plugin by deploying environments with all Fuel deployment modes.

Documentation Impact
====================

* Deployment Guide (how to install the plugin, how to configure and deploy an
  OpenStack environment with the plugin).
* User Guide (which features the plugin provides, how to use them in the
  deployed OpenStack environment).
* Test Plan.
* Test Report.

References
==========

* `Official Zabbix site <http://www.zabbix.com>`_

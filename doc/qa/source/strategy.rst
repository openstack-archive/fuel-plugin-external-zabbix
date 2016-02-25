=============
Test strategy
=============

Here are implemented three types of tests: system, functional and
nonfunctional. All tests will be automated. Functional tests can be
running in Tempest.

System testing will be performed in HA mode on CentOS and Ubuntu with
neutron vlan and gre network  settings.  Other types of testing will be
performed on Ubuntu with neutron vlan network  settings.

Acceptance criteria
===================

- Plugin enable Zabbix configuration and installation in Fuel
- Zabbix deployed on controllers.
- Zabbix web UI is operational.
- Zabbix works in HA mode.
- Zabbix configured with additional templates set.
- All blocker, critical and major issues are fixed.
- Documentation was delivered.
- Test results were delivered.

Test environment, infrastructure and tools
==========================================

- Fuel Master node with installed Zabbix plugin

Product compatibility matrix
============================

======================== ===============
Product                  Version/Comment
======================== ===============
Mirantis OpenStack       6.1
------------------------ ---------------
Zabbix monitoring plugin 1.0.1
======================== ===============


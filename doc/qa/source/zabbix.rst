========================
Zabbix Monitoring Plugin
========================

Zabbix Monitoring plugin for Fuel extends MOS functionality by adding Zabbix monitoring system. It uses Fuel plugin architecture.

- The Zabbix server must run on controller node. This node also stores the Zabbix database.
- Zabbix server supports HA architecture.
- Zabbix provides monitoring Openstack specific metrics like Cluster CPU Load, Number of instances, Openstack Offline Services etc.

Developer’s specification
=========================

========================= =====================================================================================
Document title            Link
========================= =====================================================================================
CI tests for zabbix       `https://blueprints.launchpad.net/fuel/+spec/implement-tests-for-monitoring-system
                          <https://blueprints.launchpad.net/fuel/+spec/implement-tests-for-monitoring-system>`_
------------------------- -------------------------------------------------------------------------------------
Developer’s specification `https://review.openstack.org/#/c/166816/3/specs/zabbix-plugin-spec.rst
                          <https://review.openstack.org/#/c/166816/3/specs/zabbix-plugin-spec.rst>`_
------------------------- -------------------------------------------------------------------------------------
Read me file              `https://review.openstack.org/#/c/166912/4/README.md
                          <https://review.openstack.org/#/c/166912/4/README.md>`_
========================= =====================================================================================

Limitations
===========

The plugin doesn’t have known limitation in network settings


Release notes / Changelog
=========================

**2.5.2**

* Compatibility with MOS 7.0, 8.0, 9.0, 9.1, 9.2 and 10.0

**2.5.1**

* Compatibility with MOS 7.0, 8.0, 9.0 and 9.1

**2.5.0**

* Compatibility with MOS 8.0
* Service "zabbix_server" was restarted after executing of task "upload_core_repos" (bug 1529642_)
* Monitoring of HAProxy vips doesn't work when the backend name contains dots (bug 1525713_)
* Zabbix plugin should provide zabbix_get command (bug 1525924_)
* Fail to deploy with base-os or virt roles (bug 1515956_)
* Enhance :ref:`Ceph` monitoring
* :ref:`tuning` for server and agents
* Add :ref:`MySQL` cluster metrics (wsrep global variables)
* Embed all package dependencies (bug 1483983_)
* Fix HAproxy configuration behind the Zabbix VIP (bug 1510115_)
* Reduced set of HA proxy gathered data to be in sync with LMA (bug 1531834_ + see `LMA metrics <http://fuel-plugin-lma-collector.readthedocs.org/en/latest/appendix_metrics.html#haproxy>`_)
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


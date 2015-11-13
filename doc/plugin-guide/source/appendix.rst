==================
Appendix
==================

.. _tunning:

Zabbix configuration tunning
============================

*New in version 2.5.0*

Zabbix server
-------------

To be able to handle large environments, Zabbix server is configured with the following
parameters (when enough memory is available on the node else the server uses
default configuration).

Memory cache sizes:

* CacheSize = 32M (default 8M)
* HistoryCacheSize = 128M (default 8M)
* TrendCacheSize = 512M (default 4M)
* HistoryTextCacheSize = 128M (default 16M)

The process numbers is also increased:

* StartPollers = 30
* StartPollersUnreachable = 30
* StartTrappersStartTrappers = 15

Refer to the `Zabbix server <https://www.zabbix.com/documentation/2.4/manual/appendix/config/zabbix_server>`_ official documentation for further details
and this `blog entry <http://blog.zabbix.com/monitoring-how-busy-zabbix-processes-are/457/>`_ can be useful to configure optimal count of Zabbix processes.

Zabbix agent
------------

The following parameters are set up:

* StartAgents = 10 (number of processes used to collect data, default 3)
* Timeout = 30 (default 3 seconds)

Refer to the `Zabbix agent <https://www.zabbix.com/documentation/2.4/manual/appendix/config/zabbix_agentd>`_ official documentation for futher details.

Kernel
------

Since cache related parameters of Zabbix server daemon are increased, Linux Kernel
have to be configured accordingly.
The plugin set up the max shared memory to 1GB (sysctl kernel.shmmax).

Refer to the `How to configure shared memory <https://www.zabbix.org/wiki/How_to/configure_shared_memory>`_ for further details.

Links
=========================

- `Zabbix Official site <http://www.zabbix.com>`_
- `Zabbix 2.4 documentation - SNMP traps <https://www.zabbix.com/documentation
  /2.4/manual/config/items/itemtypes/snmptrap>`_
- `Fuel Plugins CLI guide <https://docs.mirantis.com/openstack/fuel/fuel-7.0
  /user-guide.html#fuel-plugins-cli>`_

Components licenses
=========================

deb packages::

  zabbix-frontend-php: GPL-2.0
  zabbix-server-mysql: GPL-2.0
  zabbix-agent: GPL-2.0
  zabbix-sender: GPL-2.0

rpm packages::

  zabbix-agent: GPLv2+
  zabbix-server: GPLv2+
  zabbix-server-mysql: GPLv2+
  zabbix-web: GPLv2+
  zabbix-web-mysql: GPLv2+

========
Appendix
========

.. _tuning:

Zabbix configuration tuning
===========================

*New in version 2.5.0*

Zabbix server
-------------

To be able to handle large environments, Zabbix server is configured with the following
parameters (provided that there is enough memory on the node otherwise the default
values are used).

Memory cache sizes:

* CacheSize = 32M (default 8M)
* HistoryCacheSize = 128M (default 8M)
* TrendCacheSize = 512M (default 4M)
* HistoryTextCacheSize = 128M (default 16M)

The process numbers are also increased:

* StartPollers = 30
* StartPollersUnreachable = 30
* StartTrappersStartTrappers = 15

Refer to the `Zabbix server <https://www.zabbix.com/documentation/2.4/manual/appendix/config/zabbix_server>`_ official documentation for further details
and this `blog entry <http://blog.zabbix.com/monitoring-how-busy-zabbix-processes-are/457/>`_ can be useful to configure the optimal number of Zabbix processes.

Zabbix agent
------------

The following parameters are set up:

* StartAgents = 10 (number of processes used to collect data, default 3)
* Timeout = 30 (default 3 seconds)

Refer to the `Zabbix agent <https://www.zabbix.com/documentation/2.4/manual/appendix/config/zabbix_agentd>`_ official documentation for futher details.

Kernel
------

Since cache related parameters of Zabbix server daemon are increased, Linux kernel
has to be configured accordingly.
The plugin also configures the maximum shared memory to 1GB (sysctl kernel.shmmax).

Refer to the `How to configure shared memory <https://www.zabbix.org/wiki/How_to/configure_shared_memory>`_ for further details.

.. _links:

Links
=====

- `Zabbix Official site <http://www.zabbix.com>`_
- `Zabbix 2.4 documentation <https://www.zabbix.com/documentation/2.4/start>`_
- `Zabbix 2.4 documentation - SNMP traps <https://www.zabbix.com/documentation
  /2.4/manual/config/items/itemtypes/snmptrap>`_
- `Fuel Plugins CLI guide <https://docs.mirantis.com/openstack/fuel/fuel-7.0
  /user-guide.html#fuel-plugins-cli>`_

.. _licenses:

Components licenses
===================

deb packages
------------

=================== =======
Name                License
=================== =======
zabbix-agent        GPL-2.0
zabbix-frontend-php GPL-2.0
zabbix-get          GPL-2.0
zabbix-sender       GPL-2.0
zabbix-server-mysql GPL-2.0
=================== =======

rpm packages
------------

=================== =======
Name                License
=================== =======
zabbix-agent        GPLv2+
zabbix-get          GPLv2+
zabbix-sender       GPLv2+
zabbix-server       GPLv2+
zabbix-server-mysql GPLv2+
zabbix-web          GPLv2+
zabbix-web-mysql    GPLv2+
=================== =======


=====================
Zabbix plugin removal
=====================

To uninstall Zabbix plugin, follow these steps:

#. Delete all Environments in which Zabbix plugin has been enabled.

.. highlight:: none

#. Uninstall the plugin::

     # fuel plugins --remove zabbix_monitoring==2.5.0

#. Check if the plugin was uninstalled successfully::

     # fuel plugins
     id | name                      | version  | package_version
     ---|---------------------------|----------|----------------
     ...
     You can still have other plugins listed here but not zabbix_monitoring


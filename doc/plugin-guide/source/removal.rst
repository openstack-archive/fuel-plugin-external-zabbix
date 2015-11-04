==================
Removal Guide
==================

Zabbix plugin removal
============================================

To uninstall Zabbix plugin, follow these steps:

1. Delete all Environments in which Zabbix plugin has been enabled.
2. Uninstall the plugin:

   ::

     # fuel plugins --remove zabbix_monitoring==2.5.0

3. Check if the plugin was uninstalled successfully:

   ::

     # fuel plugins
      id | name                      | version  | package_version
      ---|---------------------------|----------|----------------

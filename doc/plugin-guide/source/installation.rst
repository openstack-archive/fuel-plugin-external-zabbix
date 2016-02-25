==================
Installation Guide
==================

Zabbix plugin installation
==========================

To install Zabbix plugin, follow these steps:

#. Download the plugin from the `Fuel Plugins Catalog
   <https://www.mirantis.com/products/openstack-drivers-and-plugins/fuel-plugins/>`_.

#. Copy the plugin on already installed Fuel Master node, ssh can be used
   for that. If you do not have the Fuel Master node yet, see
   `Quick Start Guide <https://software.mirantis.com/quick-start/>`_::

   # scp zabbix_monitoring-1.0-1.0.1-1.noarch.rpm root@<The_Fuel_Master_node_IP>:/tmp

#. Log into the Fuel Master node. Install the plugin::

    # cd /tmp
    # fuel plugins --install zabbix_monitoring-1.0-1.0.1-1.noarch.rpm

#. Check if the plugin was installed successfully::

    # fuel plugins
    id | name                      | version  | package_version
    ---|---------------------------|----------|----------------
    1  | zabbix_monitoring         | 1.0.1    | 2.0.0

Zabbix plugin removal
=====================

To uninstall Zabbix plugin, follow these steps:

1. Delete all Environments in which Zabbix plugin has been enabled.

2. Uninstall the plugin::

   # fuel plugins --remove zabbix_monitoring==1.0.1

3. Check if the plugin was uninstalled successfully::

    # fuel plugins
    id | name                      | version  | package_version
    ---|---------------------------|----------|----------------


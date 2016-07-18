==================
Installation Guide
==================

Zabbix plugin installation
============================================

To install Zabbix plugin, follow these steps:

#. Download the plugin from the
   `Fuel Plugins Catalog <https://www.mirantis.com/products/
   openstack-drivers-and-plugins/fuel-plugins/>`_.

#. Copy the plugin on already installed Fuel Master node, ssh can be used for
   that. If you do not have the Fuel Master node yet, see `Quick Start Guide
   <https://software.mirantis.com/quick-start/>`_::

   # scp zabbix_monitoring-2.5-2.5.1-1.noarch.rpm root@<Fuel_Master_IP>:/tmp

#. Log into the Fuel Master node. Install the plugin::

    # cd /tmp
    # fuel plugins --install zabbix_monitoring-2.5-2.5.1-1.noarch.rpm

#. Check if the plugin was installed successfully::

    # fuel plugins
    id | name                      | version  | package_version
    ---|---------------------------|----------|----------------
    1  | zabbix_monitoring         | 2.5.1    | 3.0.0


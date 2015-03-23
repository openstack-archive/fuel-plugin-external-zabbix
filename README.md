Zabbix Plugin for Fuel
=======================

Zabbix plugin
--------------

Zabbix plugin for Fuel extends Mirantis OpenStack functionality by adding
Zabbix monitoring system. It installs Zabbix server, frontend and agent
components. The plugin configures Zabbix by adding templates to monitor nodes
and OpenStack services and APIs.

Requirements
------------

| Requirement                      | Version/Comment |
|:---------------------------------|:----------------|
| Mirantis OpenStack compatibility | >= 6.0          |

Installation Guide
==================

Zabbix plugin installation
---------------------------

To install Zabbix plugin, follow these steps:

1. Download the plugin from
    [Fuel Plugins Catalog](https://software.mirantis.com/fuel-plugins)

2. Copy the plugin on already installed Fuel Master node; ssh can be used for
    that. If you do not have the Fuel Master node yet, see
    [Quick Start Guide](https://software.mirantis.com/quick-start/) :

   `scp zabbix_monitoring-1.0.0.fp root@:master_node_ip:/tmp`

3. Install the plugin:

   `fuel plugins --install zabbix_monitoring-1.0.0.fp`

4. Check if the plugin was installed successfully:

   ```
   fuel plugins
   id | name              | version | package_version
   ---|-------------------|---------|----------------
   1  | zabbix_monitoring | 1.0.0   | 1.0.0
   ```

Zabbix plugin configuration
----------------------------

1. Create an environment.
2. Enable the plugin on the Settings tab of the Fuel web UI.
3. Optionally, change values in the form:
   * username/password - access credentials for Zabbix Administrator
   * database password - password for Zabbix database in MySQL
4. Deploy the environment.
5. Zabbix frontend is available at: http://<VIP>/zabbix

User Guide
==========


Known issues
------------


Release Notes
-------------


Contributors
------------

Dmitry Klenov <dklenov@mirantis.com> (PM)  
Piotr Misiak <pmisiak@mirantis.com> (developer)  
Szymon Bańka <sbanka@mirantis.com> (developer)  
Alexander Zatserklyany <azatserklyany@mirantis.com> (QA engineer)  

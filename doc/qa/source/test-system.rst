==============
System testing
==============

Deploy environment with plugin
==============================

* Test Case ID:  deploy_zabbix_ha
* Expected Result: Cluster deployed, Zabbix dashboard available, Zabbix dashboard is not empty

Steps:

* Upload plugin to the master node
* Install plugin
* Create cluster
* Add 3 nodes with controller role
* Add 1 node with compute role
* Add 1 node with cinder role
* Deploy the cluster
* Run network verification
* Check plugin health
* Run OSTF
* Check login to zabbix dashboard
* Check that zabbix dashboard is not empty

Uninstall of plugin
===================

Test Case ID: uninstall_zabbix_plugin
Expected Result: Zabbix plugin was installed and then removed successfully

Steps:

* install plugin : fuel plugins --install  plugin.rpm
* check that it was successfully installed: fuel plugins
* remove plugin:  fuel plugins --remove plugin_name==version
* check that it was successfully removed: fuel plugins

Uninstall of plugin with deployed environment
=============================================

* Test Case ID: uninstall_zabbix_plugin_with_deployed_env
* Expected Result: Zabbix plugin was installed successfully.  Alert is present when we trying to delete plugin  which is attached to enabled environment.  When environment was removed, plugin is removed successfully too.


Steps:
 * install plugin
 * deploy environment with enabled plugin functionality
 * run ostf
 * try to delete plugin and ensure that present in cli alert: "400 Client Error: Bad Request (Can't delete plugin which is enabled for some environment.)"
 * remove environment
 * remove plugin
 * check that it was successfully removed

Deploy environment with plugin and Ceph
=======================================

* Test Case ID:  deploy_zabbix_ceph_ha
* Expected Result: Cluster deployed, Zabbix dashboard available, Zabbix dashboard is not empty

Steps:

* Upload plugin to the master node
* Install plugin
* Create cluster
* Add 3 nodes with controller,ceph-osd roles
* Add 2 nodes with compute,ceph-osd roles
* Deploy the cluster
* Run network verification
* Check plugin health
* Run OSTF
* Check login to zabbix dashboard
* Check that zabbix dashboard is not empty
* Check that zabbix screen for Ceph is present (Monitoring > Screens > Ceph)

Deploy environment with plugin and fuel-createmirror
====================================================

* Test Case ID:  deploy_zabbix_ha_offline
* Expected Result: Cluster deployed, Zabbix dashboard available, Zabbix dashboard is not empty

Steps:

* Upload plugin to the master node
* Install plugin
* run `fuel-createmirror` command on fuel master node
* Create cluster
* Add 3 nodes with controller role
* Add 1 node with compute role
* Add 1 node with cinder role
* Deploy the cluster
* Run network verification
* Check plugin health
* Run OSTF
* Check login to zabbix dashboard
* Check that zabbix dashboard is not empty


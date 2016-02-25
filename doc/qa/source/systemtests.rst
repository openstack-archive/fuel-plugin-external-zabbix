==============
System testing
==============

Deploy Environment with plugin
==============================

=============== ====================================
Test Case ID    deploy_zabbix_ha                   
=============== ====================================
Steps           #. Upload plugin to the master node
                #. Install plugin
                #. Create cluster
                #. Add 3 nodes with controller role
                #. Add 1 node with compute role
                #. Add 1 node with cinder role
                #. Deploy the cluster
                #. Run network verification
                #. Check plugin health
                #. Run OSTF
                #. Check login to zabbix dashboard
                #. Check that zabbix dashboard is
		   not empty
--------------- ------------------------------------
Expected Result Cluster deployed, Zabbix dashboard
                available, Zabbix dashboard is not
                empty
=============== ====================================

Uninstall of plugin
===================

=============== ====================================
Test Case ID    uninstall_zabbix_plugin
=============== ====================================
Steps           #. install plugin :

                   ``fuel plugins
                   --install plugin.rpm``
                #. check that it was successfully
                   installed:

		   ``fuel plugins``
                #. remove plugin:

		   ``fuel plugins
                   --remove plugin_name==version``
                #. check that it was successfully
                   removed:

		   ``fuel plugins``
--------------- ------------------------------------
Expected Result Zabbix plugin was installed and
                then removed successfully
=============== ====================================

Uninstall of plugin with deployed environment
=============================================

=============== =========================================
Test Case ID    uninstall_zabbix_plugin_with_deployed_env
=============== =========================================
Steps           #. install plugin
                #. deploy environment with enabled
                   plugin functionality
                #. run ostf
                #. try to delete plugin and ensure
                   that present in cli alert: "400
                   Client Error: Bad Request (Can't
                   delete plugin which is enabled
                   for some environment.)"
                #. remove environment
                #. remove plugin
                #. check that it was successfully
                   removed
--------------- -----------------------------------------
Expected Result Zabbix plugin was installed
                successfully. Alert is present when
                we trying to delete plugin which is
                attached to enabled environment.
                When environment was removed,
                plugin is removed successfully too.
=============== =========================================


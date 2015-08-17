==========
User Guide
==========

Environment configuration
=========================

#. Create an environment. For more information about environment creation, see
   `Mirantis OpenStack User Guide <http://docs.mirantis.com/openstack/fuel
   /fuel-7.0/user-guide.html#create-a-new-openstack-environment>`_.

#. Choose in *Environments* an evironment for which you want to run Zabbix
   plugin.

#. Open *Settings* tab and scroll the page down. On the left select
   *Zabbix for Fuel*.

#. Set credentials for *Zabbix for Fuel*:

   .. image:: images/settings.png
      :width: 33%

   You could see default passwords by clicking on the eye icon. It is highly
   recommended to change default passwords for Zabbix Administrator and
   Zabbix Database.

#. Adjust other environment settings to your requirements and deploy the
   environment. For more information, see
   `Mirantis OpenStack User Guide <http://docs.mirantis.com/openstack/fuel
   /fuel-7.0/user-guide.html#create-a-new-openstack-environment>`_.

Zabbix frontend UI
=========================

#. After successful deployment you will see a green notification: “Deployment
   of environment 'test' is done. Access the OpenStack dashboard (Horizon) at
   `http://172.16.0.2/ <http://172.16.0.2/>`_”.

   In this example, 172.16.0.2 is a VIP address.

   Zabbix UI will be available at `http://172.16.0.2/zabbix
   <http://172.16.0.2/zabbix>`_ (at http://<VIP>/zabbix in general).
   After opening this address in a browser, you should see Zabbix login page:

   .. image:: images/login.png

#. Now log into Zabbix with the credentials set provided on the Settings tab of
   the Fuel web UI (see step 2 in the Environment configuration section).
   After logging into Zabbix, you will see the Zabbix Dashboard page:

   .. image:: images/dashboard.png

#. The Zabbix Dashboard page provides information on running processes and
   their state. If all processes are running successfully in the environment,
   you should see only green colour. To demonstrate that monitoring is working
   properly, the Nova Scheduler process had been turned off. You can notice
   that Zabbix detected the halted process and provided the problem
   description: Nova Scheduler process is not running on node-13.domain.tld.
   When you go to Monitoring->Screens page, you will see the OpenStack Cluster
   screen:

   .. image:: images/openstackcluster1.png
   .. image:: images/openstackcluster2.png

   On this screen you have general statistics and graphs presenting resources
   usage in OpenStack environment. There is also a list of last 10 events
   recorded by Zabbix.

Pages
=========================

Below there are a few screenshots from Zabbix configuration pages to show how
it should look after a successful environment deployment. Zabbix UI provides
several pages placed under Configuration tab.

#. Host groups page
   This page has a list of host groups with their members. There are separate
   groups for Controllers and Computes. These groups are used to join nodes
   with the same role in OpenStack environment. There is also ManagedByPuppet
   group which contains all OpenStack nodes. Remaining host groups are created
   by default in Zabbix. For more information and instructions, see `6.1 Hosts
   and host groups <https://www.zabbix.com/documentation/2.4/manual/config
   /hosts>`_ chapter in the official Zabbix Documentation.


   .. image:: images/hostgroupspage.png

#. Hosts page
   This page contains a list of all monitored OpenStack nodes and, additionally
   one OpenStackCluster virtual host which represents OpenStack API. There are
   also lists of linked monitoring templates to particular hosts. During
   installation, the plugin detects which services have been installed on a
   particular node and links appropriate templates to the node to enable
   monitoring for those services. There is an Zabbix agent availability report
   in the last column. When ‘Z’ icon is green, the Zabbix agent on this node is
   running and available.

   .. image:: images/hostpage.png
   .. image:: images/hostpage2.png

#. Templates page
   This page contains a list of all monitoring templates and list of hosts to
   which they are linked. A monitoring template is a way to group items, graphs
   and thresholds which monitor a particular resource type, for example an
   OpenStack service like Nova Compute. For more information and instructions,
   see `6.6 Templates chapter <https://www.zabbix.com/documentation/2.4/manual
   /config/templates>`_ in the official Zabbix Documentation.

   .. image:: images/templatespage.png
   .. image:: images/templatespage2.png

   You can add an additional items (checks), create triggers and events via
   Zabbix UI. For more information and instructions, see `6.2 Items
   <https://www.zabbix.com/documentation/2.4/manual/config/items>`_, `6.3
   Triggers <https://www.zabbix.com/documentation/2.4/manual/config/triggers>`_
   and `6.4 Events chapters <https://www.zabbix.com/documentation/2.4/manual
   /config/events>`_ in the official Zabbix Documentation. By default, there
   are no notifications configured, but you can add them into the Zabbix UI.
   For more information and instructions, see `6.7 Notifications
   <https://www.zabbix.com/documentation/2.4/manual/config/notifications>`_
   upon events chapter in the official Zabbix Documentation.

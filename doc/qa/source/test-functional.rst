==================
Functional testing
==================

Check Zabbix deployment
=======================

Test ID:
* test_zabbix_deployment
* test_zabbix_started

Expected Result: Zabbix Started

Steps:

* Check that package zabbix-server installed on controllers
* Check that zabbix-server is started via `crm status`


Check Zabbix API
================

Test IDs:

* test_get_ver_API
* test_authentication_valid_cred
* test_authentication_invalid_cred
* test_http
* test_https
* test_ssl_certificate

Expected Result: All steps passed

Steps:

* Get version API
* Test authentication with valid credentials
* Test if authentication impossible with invalid credentials
* Check HTTP request to dashboard
* Check HTTPS request to dashboard
* Check SSL certificate

Check dashboard configuration
=============================

Test ID: test_graph

Expected Result: Dashboard is preconfigured

Steps:

* Log in to zabbix web
* Get zabbix/screens.php
* Check preconfigured graphs:
  * screen 'OpenStack Cluster'
  * screen 'Ceph' if Ceph is deployed

Check zabbix triggers
=====================

Test ID: test_triggers

Expected Result: All preconfigured triggers are present

Steps:

* Log in to zabbix web
* Check if preconfigured triggers are present


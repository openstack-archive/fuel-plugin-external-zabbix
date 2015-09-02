#
#    Copyright 2015 Mirantis, Inc.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.
#
class plugin_zabbix::params {

  include plugin_zabbix::params::openstack

  $zabbix_hash = hiera('zabbix_monitoring')
  $network_metadata = hiera('network_metadata')
  $ssl = hiera('public_ssl')

  $zabbix_ports = {
    server         => '10051',
    agent          => '10049',
    backend_agent  => '10050',
  }

  case $::operatingsystem {
    'Ubuntu', 'Debian': {
      $agent_pkg                = 'zabbix-agent'
      $server_pkg               = 'zabbix-server-mysql'
      $frontend_pkg             = 'zabbix-frontend-php'

      $agent_service            = 'zabbix-agent'
      $server_service           = 'zabbix-server'

      $agent_log_file           = '/var/log/zabbix/zabbix_agentd.log'
      $server_log_file          = '/var/log/zabbix/zabbix_server.log'

      $prepare_schema_cmd       = 'cat /usr/share/zabbix-server-mysql/schema.sql /usr/share/zabbix-server-mysql/images.sql > /tmp/zabbix/schema.sql'

      $frontend_service         = 'apache2'
      $frontend_service_config  = '/etc/zabbix/apache.conf'
      $frontend_config          = '/etc/zabbix/web/zabbix.conf.php'
      $php_config               = '/etc/php5/apache2/php.ini'
      $php_mysql_pkg            = 'php5-mysql'
    }
    'CentOS', 'RedHat': {

      $agent_pkg                = 'zabbix-agent'
      $server_pkg               = 'zabbix-server-mysql'
      $frontend_pkg             = 'zabbix-web-mysql'

      $agent_service            = 'zabbix-agent'
      $server_service           = 'zabbix-server'

      $agent_log_file           = '/var/log/zabbix/zabbix_agentd.log'
      $server_log_file          = '/var/log/zabbix/zabbix_server.log'

      $prepare_schema_cmd       = 'cat /usr/share/doc/zabbix-server-mysql-`zabbix_server -V | awk \'/v[0-9].[0-9].[0-9]/{print substr($3, 2)}\'`/create/schema.sql /usr/share/doc/zabbix-server-mysql-`zabbix_server -V | awk \'/v[0-9].[0-9].[0-9]/{print substr($3, 2)}\'`/create/images.sql > /tmp/zabbix/schema.sql'

      $frontend_service         = 'httpd'
      $frontend_service_config  = '/etc/httpd/conf.d/zabbix.conf'
      $frontend_config          = '/etc/zabbix/web/zabbix.conf.php'
      $php_config               = '/etc/php.ini'
      $php_mysql_pkg            = 'php-mysql'
    }
    default: {
      fail("unsuported osfamily ${::osfamily}, currently Debian and Redhat are the only supported platforms")
    }
  }

  $agent_listen_ip           = $::internal_address
  $agent_source_ip           = $::internal_address

  $agent_config_template     = 'plugin_zabbix/zabbix_agentd.conf.erb'
  $agent_config              = '/etc/zabbix/zabbix_agentd.conf'
  $agent_pid_file            = '/var/run/zabbix/zabbix_agentd.pid'

  $agent_include             = '/etc/zabbix/zabbix_agentd.d'
  $agent_scripts             = '/etc/zabbix/scripts'
  $has_userparameters        = true

  #server parameters
  $vip_name                  = 'zbx_vip_mgmt'
  $server_ip                 = $network_metadata['vips'][$vip_name]['ipaddr']
  $server_config             = '/etc/zabbix/zabbix_server.conf'
  $server_scripts            = '/etc/zabbix/externalscripts'
  $server_config_template    = 'plugin_zabbix/zabbix_server.conf.erb'
  $server_node_id            = 0
  $server_ensure             = present
  $ocf_scripts_dir           = '/usr/lib/ocf/resource.d'
  $ocf_scripts_provider      = 'fuel'

  #frontend parameters
  $frontend                  = true
  $frontend_ensure           = present
  $frontend_base             = '/zabbix'
  $frontend_config_template  = 'plugin_zabbix/zabbix.conf.php.erb'

  #common parameters
  $db_type                   = 'MYSQL'
  $db_ip                     = hiera('management_vip')
  $db_port                   = '3306'
  $db_name                   = 'zabbix'
  $db_user                   = 'zabbix'
  $db_password               = $zabbix_hash['db_password']

  #zabbix hosts params
  $host_name                 = $::fqdn
  $host_ip                   = $::internal_address
  $host_groups               = ['ManagedByPuppet', 'Controllers', 'Computes']
  $host_groups_base          = ['ManagedByPuppet', 'Linux servers']
  $host_groups_controller    = ['Controllers']
  $host_groups_compute       = ['Computes']

  #zabbix admin
  $zabbix_admin_username     = $zabbix_hash['username']
  $zabbix_admin_password     = $zabbix_hash['password']
  $zabbix_admin_password_md5 = md5($zabbix_hash['password'])

  #api
  if $ssl[horizon] == true {
    $api_url = "https://${server_ip}${frontend_base}/api_jsonrpc.php"
  }else{
    $api_url = "http://${server_ip}${frontend_base}/api_jsonrpc.php"
  }

  $api_hash = { endpoint => $api_url,
                username => $zabbix_admin_username,
                password => $zabbix_admin_password, }

}

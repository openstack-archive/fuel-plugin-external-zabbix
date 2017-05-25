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

  $zabbix_version = $::check_zabbix_version
  $zabbix_hash = hiera('zabbix_monitoring')
  $network_metadata = hiera_hash('network_metadata')
  $ssl = hiera('public_ssl')
  $zabbix_base_conf_dir = '/etc/zabbix'
  $zabbix_extra_conf_subdir = 'conf.d'
  $zabbix_extra_conf_dir = "${zabbix_base_conf_dir}/${zabbix_extra_conf_subdir}"
  $zabbix_base_run_dir = '/var/run/zabbix'
  $zabbix_base_log_dir = '/var/log/zabbix'

  if versioncmp($zabbix_version, '2.4') < 0 {
    $zabbix_includes = $zabbix_extra_conf_dir
    $zabbix_trigger_exp_not_equal = '#'
  } else {
    $zabbix_includes = "${zabbix_extra_conf_dir}/*.conf"
    $zabbix_trigger_exp_not_equal = '&lt;&gt;'
  }

  $zabbix_ports = {
    server         => '10051',
    agent          => '10049',
    backend_agent  => '10050',
    fcgi           => '9003',
  }

  case $::operatingsystem {
    'Ubuntu', 'Debian': {
      $php_fpm_pkg               = 'php5-fpm'
      $php_fpm_config            = '/etc/php5/fpm/pool.d/www.conf'
      $php_fpm_service           = 'php5-fpm'
      $php_common_pkg            = 'php5-common'
      $apache_fcgi_pkg           = 'libapache2-mod-fastcgi'
      $agent_pkg                 = 'zabbix-agent'
      $server_pkg                = 'zabbix-server-mysql'
      $frontend_pkg              = 'zabbix-frontend-php'
      $sender_pkg                = 'zabbix-sender'
      $get_pkg                   = 'zabbix-get'

      $agent_service             = 'zabbix-agent'
      $server_service            = 'zabbix-server'

      $agent_log_file            = "${zabbix_base_log_dir}/zabbix_agentd.log"
      $server_log_file           = "${zabbix_base_log_dir}/zabbix_server.log"

      $prepare_schema_cmd        = join([
        'cat /usr/share/zabbix-server-mysql/schema.sql',
        ' /usr/share/zabbix-server-mysql/images.sql',
        ' > /tmp/zabbix/schema.sql'], '')

      $frontend_service          = 'apache2'
      $frontend_service_template = 'plugin_zabbix/zabbix_apache.conf.erb'
      # For some unknown reason putting the file in conf-available
      # and running 'a2enconf zabbix' does not work, so keeping conf file
      # in conf.d for now
      $frontend_service_config   = '/etc/apache2/conf.d/zabbix.conf'
      $frontend_config           = "${zabbix_base_conf_dir}/web/zabbix.conf.php"
      $php_config                = '/etc/php5/fpm/php.ini'
      $php_mysql_pkg             = 'php5-mysql'
      $zabbix_document_root      = '/usr/share/zabbix'
    }
    'CentOS', 'RedHat': {
      $agent_pkg                = 'zabbix-agent'
      $server_pkg               = 'zabbix-server-mysql'
      $frontend_pkg             = 'zabbix-web-mysql'
      $sender_pkg               = 'zabbix-sender'
      $get_pkg                  = 'zabbix-get'

      $agent_service            = 'zabbix-agent'
      $server_service           = 'zabbix-server'

      $agent_log_file           = "${zabbix_base_log_dir}/zabbix_agentd.log"
      $server_log_file          = "${zabbix_base_log_dir}/zabbix_server.log"

      $prepare_schema_cmd       = join([
        'cat /usr/share/doc/zabbix-server-mysql-`zabbix_server -V',
        ' | awk \'/v[0-9].[0-9].[0-9]/{print substr($3, 2)}\'',
        '`/create/schema.sql /usr/share/doc/zabbix-server-mysql-`zabbix_server -V',
        ' | awk \'/v[0-9].[0-9].[0-9]/{print substr($3, 2)}\'',
        '`/create/images.sql > /tmp/zabbix/schema.sql'], '')

      $frontend_service         = 'httpd'
      $frontend_service_config  = '/etc/httpd/conf.d/zabbix.conf'
      $frontend_config          = "${zabbix_base_conf_dir}/web/zabbix.conf.php"
      $php_config               = '/etc/php.ini'
      $php_mysql_pkg            = 'php-mysql'
    }
    default: {
      fail("unsuported osfamily ${::osfamily}, currently Debian and Redhat are the only supported platforms")
    }
  }

  $agent_listen_ip                   = $::internal_address
  $agent_source_ip                   = $::internal_address

  $agent_config_template             = 'plugin_zabbix/zabbix_agentd.conf.erb'
  $agent_config                      = "${zabbix_base_conf_dir}/zabbix_agentd.conf"
  $agent_pid_file                    = "${zabbix_base_run_dir}/zabbix_agentd.pid"

  $agent_include                     = "${zabbix_base_conf_dir}/zabbix_agentd.d"
  $agent_scripts                     = "${zabbix_base_conf_dir}/scripts"
  $has_userparameters                = true
  $agent_start_agents                = '10'
  $agent_log_file_size               = '1024'
  $agent_timeout                     = '30'

  #server parameters
  $vip_name                          = 'zbx_vip_mgmt'
  $server_ip                         = $network_metadata['vips'][$vip_name]['ipaddr']
  $server_public_ip                  = $network_metadata['vips']['public']['ipaddr']
  $mgmt_vip                          = $network_metadata['vips']['management']['ipaddr']
  $server_config                     = "${zabbix_base_conf_dir}/zabbix_server.conf"
  $server_config_template            = 'plugin_zabbix/zabbix_server.conf.erb'
  $server_node_id                    = 0
  $server_ensure                     = present
  $ocf_scripts_dir                   = '/usr/lib/ocf/resource.d'
  $ocf_scripts_provider              = 'fuel'
  $server_start_pollers              = '30'
  $server_start_pollers_unreachable  = '30'
  $server_start_trappers             = '15'
  $server_cache_update_frequency     = '60'
  if $::memoryfree_mb >= 800 {
    $server_cache_size                 = '32M'
    $server_history_cache_size         = '128M'
    $server_trend_cache_size           = '512M'
    $server_history_text_cache_size    = '128M'
  } else { # use minimal configuration
    $server_cache_size                 = '16M'
    $server_history_cache_size         = '8M'
    $server_trend_cache_size           = '4M'
    $server_history_text_cache_size    = '16M'
  }
  $server_log_slow_queries           = '1000'
  # 1Gb allowed for shared memory
  $sysctl_kernel_shmmax              = '1073741824'

  #frontend parameters
  $frontend                          = true
  $frontend_ensure                   = present
  $frontend_base                     = '/zabbix'
  $frontend_config_template          = 'plugin_zabbix/zabbix.conf.php.erb'

  #common parameters
  $db_type                           = 'MYSQL'
  $db_ip                             = hiera('management_vip')
  $db_port                           = '3306'
  $db_name                           = 'zabbix'
  $db_user                           = 'zabbix'
  $db_password                       = $zabbix_hash['db_password']

  #zabbix hosts params
  $host_name                         = $::fqdn
  $host_ip                           = $::internal_address
  $host_groups                       = ['ManagedByPuppet', 'Controllers', 'Computes', 'Ceph Cluster', 'Ceph MONs', 'Ceph OSDs']
  $host_groups_base                  = ['ManagedByPuppet', 'Linux servers']
  $host_groups_controller            = ['Controllers']
  $host_groups_compute               = ['Computes']
  $host_groups_ceph_cluster          = ['Ceph Cluster']
  $host_groups_ceph_mon              = ['Ceph MONs']
  $host_groups_ceph_osd              = ['Ceph OSDs']

  #zabbix admin
  $zabbix_admin_username             = $zabbix_hash['username']
  $zabbix_admin_password             = $zabbix_hash['password']
  $zabbix_admin_password_md5         = md5($zabbix_hash['password'])

  #api
  $use_ssl = $ssl[horizon] or $ssl[services]
  if $use_ssl {
    if $ssl[horizon] {
      $api_url = "https://${server_public_ip}${frontend_base}/api_jsonrpc.php"
    } else {
      $api_url = "http://${server_public_ip}${frontend_base}/api_jsonrpc.php"
    }
  } else {
    $api_url = "http://${server_public_ip}${frontend_base}/api_jsonrpc.php"
  }

  $api_hash = { endpoint => $api_url,
                username => $zabbix_admin_username,
                password => $zabbix_admin_password, }
}

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

# This empty class is used further down to communicate properly with
# local MySQL server using existing .my.cnf configuration unchanged
class dummy::mysql::server {
}

class plugin_zabbix::controller {

  $fuel_version = 0 + hiera('fuel_version')

  $zabbix_pcmk_managed = $::check_zabbix_pacemaker

  include plugin_zabbix::params
  $host = regsubst($plugin_zabbix::params::db_ip,'^(\d+\.\d+\.\d+\.)\d+','\1%')

  file { '/etc/dbconfig-common':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { '/etc/dbconfig-common/zabbix-server-mysql.conf':
    ensure  => present,
    require => File['/etc/dbconfig-common'],
    mode    => '0600',
    source  => 'puppet:///modules/plugin_zabbix/zabbix-server-mysql.conf',
  }

  package { $plugin_zabbix::params::server_pkg:
    ensure  => present,
    require => File['/etc/dbconfig-common/zabbix-server-mysql.conf'],
  }

  file { $plugin_zabbix::params::server_config:
    ensure  => present,
    require => Package[$plugin_zabbix::params::server_pkg],
    content => template($plugin_zabbix::params::server_config_template),
  }

  file { $plugin_zabbix::params::zabbix_extra_conf_dir:
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => Package[$plugin_zabbix::params::server_pkg],
  }

  file { 'zabbix-server-ocf' :
    ensure => present,
    path   => join([
      $plugin_zabbix::params::ocf_scripts_dir,
      "/${plugin_zabbix::params::ocf_scripts_provider}",
      "/${plugin_zabbix::params::server_service}"], ''),
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
    source => 'puppet:///modules/plugin_zabbix/zabbix-server.ocf',
  }
  if $zabbix_pcmk_managed == '' {
    service { "${plugin_zabbix::params::server_service}-init-stopped":
      ensure  => 'stopped',
      name    => $plugin_zabbix::params::server_service,
      enable  => false,
      require => File[$plugin_zabbix::params::server_config],
    }
  }
  service { "${plugin_zabbix::params::server_service}-started":
    ensure   => running,
    name     => "p_${plugin_zabbix::params::server_service}",
    enable   => true,
    provider => 'pacemaker',
  }

  if $zabbix_pcmk_managed == '' {
    File['zabbix-server-ocf'] ->
    Service["${plugin_zabbix::params::server_service}-init-stopped"] ->
    Service["${plugin_zabbix::params::server_service}-started"]
  } else {
    File['zabbix-server-ocf'] -> Service["${plugin_zabbix::params::server_service}-started"]
  }
  sysctl::value { 'kernel.shmmax':
    value  => $plugin_zabbix::params::sysctl_kernel_shmmax,
    notify => Service["${plugin_zabbix::params::server_service}-started"],
  }

  if $fuel_version < 9.0 {
    class { '::mysql::server':
      custom_setup_class => 'dummy::mysql::server',
    }
  } else {
    # Class used to prevent the installation of a mysql-client-X.Y that may not be
    # compatible with the mysql-client meta-package that is installed by
    # mysql Puppet module.
    class { '::mysql::client':
      package_manage => false,
    }
  }

  mysql::db { $plugin_zabbix::params::db_name:
    user     => $plugin_zabbix::params::db_user,
    password => $plugin_zabbix::params::db_password,
    host     => $host,
  }

  if $plugin_zabbix::params::frontend {
    class { 'plugin_zabbix::frontend':
      require => File[$plugin_zabbix::params::server_config],
      before  => Class['plugin_zabbix::ha::haproxy'],
    }
  }

  include plugin_zabbix::ha::haproxy

  firewall { '998 zabbix agent vip':
    proto  => 'tcp',
    action => 'accept',
    port   => $plugin_zabbix::params::zabbix_ports['agent'],
  }

  firewall { '998 zabbix server vip':
    proto  => 'tcp',
    action => 'accept',
    port   => $plugin_zabbix::params::zabbix_ports['server'],
  }
}

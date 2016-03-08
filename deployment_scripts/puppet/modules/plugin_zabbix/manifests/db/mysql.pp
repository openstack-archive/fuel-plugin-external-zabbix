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
class plugin_zabbix::db::mysql(
  $db_ip       = undef,
  $db_password = 'zabbix',
) {

  include plugin_zabbix::params

  file { '/tmp/zabbix':
    ensure => directory,
    mode   => '0755',
  }

  file { '/tmp/zabbix/parts':
    ensure  => directory,
    purge   => true,
    force   => true,
    recurse => true,
    mode    => '0755',
    source  => 'puppet:///modules/plugin_zabbix/sql',
    require => File['/tmp/zabbix']
  }

  file { '/tmp/zabbix/parts/data_clean.sql':
    ensure  => present,
    require => File['/tmp/zabbix/parts'],
    content => template('plugin_zabbix/data_clean.erb'),
  }

  exec { 'prepare-schema-1':
    command => $plugin_zabbix::params::prepare_schema_cmd,
    creates => '/tmp/zabbix/schema.sql',
    path    => ['/usr/sbin', '/usr/bin', '/sbin', '/bin'],
    require => [File['/tmp/zabbix'], Package[$plugin_zabbix::params::server_pkg]],
    notify  => Exec['prepare-schema-2'],
  }

  exec { 'prepare-schema-2':
    command     => 'cat /tmp/zabbix/parts/*.sql >> /tmp/zabbix/schema.sql',
    path        => ['/usr/sbin', '/usr/bin', '/sbin', '/bin'],
    refreshonly => true,
    require     => File['/tmp/zabbix/parts/data_clean.sql'],
  }

  if $plugin_zabbix::params::db_is_external {
    $su = size($plugin_zabbix::params::db_admin_user)
    $sp = size($plugin_zabbix::params::db_admin_password)
    if ($su > 0) {
      $u_param = " --user=${plugin_zabbix::params::db_admin_user}"
    } else {
      $u_param = ''
    }
    if ($sp > 0) {
      $p_param = " --password=${plugin_zabbix::params::db_admin_password}"
    } else {
      $p_param = ''
    }
    $mysql_extras = "${u_param}${p_param} --host=${plugin_zabbix::params::db_ip} --port=${plugin_zabbix::params::db_port}"
  } else {
    $mysql_extras = ''
  }
  $mysql_cmd = "/usr/bin/mysql${mysql_extras} ${plugin_zabbix::params::db_name} < /tmp/zabbix/schema.sql"

  exec{ "${plugin_zabbix::params::db_name}-import":
    command     => $mysql_cmd,
    logoutput   => true,
    refreshonly => true,
    subscribe   => Database[$plugin_zabbix::params::db_name],
    require     => Exec['prepare-schema-2'],
  }
}

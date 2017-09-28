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
  $db_vip = hiera('database_vip')
  $mysql_db = hiera('mysql')
  $db_passwd = $mysql_db['root_password']

  $fuel_version = 0 + hiera('fuel_version')

  if $fuel_version < 9.0 {
    $mysql_extras_args = ''
    $next_require = Database[$plugin_zabbix::params::db_name]
  } else {
    # For some reason on MOS 9.0 the mysql command does not seem to be using
    # the existing /root/.my.cnf file therefore credentials and host
    # have to be specified
    $mysql_extras_args = "-h${db_vip} -uroot -p${db_passwd}"
    $next_require = Mysql::Db[$plugin_zabbix::params::db_name]
  }

  file { '/tmp/zabbix':
    ensure => directory,
    mode   => '0755',
  }

  file { '/tmp/zabbix/data_clean.sql':
    ensure  => present,
    require => File['/tmp/zabbix'],
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
    command     => 'cat /tmp/zabbix/data_clean.sql >> /tmp/zabbix/schema.sql',
    path        => ['/usr/sbin', '/usr/bin', '/sbin', '/bin'],
    refreshonly => true,
    require     => File['/tmp/zabbix/data_clean.sql'],
  }

  exec { "${plugin_zabbix::params::db_name}-import":
    command     => "/usr/bin/mysql ${mysql_extras_args} ${plugin_zabbix::params::db_name} < /tmp/zabbix/schema.sql",
    logoutput   => true,
    refreshonly => true,
    subscribe   => $next_require,
    require     => Exec['prepare-schema-2'],
  }

  exec { 'purge-tmp-dir':
    command     => 'rm -rf /tmp/zabbix',
    path        => ['/usr/sbin', '/usr/bin', '/sbin', '/bin'],
    logoutput   => true,
    refreshonly => true,
    subscribe   => Exec["${plugin_zabbix::params::db_name}-import"],
  }
}

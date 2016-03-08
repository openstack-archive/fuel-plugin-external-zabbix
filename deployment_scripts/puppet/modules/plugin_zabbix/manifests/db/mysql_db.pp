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
define plugin_zabbix::db::mysql_db (
  $user,
  $password,
  $charset     = 'utf8',
  $host        = 'localhost',
  $grant       = 'all',
  $sql         = '',
  $enforce_sql = false
) {

  include plugin_zabbix::params

  $db_options_file = '/root/.my.cnf'
  if $plugin_zabbix::params::db_is_external {
    # Mandatory because the MySQL Puppet module does not allow
    # passing --host=X
    $db_admin_user = $plugin_zabbix::params::db_admin_user
    $db_admin_pass = $plugin_zabbix::params::db_admin_password
    $db_host = $plugin_zabbix::params::db_ip
    $db_port = $plugin_zabbix::params::db_port
    $db_file_content = inline_template('[client]
user=\'<%= @db_admin_user %>\'
password=\'<%= @db_admin_pass %>\'
host=\'<%= @db_host %>\'
port=\'<%= @db_port %>\'
')

    exec { 'test_and_backup_db_options_file':
      path    => '/usr/bin:/usr/sbin:/bin',
      command => "mv ${db_options_file} ${db_options_file}.zbx",
      onlyif  => "test -e ${db_options_file}",
    }

    file { $db_options_file:
      ensure  => file,
      content => $db_file_content,
      # Mandatory so that Zabbix plugin does not overwrite
      # any potentially existing file/link
      require => Exec['test_and_backup_db_options_file'],
    }

    exec { 'remove_db_options_file':
      path    => '/usr/bin:/usr/sbin:/bin',
      command => "/bin/rm -f ${db_options_file}",
    }

    exec { 'restore_backup_db_options_file':
      path    => '/usr/bin:/usr/sbin:/bin',
      command => "mv ${db_options_file}.zbx ${db_options_file}",
      onlyif  => "test -e ${db_options_file}.zbx",
    }

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
    Database[$name] -> Exec['remove_db_options_file'] -> Exec['restore_backup_db_options_file']
  } else {
    $mysql_extras = ''

    file { $db_options_file:
      ensure => present,
    }
  }

  database { $name:
    ensure   => present,
    charset  => $charset,
    provider => 'mysql',
    require  => File[$db_options_file],
  }

  if ! $plugin_zabbix::params::db_is_external {
    database_user { "${user}@${host}":
      ensure        => present,
      password_hash => mysql_password($password),
      provider      => 'mysql',
      require       => Database[$name],
    }
    database_grant { "${user}@${host}/${name}":
      privileges => $grant,
      provider   => 'mysql',
      require    => Database_user["${user}@${host}"],
    }
    $next_require = Database_grant["${user}@${host}/${name}"]
  } else {
    $next_require = Database[$name]
  }

  $refresh = ! $enforce_sql
  $mysql_cmd = "/usr/bin/mysql${mysql_extras} ${name} < ${sql}"

  if $sql {
    exec{ "${name}-import":
      command     => $mysql_cmd,
      logoutput   => true,
      refreshonly => $refresh,
      require     => $next_require,
      subscribe   => Database[$name],
    }
  }

}


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
class plugin_zabbix::monitoring::mysql_mon {

  include plugin_zabbix::params

  if defined_in_state(Class['mysql::server']) {

    plugin_zabbix_template_link { "${plugin_zabbix::params::host_name} Template App MySQL":
      host => $plugin_zabbix::params::host_name,
      template => 'Template App MySQL',
      api => $plugin_zabbix::monitoring::api_hash,
    }

    plugin_zabbix::agent::userparameter {
      'mysql.status':
        key     => 'mysql.status[*]',
        command => 'echo "show global status where Variable_name=\'$1\';" | sudo mysql -N | awk \'{print $$2}\'';
      'mysql.size':
        key     => 'mysql.size[*]',
        command =>'echo "select sum($(case "$3" in both|"") echo "data_length+index_length";; data|index) echo "$3_length";; free) echo "data_free";; esac)) from information_schema.tables$([[ "$1" = "all" || ! "$1" ]] || echo " where table_schema=\'$1\'")$([[ "$2" = "all" || ! "$2" ]] || echo "and table_name=\'$2\'");" | sudo mysql -N';
      'mysql.ping':
        command => 'sudo mysqladmin ping | grep -c alive';
      'mysql.version':
        command => 'mysql -V';
    }

    file { "${::plugin_zabbix::params::agent_include}/userparameter_mysql.conf":
      ensure => absent,
    }

    file { '/var/lib/zabbix':
      ensure => directory,
    }

    file { '/var/lib/zabbix/.my.cnf':
      ensure  => present,
      content => template('plugin_zabbix/.my.cnf.erb'),
      require => File['/var/lib/zabbix'],
    }
  }
}

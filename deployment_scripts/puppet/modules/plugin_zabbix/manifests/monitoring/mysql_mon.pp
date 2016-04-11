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
      host     => $plugin_zabbix::params::host_name,
      template => 'Template App MySQL',
      api      => $plugin_zabbix::monitoring::api_hash,
    }

    plugin_zabbix::agent::userparameter {
      'mysql.status':
        key     => 'mysql.status[*]',
        command => join([
          'echo "show global status where Variable_name=\'$1\';"',
          ' | mysql --defaults-extra-file=/var/lib/zabbix/.my.cnf -N',
          ' | awk \'{print $$2}\''], '');
      'mysql.ping':
        command => 'mysqladmin --defaults-extra-file=/var/lib/zabbix/.my.cnf ping | grep -c alive';
      'mysql.version':
        command => 'mysql -V';
      'db.wsrep.status.query':
        command => '/etc/zabbix/scripts/query_db.py wsrep_status';
      'db.wsrep.ready.query':
        command => '/etc/zabbix/scripts/query_db.py wsrep_ready';
      'db.wsrep.connected.query':
        command => '/etc/zabbix/scripts/query_db.py wsrep_connected';
    }

    file { "${::plugin_zabbix::params::agent_include}/userparameter_mysql.conf":
      ensure => absent,
    }

    file { '/var/lib/zabbix':
      ensure => directory,
    }

    file { '/var/lib/zabbix/.my.cnf':
      ensure  => present,
      content => template('plugin_zabbix/my.cnf.erb'),
      require => File['/var/lib/zabbix'],
    }
  }
}

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
class plugin_zabbix::agent::scripts {

  include plugin_zabbix::params

  file { $plugin_zabbix::params::agent_scripts:
    ensure  => directory,
    recurse => true,
    purge   => true,
    force   => true,
    mode    => '0755',
    source  => 'puppet:///modules/plugin_zabbix/scripts',
  }

  file { '/etc/zabbix/check_api.conf':
    ensure  => present,
    content => template('plugin_zabbix/check_api.conf.erb'),
  }

  file { '/etc/zabbix/check_rabbit.conf':
    ensure  => present,
    content => template('plugin_zabbix/check_rabbit.conf.erb'),
  }

  file { '/etc/zabbix/check_db.conf':
    ensure  => present,
    content => template('plugin_zabbix/check_db.conf.erb'),
  }

  if ! defined(Package['sudo']) {
    package { 'sudo':
      ensure => installed
    }
  }

  file { 'zabbix_no_requiretty':
    path    => '/etc/sudoers.d/zabbix',
    mode    => '0440',
    owner   => root,
    group   => root,
    source  => 'puppet:///modules/plugin_zabbix/zabbix-sudo',
    require => Package['sudo'],
  }
}

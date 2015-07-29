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
class plugin_zabbix::primary_controller {

  include plugin_zabbix::controller

  class { 'plugin_zabbix::db':
    db_ip       => $plugin_zabbix::params::db_ip,
    db_password => $plugin_zabbix::params::db_password,
    require     => Package[$plugin_zabbix::params::server_pkg],
    before      => [ Class['plugin_zabbix::frontend'], Cs_resource["p_${plugin_zabbix::params::server_service}"] ],
  }

  cs_resource { "p_${plugin_zabbix::params::server_service}":
    primitive_class => 'ocf',
    provided_by     => $plugin_zabbix::params::ocf_scripts_provider,
    primitive_type  => $plugin_zabbix::params::server_service,
    operations      => {
      'monitor' => { 'interval' => '5s', 'timeout' => '30s' },
      'start'   => { 'interval' => '0', 'timeout' => '30s' }
    },
    metadata        => {
      'migration-threshold' => '3',
      'failure-timeout'     => '120',
    },
  }

  File[$plugin_zabbix::params::server_config] -> File['zabbix-server-ocf'] -> Cs_resource["p_${plugin_zabbix::params::server_service}"]
  Service["${plugin_zabbix::params::server_service}-init-stopped"] -> Cs_resource["p_${plugin_zabbix::params::server_service}"]
  Cs_resource["p_${plugin_zabbix::params::server_service}"] -> Service["${plugin_zabbix::params::server_service}-started"]

}

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
class plugin_zabbix(
  $server_ip          = undef,
  $db_ip              = undef,
  $primary_controller = false,
  $username           = 'admin',
  $password           = 'zabbix',
  $db_password        = 'zabbix',
) {
  include plugin_zabbix::params

  $ports = $plugin_zabbix::params::zabbix_ports

  $password_hash = md5($password)

  anchor { 'zabbix_server_start': } ->
  class { 'plugin_zabbix::server':
    db_ip              => $db_ip,
    primary_controller => $primary_controller,
    db_password        => $db_password,
  } ->
  anchor { 'zabbix_server_end': }

}

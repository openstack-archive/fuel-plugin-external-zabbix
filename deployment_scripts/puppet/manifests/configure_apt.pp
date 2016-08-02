# Copyright 2016 Mirantis, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.

notice('fuel-plugin-external-zabbix: configure_apt.pp')

$str = 'APT::Install-Suggests "0";
APT::Install-Recommends "0";
'

case $::osfamily {
    'Debian': {
        file { '/etc/apt/apt.conf.d/99norecommends':
            ensure  => file,
            content => $str,
        }
    }
    default: {
        # Currently only Debian like distributions need specific configuration.
    }
}

$fuel_version = 0 + hiera('fuel_version')
if $fuel_version < 8.0 {
  $cur_node_roles = node_roles(hiera_array('nodes'), hiera('uid'))
  $is_controller = member($cur_node_roles, 'controller') or
                    member($cur_node_roles, 'primary-controller')
} else {
  $is_controller = roles_include(['controller', 'primary-controller'])
}

if $is_controller {
  # The OCF script should exist before any node tries to configure the
  # Zabbix with Pacemaker. This is why it is shipped by this manifest.
  file { 'zabbix-server-ocf' :
    ensure => present,
    path   => '/usr/lib/ocf/resource.d/fuel/zabbix-server',
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
    source => 'puppet:///modules/plugin_zabbix/zabbix-server.ocf',
  }
}

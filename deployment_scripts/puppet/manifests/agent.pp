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
$network_metadata = hiera_hash('network_metadata')

$primary_controller_nodes = get_nodes_hash_by_roles($network_metadata, ['primary-controller'])
$controllers = get_nodes_hash_by_roles($network_metadata, ['primary-controller', 'controller'])
$controller_internal_addresses = get_node_to_ipaddr_map_by_network_role($controllers, 'management')
$controller_nodes = ipsort(values($controller_internal_addresses))

$hostinfo = $network_metadata['nodes'][$::hostname]
$netinfo = $hostinfo['network_roles']
$internal_address = $netinfo['management']
$public_address = $netinfo['ex']
$swift_address = $netinfo['storage']

class { 'plugin_zabbix::monitoring':
  server_ips => $controller_nodes,
  roles      => node_roles(hiera_array('nodes'), hiera('uid')),
}

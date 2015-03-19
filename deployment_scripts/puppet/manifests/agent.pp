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
$nodes_hash = hiera('nodes')

$primary_controller_nodes = filter_nodes($nodes_hash,'role','primary-controller')
$controllers = concat($primary_controller_nodes, filter_nodes($nodes_hash,'role','controller'))
$controller_internal_addresses = nodes_to_hash($controllers,'name','internal_address')
$controller_nodes = ipsort(values($controller_internal_addresses))

$node_data = filter_nodes($nodes_hash,'fqdn',$::fqdn)
$internal_address = join(values(nodes_to_hash($node_data,'name','internal_address')))
$public_address = join(values(nodes_to_hash($node_data,'name','public_address')))
$swift_address = join(values(nodes_to_hash($node_data,'name','storage_address')))

class { 'plugin_zabbix::monitoring':
  server_ips  => $controller_nodes,
}

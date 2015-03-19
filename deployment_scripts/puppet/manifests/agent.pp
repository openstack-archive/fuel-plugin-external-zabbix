$zabbix_hash = hiera('zabbix_monitoring')
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
  api_ip      => hiera('management_vip'),
  server_vip  => hiera('management_vip'),
  db_ip       => hiera('management_vip'),
  server_ips  => $controller_nodes,
  username    => $zabbix_hash['username'],
  password    => $zabbix_hash['password'],
  db_password => $zabbix_hash['db_password'],
}

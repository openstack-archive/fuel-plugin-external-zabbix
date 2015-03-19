$fuel_settings = parseyaml($astute_settings_yaml)
$zabbix_hash = $fuel_settings['zabbix_monitoring']
$nodes_hash = $fuel_settings['nodes']
$primary_controller_nodes = filter_nodes($nodes_hash,'role','primary-controller')
$controllers = concat($primary_controller_nodes, filter_nodes($nodes_hash,'role','controller'))
$controller_internal_addresses = nodes_to_hash($controllers,'name','internal_address')
$controller_nodes = ipsort(values($controller_internal_addresses))

prepare_network_config($::fuel_settings['network_scheme'])
$internal_address = get_network_role_property('management', 'ipaddr')
$public_address = get_network_role_property('ex', 'ipaddr')
$swift_address = get_network_role_property('storage', 'ipaddr')

$zabbix_ports = {
  api => '80',
  agent => '10049',
  backend_agent => '10050'
}

class { 'plugin_zabbix::monitoring':
  api_ip      => $fuel_settings['public_vip'],
  server_vip  => $fuel_settings['management_vip'],
  db_ip       => $fuel_settings['management_vip'],
  server_ips  => $controller_nodes,
  ports       => $zabbix_ports,
  username    => $zabbix_hash['username'],
  password    => $zabbix_hash['password'],
  db_password => $zabbix_hash['db_password'],
}

$fuel_settings = parseyaml($astute_settings_yaml)
$zabbix_hash = $fuel_settings['zabbix_monitoring']
$nodes_hash = $fuel_settings['nodes']
$primary_controller_nodes = filter_nodes($nodes_hash,'role','primary-controller')
$controllers = concat($primary_controller_nodes, filter_nodes($nodes_hash,'role','controller'))
$primary_controller = $fuel_settings['role'] ? { 'primary-controller'=>true, default=>false }

$zabbix_ports = {
  server         => '10051',
  backend_server => '10052',
  agent          => '10049',
  backend_agent  => '10050',
  api            => '80',
}

class { 'plugin_zabbix':
  api_ip              => $fuel_settings['public_vip'],
  server_ip           => $fuel_settings['management_vip'],
  ports               => $zabbix_ports,
  db_ip               => $fuel_settings['management_vip'],
  primary_controller  => $primary_controller,
  username            => $zabbix_hash['username'],
  password            => $zabbix_hash['password'],
  db_password         => $zabbix_hash['db_password'],
}

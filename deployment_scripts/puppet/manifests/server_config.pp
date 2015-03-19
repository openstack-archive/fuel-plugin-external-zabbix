$fuel_settings = parseyaml($astute_settings_yaml)
$zabbix_hash = $fuel_settings['zabbix_monitoring']
$nodes_hash = $fuel_settings['nodes']
$primary_controller_nodes = filter_nodes($nodes_hash,'role','primary-controller')
$controllers = concat($primary_controller_nodes, filter_nodes($nodes_hash,'role','controller'))
$primary_controller = $fuel_settings['role'] ? { 'primary-controller'=>true, default=>false }

$ports = {
  server         => '10051',
  backend_server => '10052',
  agent          => '10049',
  backend_agent  => '10050',
  api            => '80',
}

include plugin_zabbix::params

$api_ip = $fuel_settings['public_vip']

$api_url = "http://${api_ip}:${ports['api']}${plugin_zabbix::params::frontend_base}/api_jsonrpc.php"
$api_hash = { endpoint => $api_url,
              username => $zabbix_hash['username'],
              password => $zabbix_hash['password'] }

if ($::fuel_settings['deployment_mode'] == 'multinode') or
  ($::fuel_settings['role'] == 'primary-controller') {
  class { 'plugin_zabbix::server::config':
    api_hash => $api_hash,
  }
}


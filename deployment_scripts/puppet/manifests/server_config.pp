include plugin_zabbix::params

$zabbix_hash = hiera('zabbix_monitoring')
$api_ip = hiera('management_vip')
$api_url = "http://${api_ip}:${plugin_zabbix::params::zabbix_ports['api']}${plugin_zabbix::params::frontend_base}/api_jsonrpc.php"
$api_hash = {
  endpoint => $api_url,
  username => $zabbix_hash['username'],
  password => $zabbix_hash['password'],
}

class { 'plugin_zabbix::server::config':
  api_hash => $api_hash,
}

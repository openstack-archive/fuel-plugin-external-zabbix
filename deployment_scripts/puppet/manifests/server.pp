$zabbix_hash = hiera('zabbix_monitoring')
$nodes_hash = hiera('nodes')
$primary_controller_nodes = filter_nodes($nodes_hash,'role','primary-controller')
$controllers = concat($primary_controller_nodes, filter_nodes($nodes_hash,'role','controller'))
$primary_controller = hiera('role') ? { 'primary-controller'=>true, default=>false }

class { 'plugin_zabbix':
  server_ip          => hiera('management_vip'),
  db_ip              => hiera('management_vip'),
  primary_controller => $primary_controller,
  username           => $zabbix_hash['username'],
  password           => $zabbix_hash['password'],
  db_password        => $zabbix_hash['db_password'],
}

class plugin_zabbix(
  $api_ip,
  $server_ip,
  $db_ip,
  $ports = { server => '10051', backend_server => undef, agent => '10050', backend_agent => undef, api => '80' },
  $primary_controller = false,
  $username = 'admin',
  $password = 'zabbix',
  $db_password = 'zabbix',
) {
  include plugin_zabbix::params

  $password_hash = md5($password)

  anchor { 'zabbix_server_start': } ->
  class { 'plugin_zabbix::server':
    db_ip               => $db_ip,
    primary_controller  => $primary_controller,
    db_password         => $db_password,
  } ->
  anchor { 'zabbix_server_end': }

}

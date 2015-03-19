class plugin_zabbix(
  $server_ip          = undef,
  $db_ip              = undef,
  $primary_controller = false,
  $username           = 'admin',
  $password           = 'zabbix',
  $db_password        = 'zabbix',
) {
  include plugin_zabbix::params

  $ports = $plugin_zabbix::params::zabbix_ports

  $password_hash = md5($password)

  anchor { 'zabbix_server_start': } ->
  class { 'plugin_zabbix::server':
    db_ip              => $db_ip,
    primary_controller => $primary_controller,
    db_password        => $db_password,
  } ->
  anchor { 'zabbix_server_end': }

}

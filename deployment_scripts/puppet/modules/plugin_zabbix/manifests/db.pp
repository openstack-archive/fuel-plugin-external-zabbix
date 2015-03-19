class plugin_zabbix::db(
  $db_ip       = undef,
  $db_password = 'zabbix',
  $sync_db     = false
) {
  #stub for multiple possible db backends
  class { 'plugin_zabbix::db::mysql':
    db_ip       => $db_ip,
    db_password => $db_password,
    sync_db     => $sync_db,
  }
  anchor { 'zabbix_mysql_start': } -> Class['plugin_zabbix::db::mysql'] -> anchor { 'zabbix_mysql_end': }
}

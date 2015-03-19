class plugin_zabbix::db::mysql(
  $db_ip       = undef,
  $db_password = 'zabbix',
  $sync_db     = false,
) {

  include plugin_zabbix::params

  file { '/tmp/zabbix':
    ensure => directory,
    mode   => '0755',
  }

  file { '/tmp/zabbix/parts':
    ensure  => directory,
    purge   => true,
    force   => true,
    recurse => true,
    mode    => '0755',
    source  => 'puppet:///modules/plugin_zabbix/sql',
    require => File['/tmp/zabbix']
  }

  file { '/tmp/zabbix/parts/data_clean.sql':
    ensure    => present,
    require   => File['/tmp/zabbix/parts'],
    content   => template('plugin_zabbix/data_clean.erb'),
  }

  exec { 'prepare-schema-1':
    command => $plugin_zabbix::params::prepare_schema_cmd,
    creates => '/tmp/zabbix/schema.sql',
    path    => ['/usr/sbin', '/usr/bin', '/sbin', '/bin'],
    require => [File['/tmp/zabbix'], Package[$plugin_zabbix::params::server_pkg]],
    notify  => Exec['prepare-schema-2'],
  }

  exec { 'prepare-schema-2':
    command     => 'cat /tmp/zabbix/parts/*.sql >> /tmp/zabbix/schema.sql',
    path        => ['/usr/sbin', '/usr/bin', '/sbin', '/bin'],
    refreshonly => true,
    require     => File['/tmp/zabbix/parts/data_clean.sql'],
  }

  plugin_zabbix::db::mysql_db { $plugin_zabbix::params::db_name:
    user     => $plugin_zabbix::params::db_user,
    password => $db_password,
    host     => $db_ip,
    require  => Exec['prepare-schema-2'],
  }

  if $sync_db {
    exec{ "${plugin_zabbix::params::db_name}-import":
      command   => "/usr/bin/mysql ${plugin_zabbix::params::db_name} < /tmp/zabbix/schema.sql && touch /tmp/zabbix/imported",
      creates   => '/tmp/zabbix/imported',
      logoutput => true,
      require   => Database[$plugin_zabbix::params::db_name],
    }
  }
}

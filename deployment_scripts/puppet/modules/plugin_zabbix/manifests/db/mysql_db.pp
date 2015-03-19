define plugin_zabbix::db::mysql_db (
  $user,
  $password,
  $charset     = 'utf8',
  $host        = 'localhost',
  $grant       = 'all',
  $sql         = '',
  $enforce_sql = false
) {

  database { $name:
    ensure   => present,
    charset  => $charset,
    provider => 'mysql',
  }

  database_user { "${user}@${host}":
    ensure        => present,
    password_hash => mysql_password($password),
    provider      => 'mysql',
    require       => Database[$name],
  }

  database_grant { "${user}@${host}/${name}":
    privileges => $grant,
    provider   => 'mysql',
    require    => Database_user["${user}@${host}"],
  }

  $refresh = ! $enforce_sql

  if $sql {
    exec{ "${name}-import":
      command     => "/usr/bin/mysql ${name} < ${sql}",
      logoutput   => true,
      refreshonly => $refresh,
      require     => Database_grant["${user}@${host}/${name}"],
      subscribe   => Database[$name],
    }
  }

}


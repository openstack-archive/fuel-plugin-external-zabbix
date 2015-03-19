define plugin_zabbix::agent::userparameter (
  $ensure   = present,
  $command  = undef,
  $key      = undef,
  $index    = undef,
  $file     = undef,
  $template = 'plugin_zabbix/zabbix_agent_userparam.conf.erb'
) {

  include plugin_zabbix::params

  $key_real = $key ? {
    undef   => $name,
    default => $key
  }

  $index_real = $index ? {
    undef => '',
    default => "${index}_",
  }

  $file_real = $file ? {
    undef   => "${::plugin_zabbix::params::agent_include}/${index_real}${name}.conf",
    default => $file,
  }

  file { $file_real:
    ensure  => $ensure,
    content => template($template),
    notify  => Service[$plugin_zabbix::params::agent_service]
  }
}

class plugin_zabbix::server(
  $db_ip,
  $primary_controller = false,
  $db_password = 'zabbix',
  $ocf_scripts_dir = '/usr/lib/ocf/resource.d',
  $ocf_scripts_provider = 'mirantis',
) {

  include plugin_zabbix::params

  file { '/etc/dbconfig-common':
    ensure    => directory,
    owner     => 'root',
    group     => 'root',
    mode      => '0755',
  }

  file { '/etc/dbconfig-common/zabbix-server-mysql.conf':
    require   => File['/etc/dbconfig-common'],
    ensure    => present,
    mode      => '0600',
    source    => 'puppet:///modules/plugin_zabbix/zabbix-server-mysql.conf',
  }

  package { $plugin_zabbix::params::server_pkg:
    require   => File['/etc/dbconfig-common/zabbix-server-mysql.conf'],
    ensure    => present,
  }

  file { $plugin_zabbix::params::server_config:
    ensure    => present,
    require   => Package[$plugin_zabbix::params::server_pkg],
    content   => template($plugin_zabbix::params::server_config_template),
  }

  file { $plugin_zabbix::params::server_scripts:
    ensure    => directory,
    require   => Package[$plugin_zabbix::params::server_pkg],
    recurse   => true,
    purge     => true,
    force     => true,
    mode      => '0755',
    source    => 'puppet:///modules/plugin_zabbix/externalscripts',
  }

  class { 'plugin_zabbix::db':
    db_ip            => $db_ip,
    db_password      => $db_password,
    sync_db          => $primary_controller,
  }

  anchor { 'zabbix_db_start': } -> Class['plugin_zabbix::db'] -> File[$plugin_zabbix::params::server_config] -> anchor { 'zabbix_db_end': }

  if $::fuel_settings["deployment_mode"] == "multinode" {
    service { $plugin_zabbix::params::server_service:
      enable     => true,
      ensure     => running,
      require    => File[$plugin_zabbix::params::server_config],
      subscribe  => File[$plugin_zabbix::params::server_config],
    }

    File[$plugin_zabbix::params::server_config] -> Service[$plugin_zabbix::params::server_service]

  } else {
    if $::fuel_settings["role"] == "primary-controller" {
      cs_resource { "p_${plugin_zabbix::params::server_service}":
        primitive_class => 'ocf',
        provided_by     => $ocf_scripts_provider,
        primitive_type  => "${plugin_zabbix::params::server_service}",
        operations      => {
          'monitor' => { 'interval' => '5s', 'timeout' => '30s' },
          'start'   => { 'interval' => '0', 'timeout' => '30s' }
        },
        metadata => {
          'migration-threshold' => '3',
          'failure-timeout'     => '120',
        },
      }
      cs_colocation { 'vip_management-with-zabbix-server':
        ensure     => present,
        score      => 'INFINITY',
        primitives => [
            "vip__management",
            "p_${plugin_zabbix::params::server_service}"
        ],
      }

      File[$plugin_zabbix::params::server_config] -> File['zabbix-server-ocf'] -> Cs_resource["p_${plugin_zabbix::params::server_service}"]
      Cs_resource["p_${plugin_zabbix::params::server_service}"] -> Service["${plugin_zabbix::params::server_service}-started"]
      Cs_resource["p_${plugin_zabbix::params::server_service}"] -> Cs_colocation['vip_management-with-zabbix-server']

      service { "${plugin_zabbix::params::server_service}-started":
        name       => "p_${plugin_zabbix::params::server_service}",
        enable     => true,
        ensure     => running,
        provider   => 'pacemaker',
      }

      File[$plugin_zabbix::params::server_config] -> Service["${plugin_zabbix::params::server_service}-started"]
      Service["${plugin_zabbix::params::server_service}-init-stopped"] -> Service["${plugin_zabbix::params::server_service}-started"]
    }
     
    file { 'zabbix-server-ocf' :
      ensure  => present,
      path    => "${ocf_scripts_dir}/${ocf_scripts_provider}/${plugin_zabbix::params::server_service}",
      mode    => '0755',
      owner   => 'root',
      group   => 'root',
      source  => 'puppet:///modules/plugin_zabbix/zabbix-server.ocf',
    }
    service { "${plugin_zabbix::params::server_service}-init-stopped":
      name       => $plugin_zabbix::params::server_service,
      enable     => false,
      ensure     => 'stopped',
      require    => File[$plugin_zabbix::params::server_config],
    }

    File['zabbix-server-ocf'] -> Service["${plugin_zabbix::params::server_service}-init-stopped"]

  }

  cron { 'zabbix db_clean':
    ensure   => 'present',
    require  => File[$plugin_zabbix::params::server_scripts],
    command  => "${plugin_zabbix::params::server_scripts}/db_clean.sh",
    user     => 'root',
    minute   => '*/5',
  }

  if $plugin_zabbix::params::frontend {
    Anchor<| title == 'zabbix_db_end' |> -> Anchor<| title == 'zabbix_frontend_start' |>

    class { 'plugin_zabbix::frontend':
      require => Package[$plugin_zabbix::params::server_pkg],
    }

    anchor { 'zabbix_frontend_start': } -> Class['plugin_zabbix::frontend'] -> anchor { 'zabbix_frontend_end': }
  }

  if $::fuel_settings["deployment_mode"] != "multinode" {
    Anchor<| title == 'zabbix_frontend_end' |> -> Anchor<| title == 'zabbix_haproxy_start' |>

    class { 'plugin_zabbix::ha::haproxy': }

    anchor { 'zabbix_haproxy_start': } -> Class['plugin_zabbix::ha::haproxy'] -> anchor { 'zabbix_haproxy_end': }
  }

  firewall { '997 zabbix server':
    proto     => 'tcp',
    action    => 'accept',
    port      => $plugin_zabbix::ports['backend_server'] ? { unset=>$plugin_zabbix::ports['server'], default=>$plugin_zabbix::ports['backend_server'] },
  }

}

class plugin_zabbix::frontend {

  include plugin_zabbix::params

  service { $plugin_zabbix::params::frontend_service:
    ensure     => 'running',
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }

  package { $plugin_zabbix::params::frontend_pkg:
    ensure    => present,
  }

  file { $plugin_zabbix::params::frontend_config:
    ensure    => present,
    content   => template($plugin_zabbix::params::frontend_config_template),
    notify    => Service[$plugin_zabbix::params::frontend_service],
    require   => Package[$plugin_zabbix::params::frontend_pkg],
  }

  file_line { 'php timezone':
    path      => $plugin_zabbix::params::frontend_service_config,
    line      => '    php_value date.timezone UTC',
    match     => 'php_value date.timezone',
    notify    => Service[$plugin_zabbix::params::frontend_service],
    require   => Package[$plugin_zabbix::params::frontend_pkg],
  }

  # disable worker MPM, use prefork MPM which is required by mod_php:
  case $::osfamily {
    'RedHat': {
      file_line { 'httpd_mpm_prefork':
        path    => '/etc/sysconfig/httpd',
        line    => 'HTTPD=/usr/sbin/httpd',
        match   => '^HTTPD=/usr/sbin/httpd',
        notify  => Service[$plugin_zabbix::params::frontend_service],
        require => Package[$plugin_zabbix::params::frontend_pkg],
      }
    }
    'Debian': {
      file { '/etc/apache2/mods-enabled/worker.conf':
        ensure  => absent,
        notify  => Service[$plugin_zabbix::params::frontend_service],
        require => Package[$plugin_zabbix::params::frontend_pkg],
      }
      file { '/etc/apache2/mods-enabled/worker.load':
        ensure  => absent,
        notify  => Service[$plugin_zabbix::params::frontend_service],
        require => Package[$plugin_zabbix::params::frontend_pkg],
      }
    }
    default: {}
  }

  # postinst script in zabbix-frontend-php package creates an invalid symlink
  # hack: in debconf disable apache configuration and restarting
  #       and create the symlink manually then restart apache
  case $::osfamily {
    'Debian': {
      exec { 'configure zabbix-frontend-php package':
        command  => 'echo "zabbix-frontend-php zabbix-frontend-php/configure-apache boolean false\nzabbix-frontend-php zabbix-frontend-php/restart-webserver boolean false" | debconf-set-selections',
        provider => 'shell',
        before   => Package[$plugin_zabbix::params::frontend_pkg],
      }
      file { '/etc/apache2/conf.d/zabbix.conf':
        ensure   => link,
        target   => $plugin_zabbix::params::frontend_service_config,
        notify   => Service[$plugin_zabbix::params::frontend_service],
        require  => Package[$plugin_zabbix::params::frontend_pkg],
      }
    }
    default: {}
  }
}

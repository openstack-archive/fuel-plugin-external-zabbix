class plugin_zabbix::frontend {

  include plugin_zabbix::params

  service { $plugin_zabbix::params::frontend_service:
    ensure     => 'running',
    name       => $plugin_zabbix::params::frontend_service,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }

  package { $plugin_zabbix::params::frontend_pkg:
    ensure    => present,
    before    => [ File["$plugin_zabbix::params::frontend_config"], File["$plugin_zabbix::params::frontend_php_ini"] ],
  }

  file { $plugin_zabbix::params::frontend_config:
    ensure    => present,
    content   => template($plugin_zabbix::params::frontend_config_template),
    notify    => Service[$plugin_zabbix::params::frontend_service],
  }

  file { $plugin_zabbix::params::frontend_php_ini:
    ensure    => present,
    content   => template($plugin_zabbix::params::frontend_php_ini_template),
    notify    => Service[$plugin_zabbix::params::frontend_service],
  }

  if $::osfamily == 'RedHat' {
    file_line { 'httpd_mpm_prefork':
      path  => '/etc/sysconfig/httpd',
      line  => 'HTTPD=/usr/sbin/httpd',
      match => '^HTTPD=/usr/sbin/httpd',
      notify => Service[$plugin_zabbix::params::frontend_service],
      require => Package[$plugin_zabbix::params::frontend_pkg],
    }
  }
}

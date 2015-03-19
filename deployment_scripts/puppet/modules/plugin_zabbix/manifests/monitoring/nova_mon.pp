class plugin_zabbix::monitoring::nova_mon {

  include plugin_zabbix::params

  # Nova (controller)
  if defined_in_state(Class['openstack::controller']) {

    plugin_zabbix_template_link { "$plugin_zabbix::params::host_name Template App OpenStack Nova API":
      host => $plugin_zabbix::params::host_name,
      template => 'Template App OpenStack Nova API',
      api => $plugin_zabbix::monitoring::api_hash,
    }

    plugin_zabbix_template_link { "$plugin_zabbix::params::host_name Template App OpenStack Nova API OSAPI":
      host => $plugin_zabbix::params::host_name,
      template => 'Template App OpenStack Nova API OSAPI',
      api => $plugin_zabbix::monitoring::api_hash,
    }

    plugin_zabbix_template_link { "$plugin_zabbix::params::host_name Template App OpenStack Nova API OSAPI check":
      host    => $plugin_zabbix::params::host_name,
      template => 'Template App OpenStack Nova API OSAPI check',
      api => $plugin_zabbix::monitoring::api_hash,
    }

    plugin_zabbix_template_link { "$plugin_zabbix::params::host_name Template App OpenStack Nova API EC2":
      host => $plugin_zabbix::params::host_name,
      template => 'Template App OpenStack Nova API EC2',
      api => $plugin_zabbix::monitoring::api_hash,
    }

    plugin_zabbix_template_link { "$plugin_zabbix::params::host_name Template App OpenStack Nova Cert":
      host => $plugin_zabbix::params::host_name,
      template => 'Template App OpenStack Nova Cert',
      api => $plugin_zabbix::monitoring::api_hash,
    }

    plugin_zabbix::agent::userparameter {
      'nova.api.status':
        command => "/etc/zabbix/scripts/check_api.py nova_os http ${::internal_address} 8774";
    }

    if ! $::fuel_settings['quantum'] {
      plugin_zabbix_template_link { "$plugin_zabbix::params::host_name Template App OpenStack Nova Network":
        host => $plugin_zabbix::params::host_name,
        template => 'Template App OpenStack Nova Network',
        api => $plugin_zabbix::monitoring::api_hash,
      }
    }
  }

  #Nova (compute)
  if defined_in_state(Class['openstack::compute']) {

    if ! $::fuel_settings['quantum'] {
      plugin_zabbix_template_link { "$plugin_zabbix::params::host_name Template App OpenStack Nova API Metadata":
        host => $plugin_zabbix::params::host_name,
        template => 'Template App OpenStack Nova API Metadata',
        api => $plugin_zabbix::monitoring::api_hash,
      }
    }
  }

  if defined_in_state(Class['nova::consoleauth']) {
    plugin_zabbix_template_link { "$plugin_zabbix::params::host_name Template App OpenStack Nova ConsoleAuth":
      host => $plugin_zabbix::params::host_name,
      template => 'Template App OpenStack Nova ConsoleAuth',
      api => $plugin_zabbix::monitoring::api_hash,
    }
  }

  if defined_in_state(Class['nova::scheduler']) {
    plugin_zabbix_template_link { "$plugin_zabbix::params::host_name Template App OpenStack Nova Scheduler":
      host => $plugin_zabbix::params::host_name,
      template => 'Template App OpenStack Nova Scheduler',
      api => $plugin_zabbix::monitoring::api_hash,
    }
  }

  #Nova compute
  if defined_in_state(Class['nova::compute']) {
    plugin_zabbix_template_link { "$plugin_zabbix::params::host_name Template App OpenStack Nova Compute":
      host => $plugin_zabbix::params::host_name,
      template => 'Template App OpenStack Nova Compute',
      api => $plugin_zabbix::monitoring::api_hash,
    }
  }

  #Libvirt
  if defined_in_state(Class['nova::compute::libvirt']) {
    plugin_zabbix_template_link { "$::fqdn Template App OpenStack Libvirt":
      host => $::fqdn,
      template => 'Template App OpenStack Libvirt',
      api => $plugin_zabbix::monitoring::api_hash,
    }
  }
}

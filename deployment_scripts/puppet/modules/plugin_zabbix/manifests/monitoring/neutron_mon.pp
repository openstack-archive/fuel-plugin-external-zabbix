class plugin_zabbix::monitoring::neutron_mon {

  include plugin_zabbix::params

  # Neutron server
  if defined_in_state(Class['::neutron']) and !defined_in_state(Class['openstack::compute']) {

    plugin_zabbix_template_link { "${plugin_zabbix::params::host_name} Template App OpenStack Neutron Server":
      host => $plugin_zabbix::params::host_name,
      template => 'Template App OpenStack Neutron Server',
      api => $plugin_zabbix::monitoring::api_hash,
    }

    plugin_zabbix_template_link { "${plugin_zabbix::params::host_name} Template App OpenStack Neutron API check":
      host    => $plugin_zabbix::params::host_name,
      template => 'Template App OpenStack Neutron API check',
      api => $plugin_zabbix::monitoring::api_hash,
    }

    plugin_zabbix::agent::userparameter {
      'neutron.api.status':
        command => "/etc/zabbix/scripts/check_api.py neutron http ${::internal_address} 9696";
    }
  }

  # Neutron OVS agent
  if defined_in_state(Class['::neutron::agents::ovs']) {
    plugin_zabbix_template_link { "${plugin_zabbix::params::host_name} Template App OpenStack Neutron OVS Agent":
      host => $plugin_zabbix::params::host_name,
      template => 'Template App OpenStack Neutron OVS Agent',
      api => $plugin_zabbix::monitoring::api_hash,
    }
  }

  # Neutron Metadata agent
  if defined_in_state(Class['::neutron::agents::metadata']) {
    plugin_zabbix_template_link { "${plugin_zabbix::params::host_name} Template App OpenStack Neutron Metadata Agent":
      host => $plugin_zabbix::params::host_name,
      template => 'Template App OpenStack Neutron Metadata Agent',
      api => $plugin_zabbix::monitoring::api_hash,
    }
  }

  # Neutron L3 agent
  if defined_in_state(Class['::neutron::agents::l3']) {
    plugin_zabbix_template_link { "${plugin_zabbix::params::host_name} Template App OpenStack Neutron L3 Agent":
      host => $plugin_zabbix::params::host_name,
      template => 'Template App OpenStack Neutron L3 Agent',
      api => $plugin_zabbix::monitoring::api_hash,
    }
  }

  # Neutron DHCP agent
  if defined_in_state(Class['::neutron::agents::dhcp']) {
    plugin_zabbix_template_link { "${plugin_zabbix::params::host_name} Template App OpenStack Neutron DHCP Agent":
      host => $plugin_zabbix::params::host_name,
      template => 'Template App OpenStack Neutron DHCP Agent',
      api => $plugin_zabbix::monitoring::api_hash,
    }
  }
}

class plugin_zabbix::server::config(
  $api_hash = undef,
) {

  include plugin_zabbix::params

  plugin_zabbix_hostgroup { $plugin_zabbix::params::host_groups:
    ensure   => present,
    api      => $api_hash,
  }

  file { '/etc/zabbix/import':
    ensure   => directory,
    recurse  => true,
    purge    => true,
    force    => true,
    source   => 'puppet:///modules/plugin_zabbix/import'
  }

  Plugin_zabbix_configuration_import {
    require  => File['/etc/zabbix/import'],
  }

  plugin_zabbix_configuration_import { 'Template_App_Zabbix_Agent.xml Import':
    ensure   => present,
    xml_file => '/etc/zabbix/import/Template_App_Zabbix_Agent.xml',
    api      => $api_hash,
  }

  plugin_zabbix_configuration_import { 'Template_Fuel_OS_Linux.xml Import':
    ensure   => present,
    xml_file => '/etc/zabbix/import/Template_Fuel_OS_Linux.xml',
    api      => $api_hash,
  }

  # Nova templates
  plugin_zabbix_configuration_import { 'Template_App_OpenStack_Nova_API_EC2.xml Import':
    ensure   => present,
    xml_file => '/etc/zabbix/import/Template_App_OpenStack_Nova_API_EC2.xml',
    api      => $api_hash,
  }
  plugin_zabbix_configuration_import { 'Template_App_OpenStack_Nova_API.xml Import':
    ensure   => present,
    xml_file => '/etc/zabbix/import/Template_App_OpenStack_Nova_API.xml',
    api      => $api_hash,
  }
  plugin_zabbix_configuration_import { 'Template_App_OpenStack_Nova_API_Metadata.xml Import':
    ensure   => present,
    xml_file => '/etc/zabbix/import/Template_App_OpenStack_Nova_API_Metadata.xml',
    api      => $api_hash,
  }
  plugin_zabbix_configuration_import { 'Template_App_OpenStack_Nova_API_OSAPI.xml Import':
    ensure   => present,
    xml_file => '/etc/zabbix/import/Template_App_OpenStack_Nova_API_OSAPI.xml',
    api      => $api_hash,
  }
  plugin_zabbix_configuration_import { 'Template_App_OpenStack_Nova_API_OSAPI_check.xml Import':
    ensure   => present,
    xml_file => '/etc/zabbix/import/Template_App_OpenStack_Nova_API_OSAPI_check.xml',
    api      => $api_hash,
  }
  plugin_zabbix_configuration_import { 'Template_App_OpenStack_Nova_Cert.xml Import':
    ensure   => present,
    xml_file => '/etc/zabbix/import/Template_App_OpenStack_Nova_Cert.xml',
    api      => $api_hash,
  }
  plugin_zabbix_configuration_import { 'Template_App_OpenStack_Nova_ConsoleAuth.xml Import':
    ensure   => present,
    xml_file => '/etc/zabbix/import/Template_App_OpenStack_Nova_ConsoleAuth.xml',
    api      => $api_hash,
  }
  plugin_zabbix_configuration_import { 'Template_App_OpenStack_Nova_Scheduler.xml Import':
    ensure   => present,
    xml_file => '/etc/zabbix/import/Template_App_OpenStack_Nova_Scheduler.xml',
    api      => $api_hash,
  }
  plugin_zabbix_configuration_import { 'Template_App_OpenStack_Nova_Compute.xml Import':
    ensure   => present,
    xml_file => '/etc/zabbix/import/Template_App_OpenStack_Nova_Compute.xml',
    api      => $api_hash,
  }
  plugin_zabbix_configuration_import { 'Template_App_OpenStack_Libvirt.xml Import':
    ensure   => present,
    xml_file => '/etc/zabbix/import/Template_App_OpenStack_Libvirt.xml',
    api      => $api_hash,
  }
  plugin_zabbix_configuration_import { 'Template_App_OpenStack_Nova_Network.xml Import':
    ensure   => present,
    xml_file => '/etc/zabbix/import/Template_App_OpenStack_Nova_Network.xml',
    api      => $api_hash,
  }

  # Keystone templates
  plugin_zabbix_configuration_import { 'Template_App_OpenStack_Keystone.xml Import':
    ensure   => present,
    xml_file => '/etc/zabbix/import/Template_App_OpenStack_Keystone.xml',
    api      => $api_hash,
  }
  plugin_zabbix_configuration_import { 'Template_App_OpenStack_Keystone_API_check.xml Import':
    ensure   => present,
    xml_file => '/etc/zabbix/import/Template_App_OpenStack_Keystone_API_check.xml',
    api      => $api_hash,
  }

  # Glance templates
  plugin_zabbix_configuration_import { 'Template_App_OpenStack_Glance_API.xml Import':
    ensure   => present,
    xml_file => '/etc/zabbix/import/Template_App_OpenStack_Glance_API.xml',
    api      => $api_hash,
  }
  plugin_zabbix_configuration_import { 'Template_App_OpenStack_Glance_API_check.xml Import':
    ensure   => present,
    xml_file => '/etc/zabbix/import/Template_App_OpenStack_Glance_API_check.xml',
    api      => $api_hash,
  }
  plugin_zabbix_configuration_import { 'Template_App_OpenStack_Glance_Registry.xml Import':
    ensure   => present,
    xml_file => '/etc/zabbix/import/Template_App_OpenStack_Glance_Registry.xml',
    api      => $api_hash,
  }

  # Cinder templates
  plugin_zabbix_configuration_import { 'Template_App_OpenStack_Cinder_API.xml Import':
    ensure   => present,
    xml_file => '/etc/zabbix/import/Template_App_OpenStack_Cinder_API.xml',
    api      => $api_hash,
  }
  plugin_zabbix_configuration_import { 'Template_App_OpenStack_Cinder_API_check.xml Import':
    ensure   => present,
    xml_file => '/etc/zabbix/import/Template_App_OpenStack_Cinder_API_check.xml',
    api      => $api_hash,
  }
  plugin_zabbix_configuration_import { 'Template_App_OpenStack_Cinder_Scheduler.xml Import':
    ensure   => present,
    xml_file => '/etc/zabbix/import/Template_App_OpenStack_Cinder_Scheduler.xml',
    api      => $api_hash,
  }
  plugin_zabbix_configuration_import { 'Template_App_OpenStack_Cinder_Volume.xml Import':
    ensure   => present,
    xml_file => '/etc/zabbix/import/Template_App_OpenStack_Cinder_Volume.xml',
    api      => $api_hash,
  }

  # Swift templates
  plugin_zabbix_configuration_import { 'Template_App_OpenStack_Swift_Account.xml Import':
    ensure   => present,
    xml_file => '/etc/zabbix/import/Template_App_OpenStack_Swift_Account.xml',
    api      => $api_hash,
  }
  plugin_zabbix_configuration_import { 'Template_App_OpenStack_Swift_Container.xml Import':
    ensure   => present,
    xml_file => '/etc/zabbix/import/Template_App_OpenStack_Swift_Container.xml',
    api      => $api_hash,
  }
  plugin_zabbix_configuration_import { 'Template_App_OpenStack_Swift_Object.xml Import':
    ensure   => present,
    xml_file => '/etc/zabbix/import/Template_App_OpenStack_Swift_Object.xml',
    api      => $api_hash,
  }
  plugin_zabbix_configuration_import { 'Template_App_OpenStack_Swift_Proxy.xml Import':
    ensure   => present,
    xml_file => '/etc/zabbix/import/Template_App_OpenStack_Swift_Proxy.xml',
    api      => $api_hash,
  }

  # RabbitMQ template
  plugin_zabbix_configuration_import { 'Template_App_OpenStack_RabbitMQ_ha.xml Import':
    ensure   => present,
    xml_file => '/etc/zabbix/import/Template_App_OpenStack_RabbitMQ_ha.xml',
    api      => $api_hash,
  }

  # Horizon
  plugin_zabbix_configuration_import { 'Template_App_OpenStack_Horizon.xml Import':
    ensure   => present,
    xml_file => '/etc/zabbix/import/Template_App_OpenStack_Horizon.xml',
    api      => $api_hash,
  }

  # MySQL
  plugin_zabbix_configuration_import { 'Template_App_MySQL.xml Import':
    ensure   => present,
    xml_file => '/etc/zabbix/import/Template_App_MySQL.xml',
    api      => $api_hash,
  }

  # memcached
  plugin_zabbix_configuration_import { 'Template_App_Memcache.xml Import':
    ensure   => present,
    xml_file => '/etc/zabbix/import/Template_App_Memcache.xml',
    api      => $api_hash,
  }

  # HAProxy
  plugin_zabbix_configuration_import { 'Template_App_HAProxy.xml Import':
    ensure   => present,
    xml_file => '/etc/zabbix/import/Template_App_HAProxy.xml',
    api      => $api_hash,
  }

  # Zabbix server
  plugin_zabbix_configuration_import { 'Template_App_Zabbix_Server.xml Import':
    ensure   => present,
    xml_file => '/etc/zabbix/import/Template_App_Zabbix_Server.xml',
    api      => $api_hash,
  }

  # Virtual OpenStack Cluster
  plugin_zabbix_configuration_import { 'Template_OpenStack_Cluster.xml Import':
    ensure   => present,
    xml_file => '/etc/zabbix/import/Template_OpenStack_Cluster.xml',
    api      => $api_hash,
  }

  # Neutron
  plugin_zabbix_configuration_import { 'Template_App_OpenStack_Neutron_Server.xml Import':
    ensure   => present,
    xml_file => '/etc/zabbix/import/Template_App_OpenStack_Neutron_Server.xml',
    api      => $api_hash,
  }
  plugin_zabbix_configuration_import { 'Template_App_OpenStack_Neutron_OVS_Agent.xml Import':
    ensure   => present,
    xml_file => '/etc/zabbix/import/Template_App_OpenStack_Neutron_OVS_Agent.xml',
    api      => $api_hash,
  }
  plugin_zabbix_configuration_import { 'Template_App_OpenStack_Neutron_Metadata_Agent.xml Import':
    ensure   => present,
    xml_file => '/etc/zabbix/import/Template_App_OpenStack_Neutron_Metadata_Agent.xml',
    api      => $api_hash,
  }
  plugin_zabbix_configuration_import { 'Template_App_OpenStack_Neutron_L3_Agent.xml Import':
    ensure   => present,
    xml_file => '/etc/zabbix/import/Template_App_OpenStack_Neutron_L3_Agent.xml',
    api      => $api_hash,
  }
  plugin_zabbix_configuration_import { 'Template_App_OpenStack_Neutron_DHCP_Agent.xml Import':
    ensure   => present,
    xml_file => '/etc/zabbix/import/Template_App_OpenStack_Neutron_DHCP_Agent.xml',
    api      => $api_hash,
  }
  plugin_zabbix_configuration_import { 'Template_App_OpenStack_Neutron_API_check.xml Import':
    ensure   => present,
    xml_file => '/etc/zabbix/import/Template_App_OpenStack_Neutron_API_check.xml',
    api      => $api_hash,
  }

  # Open vSwitch
  plugin_zabbix_configuration_import { 'Template_App_OpenStack_Open_vSwitch.xml Import':
    ensure   => present,
    xml_file => '/etc/zabbix/import/Template_App_OpenStack_Open_vSwitch.xml',
    api      => $api_hash,
  }

  # Ceilometer
  plugin_zabbix_configuration_import { 'Template_App_OpenStack_Ceilometer.xml Import':
    ensure   => present,
    xml_file => '/etc/zabbix/import/Template_App_OpenStack_Ceilometer.xml',
    api      => $api_hash,
  }
  plugin_zabbix_configuration_import { 'Template_App_OpenStack_Ceilometer_Compute.xml Import':
    ensure   => present,
    xml_file => '/etc/zabbix/import/Template_App_OpenStack_Ceilometer_Compute.xml',
    api      => $api_hash,
  }
}

#    Copyright 2015 Mirantis, Inc.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.
#
class plugin_zabbix::server::config {

  include plugin_zabbix::params

  $settings = hiera(storage)
  $use_ceph = $settings['volumes_ceph']

  $api_hash = $plugin_zabbix::params::api_hash

  plugin_zabbix_hostgroup { $plugin_zabbix::params::host_groups:
    ensure => present,
    api    => $api_hash,
  }

  file { '/etc/zabbix/import':
    ensure  => directory,
    recurse => true,
    purge   => true,
    force   => true,
    source  => 'puppet:///modules/plugin_zabbix/import'
  }

  file { '/etc/zabbix/import/Template_App_MySQL.xml':
    ensure  => present,
    require => File['/etc/zabbix/import'],
    content => template('plugin_zabbix/Template_App_MySQL.xml.erb'),
  }

  file { '/etc/zabbix/import/Template_App_OpenStack_Ceph_Cluster.xml':
    ensure  => present,
    require => File['/etc/zabbix/import'],
    content => template('plugin_zabbix/Template_App_OpenStack_Ceph_Cluster.xml.erb'),
  }

  Plugin_zabbix_configuration_import {
    require => File['/etc/zabbix/import'],
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

  plugin_zabbix_configuration_import { 'Template_NTP_binding Import':
    ensure   => present,
    xml_file => '/etc/zabbix/import/Template_NTP_binding.xml',
    api      => $api_hash,
  }

  plugin_zabbix_configuration_import { 'Template_OS_Controller Import':
    ensure   => present,
    xml_file => '/etc/zabbix/import/Template_OS_Controller.xml',
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
  plugin_zabbix_configuration_import { 'Template_App_OpenStack_Nova_Conductor.xml Import':
    ensure   => present,
    xml_file => '/etc/zabbix/import/Template_App_OpenStack_Nova_Conductor.xml',
    api      => $api_hash,
  }
  plugin_zabbix_configuration_import { 'Template_App_OpenStack_Nova_NoVNCProxy.xml Import':
    ensure   => present,
    xml_file => '/etc/zabbix/import/Template_App_OpenStack_Nova_NoVNCProxy.xml',
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

  if $use_ceph {
    # Ceph templates
    plugin_zabbix_configuration_import { 'Template_App_OpenStack_Ceph.xml Import':
      ensure   => present,
      xml_file => '/etc/zabbix/import/Template_App_OpenStack_Ceph.xml',
      api      => $api_hash,
    }

    plugin_zabbix_configuration_import { 'Template_App_OpenStack_Ceph_OSD.xml Import':
      ensure   => present,
      xml_file => '/etc/zabbix/import/Template_App_OpenStack_Ceph_OSD.xml',
      api      => $api_hash,
    }

    plugin_zabbix_configuration_import { 'Template_App_OpenStack_Ceph_MON.xml Import':
      ensure   => present,
      xml_file => '/etc/zabbix/import/Template_App_OpenStack_Ceph_MON.xml',
      api      => $api_hash,
    }

    # Virtual Ceph Cluser
    plugin_zabbix_configuration_import { 'Template_App_OpenStack_Ceph_Cluster.xml Import':
      ensure   => present,
      xml_file => '/etc/zabbix/import/Template_App_OpenStack_Ceph_Cluster.xml',
      api      => $api_hash,
    }
    ->
    plugin_zabbix_host { $plugin_zabbix::params::openstack::ceph_virtual_cluster_name:
      host   => $plugin_zabbix::params::openstack::ceph_virtual_cluster_name,
      ip     => $plugin_zabbix::params::server_ip,
      port   => $plugin_zabbix::params::zabbix_ports['agent'],
      groups => concat($plugin_zabbix::params::host_groups_ceph_cluster, $plugin_zabbix::params::host_groups_base),
      api    => $plugin_zabbix::params::api_hash,
    }
    ->
    plugin_zabbix_template_link { "${plugin_zabbix::params::openstack::ceph_virtual_cluster_name} Template Ceph Cluster":
      host     => $plugin_zabbix::params::openstack::ceph_virtual_cluster_name,
      template => 'Template App OpenStack Ceph Cluster',
      api      => $plugin_zabbix::params::api_hash,
    }
    ->
    plugin_zabbix_configuration_import { 'Screens_Ceph_Cluster.xml Import':
      ensure   => present,
      xml_file => '/etc/zabbix/import/Screens_Ceph_Cluster.xml',
      api      => $plugin_zabbix::params::api_hash,
    }
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

  # Firewall
  plugin_zabbix_configuration_import { 'Template_App_Iptables_Stats.xml Import':
    ensure   => present,
    xml_file => '/etc/zabbix/import/Template_App_Iptables_Stats.xml',
    api      => $api_hash,
  }

  # Virtual OpenStack Cluster
  plugin_zabbix_configuration_import { 'Template_OpenStack_Cluster.xml Import':
    ensure   => present,
    xml_file => '/etc/zabbix/import/Template_OpenStack_Cluster.xml',
    api      => $api_hash,
  }
  ->
  plugin_zabbix_host { $plugin_zabbix::params::openstack::virtual_cluster_name:
    host   => $plugin_zabbix::params::openstack::virtual_cluster_name,
    ip     => $plugin_zabbix::params::server_ip,
    port   => $plugin_zabbix::params::zabbix_ports['agent'],
    groups => $plugin_zabbix::params::host_groups_base,
    api    => $plugin_zabbix::params::api_hash,
  }
  ->
  plugin_zabbix_template_link { "${plugin_zabbix::params::openstack::virtual_cluster_name} Template OpenStack Cluster":
    host     => $plugin_zabbix::params::openstack::virtual_cluster_name,
    template => 'Template OpenStack Cluster',
    api      => $plugin_zabbix::params::api_hash,
  }
  ->
  plugin_zabbix_configuration_import { 'Template_Screens_OpenStack_Cluster.xml Import':
    ensure   => present,
    xml_file => '/etc/zabbix/import/Screens_OpenStack_Cluster.xml',
    api      => $plugin_zabbix::params::api_hash,
  }

  Plugin_zabbix_hostgroup<||> -> Plugin_zabbix_host <||>

}

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

  $base_dir = '/etc/zabbix/import'
  $settings = hiera(storage)
  $use_ceph = $settings['volumes_ceph']

  $api_hash = $plugin_zabbix::params::api_hash

  plugin_zabbix_hostgroup { $plugin_zabbix::params::host_groups:
    ensure => present,
    api    => $api_hash,
  }

  file { $base_dir:
    ensure  => directory,
    recurse => true,
    purge   => true,
    force   => true,
    source  => 'puppet:///modules/plugin_zabbix/import'
  }

  Plugin_zabbix_configuration_import {
    require => File[$base_dir],
  }

  xmltemplate { 'Template_App_Zabbix_Agent':
    base_dir => $base_dir,
    api      => $api_hash,
  }

  xmltemplate { 'Template_Fuel_OS_Linux':
    base_dir => $base_dir,
    api      => $api_hash,
  }

  xmltemplate { 'Template_NTP_binding':
    base_dir => $base_dir,
    api      => $api_hash,
  }

  xmltemplate { 'Template_OS_Controller':
    base_dir => $base_dir,
    api      => $api_hash,
  }

  # Nova templates
  xmltemplate { 'Template_App_OpenStack_Nova_API_EC2':
    base_dir => $base_dir,
    api      => $api_hash,
  }
  xmltemplate { 'Template_App_OpenStack_Nova_API':
    base_dir => $base_dir,
    api      => $api_hash,
  }
  xmltemplate { 'Template_App_OpenStack_Nova_API_Metadata':
    base_dir => $base_dir,
    api      => $api_hash,
  }
  xmltemplate { 'Template_App_OpenStack_Nova_API_OSAPI':
    base_dir => $base_dir,
    api      => $api_hash,
  }
  xmltemplate { 'Template_App_OpenStack_Nova_API_OSAPI_check':
    base_dir => $base_dir,
    api      => $api_hash,
  }
  xmltemplate { 'Template_App_OpenStack_Nova_Cert':
    base_dir => $base_dir,
    api      => $api_hash,
  }
  xmltemplate { 'Template_App_OpenStack_Nova_ConsoleAuth':
    base_dir => $base_dir,
    api      => $api_hash,
  }
  xmltemplate { 'Template_App_OpenStack_Nova_Scheduler':
    base_dir => $base_dir,
    api      => $api_hash,
  }
  xmltemplate { 'Template_App_OpenStack_Nova_Conductor':
    base_dir => $base_dir,
    api      => $api_hash,
  }
  xmltemplate { 'Template_App_OpenStack_Nova_NoVNCProxy':
    base_dir => $base_dir,
    api      => $api_hash,
  }
  xmltemplate { 'Template_App_OpenStack_Nova_Compute':
    base_dir => $base_dir,
    api      => $api_hash,
  }
  xmltemplate { 'Template_App_OpenStack_Libvirt':
    base_dir => $base_dir,
    api      => $api_hash,
  }
  xmltemplate { 'Template_App_OpenStack_Nova_Network':
    base_dir => $base_dir,
    api      => $api_hash,
  }

  # Keystone templates
  xmltemplate { 'Template_App_OpenStack_Keystone':
    base_dir => $base_dir,
    api      => $api_hash,
  }
  xmltemplate { 'Template_App_OpenStack_Keystone_API_check':
    base_dir => $base_dir,
    api      => $api_hash,
  }

  # Glance templates
  xmltemplate { 'Template_App_OpenStack_Glance_API':
    base_dir => $base_dir,
    api      => $api_hash,
  }
  xmltemplate { 'Template_App_OpenStack_Glance_API_check':
    base_dir => $base_dir,
    api      => $api_hash,
  }
  xmltemplate { 'Template_App_OpenStack_Glance_Registry':
    base_dir => $base_dir,
    api      => $api_hash,
  }

  # Cinder templates
  xmltemplate { 'Template_App_OpenStack_Cinder_API':
    base_dir => $base_dir,
    api      => $api_hash,
  }
  xmltemplate { 'Template_App_OpenStack_Cinder_API_check':
    base_dir => $base_dir,
    api      => $api_hash,
  }
  xmltemplate { 'Template_App_OpenStack_Cinder_Scheduler':
    base_dir => $base_dir,
    api      => $api_hash,
  }
  xmltemplate { 'Template_App_OpenStack_Cinder_Volume':
    base_dir => $base_dir,
    api      => $api_hash,
  }

  # Swift templates
  xmltemplate { 'Template_App_OpenStack_Swift_Account':
    base_dir => $base_dir,
    api      => $api_hash,
  }
  xmltemplate { 'Template_App_OpenStack_Swift_Container':
    base_dir => $base_dir,
    api      => $api_hash,
  }
  xmltemplate { 'Template_App_OpenStack_Swift_Object':
    base_dir => $base_dir,
    api      => $api_hash,
  }
  xmltemplate { 'Template_App_OpenStack_Swift_Proxy':
    base_dir => $base_dir,
    api      => $api_hash,
  }

  if $use_ceph {
    # Ceph templates
    xmltemplate { 'Template_App_OpenStack_Ceph':
      base_dir => $base_dir,
      api      => $api_hash,
    }

    xmltemplate { 'Template_App_OpenStack_Ceph_OSD':
      base_dir => $base_dir,
      api      => $api_hash,
    }

    xmltemplate { 'Template_App_OpenStack_Ceph_MON':
      base_dir => $base_dir,
      api      => $api_hash,
    }

    # Virtual Ceph Cluser
    xmltemplate { 'Template_App_OpenStack_Ceph_Cluster':
      base_dir => $base_dir,
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
  xmltemplate { 'Template_App_OpenStack_RabbitMQ_ha':
    base_dir => $base_dir,
    api      => $api_hash,
  }

  # Horizon
  xmltemplate { 'Template_App_OpenStack_Horizon':
    base_dir => $base_dir,
    api      => $api_hash,
  }

  # MySQL
  xmltemplate { 'Template_App_MySQL':
    base_dir => $base_dir,
    api      => $api_hash,
  }

  # memcached
  xmltemplate { 'Template_App_Memcache':
    base_dir => $base_dir,
    api      => $api_hash,
  }

  # HAProxy
  xmltemplate { 'Template_App_HAProxy':
    base_dir => $base_dir,
    api      => $api_hash,
  }

  # Zabbix server
  xmltemplate { 'Template_App_Zabbix_Server':
    base_dir => $base_dir,
    api      => $api_hash,
  }

  # Neutron
  xmltemplate { 'Template_App_OpenStack_Neutron_Server':
    base_dir => $base_dir,
    api      => $api_hash,
  }
  xmltemplate { 'Template_App_OpenStack_Neutron_OVS_Agent':
    base_dir => $base_dir,
    api      => $api_hash,
  }
  xmltemplate { 'Template_App_OpenStack_Neutron_Metadata_Agent':
    base_dir => $base_dir,
    api      => $api_hash,
  }
  xmltemplate { 'Template_App_OpenStack_Neutron_L3_Agent':
    base_dir => $base_dir,
    api      => $api_hash,
  }
  xmltemplate { 'Template_App_OpenStack_Neutron_DHCP_Agent':
    base_dir => $base_dir,
    api      => $api_hash,
  }
  xmltemplate { 'Template_App_OpenStack_Neutron_API_check':
    base_dir => $base_dir,
    api      => $api_hash,
  }

  # Open vSwitch
  xmltemplate { 'Template_App_OpenStack_Open_vSwitch':
    base_dir => $base_dir,
    api      => $api_hash,
  }

  # Ceilometer
  xmltemplate { 'Template_App_OpenStack_Ceilometer':
    base_dir => $base_dir,
    api      => $api_hash,
  }
  xmltemplate { 'Template_App_OpenStack_Ceilometer_Compute':
    base_dir => $base_dir,
    api      => $api_hash,
  }

  # Firewall
  xmltemplate { 'Template_App_Iptables_Stats':
    base_dir => $base_dir,
    api      => $api_hash,
  }

  # Virtual OpenStack Cluster
  xmltemplate { 'Template_OpenStack_Cluster':
    base_dir => $base_dir,
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

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

  $base_dir = $plugin_zabbix::params::zabbix_import_dir
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
  }

  xmltemplate { 'Template_Fuel_OS_Linux':
  }

  xmltemplate { 'Template_NTP_binding':
  }

  xmltemplate { 'Template_OS_Controller':
  }

  # Nova templates
  xmltemplate { 'Template_App_OpenStack_Nova_API_EC2':
  }
  xmltemplate { 'Template_App_OpenStack_Nova_API':
  }
  xmltemplate { 'Template_App_OpenStack_Nova_API_Metadata':
  }
  xmltemplate { 'Template_App_OpenStack_Nova_API_OSAPI':
  }
  xmltemplate { 'Template_App_OpenStack_Nova_API_OSAPI_check':
  }
  xmltemplate { 'Template_App_OpenStack_Nova_Cert':
  }
  xmltemplate { 'Template_App_OpenStack_Nova_ConsoleAuth':
  }
  xmltemplate { 'Template_App_OpenStack_Nova_Scheduler':
  }
  xmltemplate { 'Template_App_OpenStack_Nova_Conductor':
  }
  xmltemplate { 'Template_App_OpenStack_Nova_NoVNCProxy':
  }
  xmltemplate { 'Template_App_OpenStack_Nova_Compute':
  }
  xmltemplate { 'Template_App_OpenStack_Libvirt':
  }
  xmltemplate { 'Template_App_OpenStack_Nova_Network':
  }

  # Keystone templates
  xmltemplate { 'Template_App_OpenStack_Keystone':
  }
  xmltemplate { 'Template_App_OpenStack_Keystone_API_check':
  }

  # Glance templates
  xmltemplate { 'Template_App_OpenStack_Glance_API':
  }
  xmltemplate { 'Template_App_OpenStack_Glance_API_check':
  }
  xmltemplate { 'Template_App_OpenStack_Glance_Registry':
  }

  # Cinder templates
  xmltemplate { 'Template_App_OpenStack_Cinder_API':
  }
  xmltemplate { 'Template_App_OpenStack_Cinder_API_check':
  }
  xmltemplate { 'Template_App_OpenStack_Cinder_Scheduler':
  }
  xmltemplate { 'Template_App_OpenStack_Cinder_Volume':
  }

  # Swift templates
  xmltemplate { 'Template_App_OpenStack_Swift_Account':
  }
  xmltemplate { 'Template_App_OpenStack_Swift_Container':
  }
  xmltemplate { 'Template_App_OpenStack_Swift_Object':
  }
  xmltemplate { 'Template_App_OpenStack_Swift_Proxy':
  }

  if $use_ceph {
    # Ceph templates
    xmltemplate { 'Template_App_OpenStack_Ceph':
    }
    xmltemplate { 'Template_App_OpenStack_Ceph_OSD':
    }
    xmltemplate { 'Template_App_OpenStack_Ceph_MON':
    }

    # Virtual Ceph Cluser
    xmltemplate { 'Template_App_OpenStack_Ceph_Cluster':
    }
    ->
    plugin_zabbix_host { $plugin_zabbix::params::openstack::ceph_virtual_cluster_name:
      host   => $plugin_zabbix::params::openstack::ceph_virtual_cluster_name,
      ip     => $plugin_zabbix::params::server_ip,
      port   => $plugin_zabbix::params::zabbix_ports['agent'],
      groups => concat($plugin_zabbix::params::host_groups_ceph_cluster, $plugin_zabbix::params::host_groups_base),
      api    => $api_hash,
    }
    ->
    plugin_zabbix_template_link { "${plugin_zabbix::params::openstack::ceph_virtual_cluster_name} Template Ceph Cluster":
      host     => $plugin_zabbix::params::openstack::ceph_virtual_cluster_name,
      template => 'Template App OpenStack Ceph Cluster',
      api      => $api_hash,
    }
    ->
    plugin_zabbix_configuration_import { 'Screens_Ceph_Cluster.xml Import':
      ensure   => present,
      xml_file => '/etc/zabbix/import/Screens_Ceph_Cluster.xml',
      api      => $api_hash,
    }
  }

  # RabbitMQ template
  xmltemplate { 'Template_App_OpenStack_RabbitMQ_ha':
  }

  # Horizon
  xmltemplate { 'Template_App_OpenStack_Horizon':
  }

  # MySQL
  xmltemplate { 'Template_App_MySQL':
  }

  # memcached
  xmltemplate { 'Template_App_Memcache':
  }

  # HAProxy
  xmltemplate { 'Template_App_HAProxy':
  }

  # Zabbix server
  xmltemplate { 'Template_App_Zabbix_Server':
  }

  # Neutron
  xmltemplate { 'Template_App_OpenStack_Neutron_Server':
  }
  xmltemplate { 'Template_App_OpenStack_Neutron_OVS_Agent':
  }
  xmltemplate { 'Template_App_OpenStack_Neutron_Metadata_Agent':
  }
  xmltemplate { 'Template_App_OpenStack_Neutron_L3_Agent':
  }
  xmltemplate { 'Template_App_OpenStack_Neutron_DHCP_Agent':
  }
  xmltemplate { 'Template_App_OpenStack_Neutron_API_check':
  }

  # Open vSwitch
  xmltemplate { 'Template_App_OpenStack_Open_vSwitch':
  }

  # Ceilometer
  xmltemplate { 'Template_App_OpenStack_Ceilometer':
  }
  xmltemplate { 'Template_App_OpenStack_Ceilometer_Compute':
  }

  # Firewall
  xmltemplate { 'Template_App_Iptables_Stats':
  }

  # Virtual OpenStack Cluster
  xmltemplate { 'Template_OpenStack_Cluster':
  }
  ->
  plugin_zabbix_host { $plugin_zabbix::params::openstack::virtual_cluster_name:
    host   => $plugin_zabbix::params::openstack::virtual_cluster_name,
    ip     => $plugin_zabbix::params::server_ip,
    port   => $plugin_zabbix::params::zabbix_ports['agent'],
    groups => $plugin_zabbix::params::host_groups_base,
    api    => $api_hash,
  }
  ->
  plugin_zabbix_template_link { "${plugin_zabbix::params::openstack::virtual_cluster_name} Template OpenStack Cluster":
    host     => $plugin_zabbix::params::openstack::virtual_cluster_name,
    template => 'Template OpenStack Cluster',
    api      => $api_hash,
  }
  ->
  plugin_zabbix_configuration_import { 'Template_Screens_OpenStack_Cluster.xml Import':
    ensure   => present,
    xml_file => '/etc/zabbix/import/Screens_OpenStack_Cluster.xml',
    api      => $api_hash,
  }

  Plugin_zabbix_hostgroup<||> -> Plugin_zabbix_host <||>

}

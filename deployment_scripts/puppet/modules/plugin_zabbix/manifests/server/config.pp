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

  plugin_zabbix::server::zabbix_import_xmltemplate { 'Template_App_Zabbix_Agent':
  }

  plugin_zabbix::server::zabbix_import_xmltemplate { 'Template_Fuel_OS_Linux':
  }

  plugin_zabbix::server::zabbix_import_xmltemplate { 'Template_NTP_binding':
  }

  plugin_zabbix::server::zabbix_import_xmltemplate { 'Template_OS_Controller':
  }

  # Nova templates
  plugin_zabbix::server::zabbix_import_xmltemplate { 'Template_App_OpenStack_Nova_API_EC2':
  }
  plugin_zabbix::server::zabbix_import_xmltemplate { 'Template_App_OpenStack_Nova_API':
  }
  plugin_zabbix::server::zabbix_import_xmltemplate { 'Template_App_OpenStack_Nova_API_Metadata':
  }
  plugin_zabbix::server::zabbix_import_xmltemplate { 'Template_App_OpenStack_Nova_API_OSAPI':
  }
  plugin_zabbix::server::zabbix_import_xmltemplate { 'Template_App_OpenStack_Nova_API_OSAPI_check':
  }
  plugin_zabbix::server::zabbix_import_xmltemplate { 'Template_App_OpenStack_Nova_Cert':
  }
  plugin_zabbix::server::zabbix_import_xmltemplate { 'Template_App_OpenStack_Nova_ConsoleAuth':
  }
  plugin_zabbix::server::zabbix_import_xmltemplate { 'Template_App_OpenStack_Nova_Scheduler':
  }
  plugin_zabbix::server::zabbix_import_xmltemplate { 'Template_App_OpenStack_Nova_Conductor':
  }
  plugin_zabbix::server::zabbix_import_xmltemplate { 'Template_App_OpenStack_Nova_NoVNCProxy':
  }
  plugin_zabbix::server::zabbix_import_xmltemplate { 'Template_App_OpenStack_Nova_Compute':
  }
  plugin_zabbix::server::zabbix_import_xmltemplate { 'Template_App_OpenStack_Libvirt':
  }
  plugin_zabbix::server::zabbix_import_xmltemplate { 'Template_App_OpenStack_Nova_Network':
  }

  # Keystone templates
  plugin_zabbix::server::zabbix_import_xmltemplate { 'Template_App_OpenStack_Keystone':
  }
  plugin_zabbix::server::zabbix_import_xmltemplate { 'Template_App_OpenStack_Keystone_API_check':
  }

  # Glance templates
  plugin_zabbix::server::zabbix_import_xmltemplate { 'Template_App_OpenStack_Glance_API':
  }
  plugin_zabbix::server::zabbix_import_xmltemplate { 'Template_App_OpenStack_Glance_API_check':
  }
  plugin_zabbix::server::zabbix_import_xmltemplate { 'Template_App_OpenStack_Glance_Registry':
  }

  # Cinder templates
  plugin_zabbix::server::zabbix_import_xmltemplate { 'Template_App_OpenStack_Cinder_API':
  }
  plugin_zabbix::server::zabbix_import_xmltemplate { 'Template_App_OpenStack_Cinder_API_check':
  }
  plugin_zabbix::server::zabbix_import_xmltemplate { 'Template_App_OpenStack_Cinder_Scheduler':
  }
  plugin_zabbix::server::zabbix_import_xmltemplate { 'Template_App_OpenStack_Cinder_Volume':
  }

  # Swift templates
  plugin_zabbix::server::zabbix_import_xmltemplate { 'Template_App_OpenStack_Swift_Account':
  }
  plugin_zabbix::server::zabbix_import_xmltemplate { 'Template_App_OpenStack_Swift_Container':
  }
  plugin_zabbix::server::zabbix_import_xmltemplate { 'Template_App_OpenStack_Swift_Object':
  }
  plugin_zabbix::server::zabbix_import_xmltemplate { 'Template_App_OpenStack_Swift_Proxy':
  }

  if $use_ceph {
    # Ceph templates
    plugin_zabbix::server::zabbix_import_xmltemplate { 'Template_App_OpenStack_Ceph':
    }
    plugin_zabbix::server::zabbix_import_xmltemplate { 'Template_App_OpenStack_Ceph_OSD':
    }
    plugin_zabbix::server::zabbix_import_xmltemplate { 'Template_App_OpenStack_Ceph_MON':
    }

    # Virtual Ceph Cluser
    plugin_zabbix::server::zabbix_import_xmltemplate { 'Template_App_OpenStack_Ceph_Cluster':
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
  plugin_zabbix::server::zabbix_import_xmltemplate { 'Template_App_OpenStack_RabbitMQ_ha':
  }

  # Horizon
  plugin_zabbix::server::zabbix_import_xmltemplate { 'Template_App_OpenStack_Horizon':
  }

  # MySQL
  plugin_zabbix::server::zabbix_import_xmltemplate { 'Template_App_MySQL':
  }

  # memcached
  plugin_zabbix::server::zabbix_import_xmltemplate { 'Template_App_Memcache':
  }

  # HAProxy
  plugin_zabbix::server::zabbix_import_xmltemplate { 'Template_App_HAProxy':
  }

  # Zabbix server
  plugin_zabbix::server::zabbix_import_xmltemplate { 'Template_App_Zabbix_Server':
  }

  # Neutron
  plugin_zabbix::server::zabbix_import_xmltemplate { 'Template_App_OpenStack_Neutron_Server':
  }
  plugin_zabbix::server::zabbix_import_xmltemplate { 'Template_App_OpenStack_Neutron_OVS_Agent':
  }
  plugin_zabbix::server::zabbix_import_xmltemplate { 'Template_App_OpenStack_Neutron_Metadata_Agent':
  }
  plugin_zabbix::server::zabbix_import_xmltemplate { 'Template_App_OpenStack_Neutron_L3_Agent':
  }
  plugin_zabbix::server::zabbix_import_xmltemplate { 'Template_App_OpenStack_Neutron_DHCP_Agent':
  }
  plugin_zabbix::server::zabbix_import_xmltemplate { 'Template_App_OpenStack_Neutron_API_check':
  }

  # Open vSwitch
  plugin_zabbix::server::zabbix_import_xmltemplate { 'Template_App_OpenStack_Open_vSwitch':
  }

  # Ceilometer
  plugin_zabbix::server::zabbix_import_xmltemplate { 'Template_App_OpenStack_Ceilometer':
  }
  plugin_zabbix::server::zabbix_import_xmltemplate { 'Template_App_OpenStack_Ceilometer_Compute':
  }

  # Firewall
  plugin_zabbix::server::zabbix_import_xmltemplate { 'Template_App_Iptables_Stats':
  }

  # Virtual OpenStack Cluster
  plugin_zabbix::server::zabbix_import_xmltemplate { 'Template_OpenStack_Cluster':
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

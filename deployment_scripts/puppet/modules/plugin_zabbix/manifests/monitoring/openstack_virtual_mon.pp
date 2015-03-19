class plugin_zabbix::monitoring::openstack_virtual_mon {

  include plugin_zabbix::params


  if hiera('role') == 'primary-controller' {
    plugin_zabbix_host { $plugin_zabbix::params::openstack::virtual_cluster_name:
      host    => $plugin_zabbix::params::openstack::virtual_cluster_name,
      ip      => $plugin_zabbix::monitoring::server_vip,
      port    => $plugin_zabbix::monitoring::ports['agent'],
      groups  => $plugin_zabbix::params::host_groups_base,
      api     => $plugin_zabbix::monitoring::api_hash,
    }
    plugin_zabbix_template_link { "${plugin_zabbix::params::openstack::virtual_cluster_name} Template OpenStack Cluster":
      host     => $plugin_zabbix::params::openstack::virtual_cluster_name,
      template => 'Template OpenStack Cluster',
      api      => $plugin_zabbix::monitoring::api_hash,
      require  => Plugin_zabbix_host[$plugin_zabbix::params::openstack::virtual_cluster_name],
    }
    # Screen
    plugin_zabbix_configuration_import { 'Template_Screens_OpenStack_Cluster.xml Import':
      ensure   => present,
      xml_file => '/etc/zabbix/import/Screens_OpenStack_Cluster.xml',
      api      => $plugin_zabbix::monitoring::api_hash,
      require  => Plugin_zabbix_template_link["${plugin_zabbix::params::openstack::virtual_cluster_name} Template OpenStack Cluster"],
    }
  }

  if defined_in_state(Class['openstack::controller']) {
    plugin_zabbix::agent::userparameter {
      'db.token.count.query':
        command => '/etc/zabbix/scripts/query_db.py token_count';
      'db.instance.error.query':
        command => '/etc/zabbix/scripts/query_db.py instance_error';
      'db.services.offline.nova.query':
        command => '/etc/zabbix/scripts/query_db.py services_offline_nova';
      'db.instance.count.query':
        command => '/etc/zabbix/scripts/query_db.py instance_count';
      'db.cpu.total.query':
        command => '/etc/zabbix/scripts/query_db.py cpu_total';
      'db.cpu.used.query':
        command => '/etc/zabbix/scripts/query_db.py cpu_used';
      'db.ram.total.query':
        command => '/etc/zabbix/scripts/query_db.py ram_total';
      'db.ram.used.query':
        command => '/etc/zabbix/scripts/query_db.py ram_used';
      'db.services.offline.cinder.query':
        command => '/etc/zabbix/scripts/query_db.py services_offline_cinder';
      'vip.nova.api.status':
        command => "/etc/zabbix/scripts/check_api.py nova_os http ${::plugin_zabbix::params::openstack::nova_vip} 8774";
      'vip.glance.api.status':
        command => "/etc/zabbix/scripts/check_api.py glance http ${::plugin_zabbix::params::openstack::glance_vip} 9292";
      'vip.keystone.api.status':
        command => "/etc/zabbix/scripts/check_api.py keystone http ${::plugin_zabbix::params::openstack::keystone_vip} 5000";
      'vip.keystone.service.api.status':
        command => "/etc/zabbix/scripts/check_api.py keystone_service http ${::plugin_zabbix::params::openstack::keystone_vip} 35357";
      'vip.cinder.api.status':
        command => "/etc/zabbix/scripts/check_api.py cinder http ${::plugin_zabbix::params::openstack::cinder_vip} 8776";
    }
  }
}

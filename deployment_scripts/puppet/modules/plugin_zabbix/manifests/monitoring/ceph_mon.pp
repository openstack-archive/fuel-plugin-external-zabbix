#
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
class plugin_zabbix::monitoring::ceph_mon {

  include plugin_zabbix::params

  if defined_in_state(Class['ceph::mon']) {

    # Set read acl for zabbix user to be able to read the ceph keyring
    exec { 'set_ceph_keyring_acl':
      command     => '/usr/bin/setfacl -m "u:zabbix:r" /etc/ceph/ceph.client.admin.keyring',
    }

    plugin_zabbix_template_link { "${plugin_zabbix::params::host_name} Template App OpenStack Ceph":
      host     => $plugin_zabbix::params::host_name,
      template => 'Template App OpenStack Ceph',
      api      => $plugin_zabbix::monitoring::api_hash,
    }
    plugin_zabbix::agent::userparameter {
      'ceph_health':
        key     => 'ceph.health',
        command => '/etc/zabbix/scripts/ceph_health.sh'
    }

    plugin_zabbix_template_link { "${plugin_zabbix::params::host_name} Template App OpenStack Ceph MON":
      host     => $plugin_zabbix::params::host_name,
      template => 'Template App OpenStack Ceph MON',
      api      => $plugin_zabbix::monitoring::api_hash,
    }

    plugin_zabbix::agent::userparameter {
      'probe.ceph':
        key     => 'probe.ceph',
        command => join([
          '/etc/zabbix/scripts/ceph.py',
          " ${plugin_zabbix::params::openstack::ceph_virtual_cluster_name}",
          " ${plugin_zabbix::params::server_ip}"], '')
    }
  }
  if defined_in_state(Class['ceph::osds']) {
    plugin_zabbix_template_link { "${plugin_zabbix::params::host_name} Template App OpenStack Ceph OSD":
      host     => $plugin_zabbix::params::host_name,
      template => 'Template App OpenStack Ceph OSD',
      api      => $plugin_zabbix::monitoring::api_hash,
    }
  }
}

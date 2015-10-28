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
class plugin_zabbix::params::openstack {

  $virtual_cluster_name  = 'OpenStackCluster'
  $ceph_virtual_cluster_name  = 'CephCluster'

  $keystone_vip          = hiera('management_vip')
  $db_vip                = hiera('management_vip')
  $nova_vip              = hiera('management_vip')
  $glance_vip            = hiera('management_vip')
  $cinder_vip            = hiera('management_vip')
  $rabbit_vip            = hiera('management_vip')
  $zabbix_hash           = hiera('zabbix_monitoring')


  $access_hash           = hiera('access')
  $keystone_hash         = hiera('keystone')
  $nova_hash             = hiera('nova')
  $neutron_hash          = hiera('neutron_config')
  $cinder_hash           = hiera('cinder')
  $rabbit_hash           = hiera('rabbit')

  $access_user           = 'monitoring'
  $access_password       = $zabbix_hash['monitoring_password']
  $access_tenant         = 'services'
  $keystone_db_password  = $keystone_hash['db_password']
  $nova_db_password      = $nova_hash['db_password']
  $neutron_db_password   = $neutron_hash['database']['passwd']
  $cinder_db_password    = $cinder_hash['db_password']
  $rabbit_password       = $rabbit_hash['password']
  $rabbitmq_service_name = 'rabbitmq-server'

  if !$rabbit_hash['user'] {
    $rabbit_user         = 'nova'
  } else {
    $rabbit_user         = $rabbit_hash['user']
  }
}

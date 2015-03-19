class plugin_zabbix::params::openstack {

  $virtual_cluster_name  = 'OpenStackCluster'

  $keystone_vip          = hiera('management_vip')
  $db_vip                = hiera('management_vip')
  $nova_vip              = hiera('management_vip')
  $glance_vip            = hiera('management_vip')
  $cinder_vip            = hiera('management_vip')
  $rabbit_vip            = hiera('management_vip')

  $access_hash           = hiera('access')
  $keystone_hash         = hiera('keystone')
  $nova_hash             = hiera('nova')
  $cinder_hash           = hiera('cinder')
  $rabbit_hash           = hiera('rabbit')

  $access_user           = $access_hash['user']
  $access_password       = $access_hash['password']
  $access_tenant         = $access_hash['tenant']
  $keystone_db_password  = $keystone_hash['db_password']
  $nova_db_password      = $nova_hash['db_password']
  $cinder_db_password    = $cinder_hash['db_password']
  $rabbit_password       = $rabbit_hash['password']
  $rabbitmq_service_name = 'rabbitmq-server'

  if !$rabbit_hash['user'] {
    $rabbit_user         = 'nova'
  } else {
    $rabbit_user         = $rabbit_hash['user']
  }
}

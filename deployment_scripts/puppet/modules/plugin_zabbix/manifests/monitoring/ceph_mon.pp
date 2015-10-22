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
  $roles     = hiera(roles)
  $settings = hiera(storage)
  $use_ceph = $settings['volumes_ceph']

  # Make sure BC exists so that checks work
  if !defined(Package['bc']) {
    package { 'bc':
      ensure => 'present',
    }
  }

  if $use_ceph {
    # Set read acl for zabbix user to be able to read the ceph keyring
    exec { 'set_ceph_keyring_acl':
      command     => '/usr/bin/setfacl -m "u:zabbix:r" /etc/ceph/ceph.client.admin.keyring',
    }
    plugin_zabbix::agent::userparameter {
      'ceph.osd_in':
        key      => 'ceph.osd_in',
        command => '/etc/zabbix/scripts/ceph-status.sh in',
    }
    ->
    plugin_zabbix::agent::userparameter {
      'ceph.osd_up':
        key      => 'ceph.osd_up',
        command => '/etc/zabbix/scripts/ceph-status.sh up',
    }
    ->
    plugin_zabbix::agent::userparameter {
      'ceph.active':
        key      => 'ceph.active',
        command => '/etc/zabbix/scripts/ceph-status.sh active',
    }
    ->
    plugin_zabbix::agent::userparameter {
      'ceph.backfill':
        key      => 'ceph.backfill',
        command => '/etc/zabbix/scripts/ceph-status.sh backfill',
    }
    ->
    plugin_zabbix::agent::userparameter {
      'ceph.clean':
        key      => 'ceph.clean',
        command => '/etc/zabbix/scripts/ceph-status.sh clean',
    }
    ->
    plugin_zabbix::agent::userparameter {
      'ceph.creating':
        key      => 'ceph.creating',
        command => '/etc/zabbix/scripts/ceph-status.sh creating',
    }
    ->
    plugin_zabbix::agent::userparameter {
      'ceph.degraded':
        key      => 'ceph.degraded',
        command => '/etc/zabbix/scripts/ceph-status.sh degraded',
    }
    ->
    plugin_zabbix::agent::userparameter {
      'ceph.degraded_percent':
        key      => 'ceph.degraded_percent',
        command => '/etc/zabbix/scripts/ceph-status.sh degraded_percent',
    }
    ->
    plugin_zabbix::agent::userparameter {
      'ceph.down':
        key      => 'ceph.down',
        command => '/etc/zabbix/scripts/ceph-status.sh down',
    }
    ->
    plugin_zabbix::agent::userparameter {
      'ceph.incomplete':
        key      => 'ceph.incomplete',
        command => '/etc/zabbix/scripts/ceph-status.sh incomplete',
    }
    ->
    plugin_zabbix::agent::userparameter {
      'ceph.inconsistent':
        key      => 'ceph.inconsistent',
        command => '/etc/zabbix/scripts/ceph-status.sh inconsistent',
    }
    ->
    plugin_zabbix::agent::userparameter {
      'ceph.peering':
        key      => 'ceph.peering',
        command => '/etc/zabbix/scripts/ceph-status.sh peering',
    }
    ->
    plugin_zabbix::agent::userparameter {
      'ceph.recovering':
        key      => 'ceph.recovering',
        command => '/etc/zabbix/scripts/ceph-status.sh recovering',
    }
    ->
    plugin_zabbix::agent::userparameter {
      'ceph.remapped':
        key      => 'ceph.remapped',
        command => '/etc/zabbix/scripts/ceph-status.sh remapped',
    }
    ->
    plugin_zabbix::agent::userparameter {
      'ceph.repair':
        key      => 'ceph.repair',
        command => '/etc/zabbix/scripts/ceph-status.sh repair',
    }
    ->
    plugin_zabbix::agent::userparameter {
      'ceph.replay':
        key      => 'ceph.replay',
        command => '/etc/zabbix/scripts/ceph-status.sh replay',
    }
    ->
    plugin_zabbix::agent::userparameter {
      'ceph.scrubbing':
        key      => 'ceph.scrubbing',
        command => '/etc/zabbix/scripts/ceph-status.sh scrubbing',
    }
    ->
    plugin_zabbix::agent::userparameter {
      'ceph.splitting':
        key      => 'ceph.splitting',
        command => '/etc/zabbix/scripts/ceph-status.sh splitting',
    }
    ->
    plugin_zabbix::agent::userparameter {
      'ceph.stale':
        key      => 'ceph.stale',
        command => '/etc/zabbix/scripts/ceph-status.sh stale',
    }
    ->
    plugin_zabbix::agent::userparameter {
      'ceph.pgtotal':
        key      => 'ceph.pgtotal',
        command => '/etc/zabbix/scripts/ceph-status.sh pgtotal',
    }
    ->
    plugin_zabbix::agent::userparameter {
      'ceph.waitBackfill':
        key      => 'ceph.waitBackfill',
        command => '/etc/zabbix/scripts/ceph-status.sh waitBackfill',
    }
    ->
    plugin_zabbix::agent::userparameter {
      'ceph.mon':
        key      => 'ceph.mon',
        command => '/etc/zabbix/scripts/ceph-status.sh mon',
    }
    ->
    plugin_zabbix::agent::userparameter {
      'ceph.rados_total':
        key      => 'ceph.rados_total',
        command => '/etc/zabbix/scripts/ceph-status.sh rados_total',
    }
    ->
    plugin_zabbix::agent::userparameter {
      'ceph.rados_used':
        key      => 'ceph.rados_used',
        command => '/etc/zabbix/scripts/ceph-status.sh rados_used',
    }
    ->
    plugin_zabbix::agent::userparameter {
      'ceph.rados_free':
        key      => 'ceph.rados_free',
        command => '/etc/zabbix/scripts/ceph-status.sh rados_free',
    }
    ->
    plugin_zabbix::agent::userparameter {
      'ceph.wrbps':
        key      => 'ceph.wrbps',
        command => '/etc/zabbix/scripts/ceph-status.sh wrbps',
    }
    ->
    plugin_zabbix::agent::userparameter {
      'ceph.rdbps':
        key      => 'ceph.rdbps',
        command => '/etc/zabbix/scripts/ceph-status.sh rdbps',
    }
    ->
    plugin_zabbix::agent::userparameter {
      'ceph.ops':
        key      => 'ceph.ops',
        command => '/etc/zabbix/scripts/ceph-status.sh ops',
    }
    ->
    plugin_zabbix::agent::userparameter {
      'ceph.quorum':
        key      => 'ceph.quorum',
        command => '/etc/zabbix/scripts/ceph-status.sh mon_quorum',
    }
    ->
    plugin_zabbix::agent::userparameter {
      'ceph.apply':
        key      => 'ceph.apply',
        command => '/etc/zabbix/scripts/ceph-status.sh apply',
    }
    ->
    plugin_zabbix::agent::userparameter {
      'ceph.commit':
        key      => 'ceph.commit',
        command => '/etc/zabbix/scripts/ceph-status.sh commit',
    }
    ->
    plugin_zabbix::agent::userparameter {
      'ceph.obj':
        key      => 'ceph.obj',
        command => '/etc/zabbix/scripts/ceph-status.sh obj',
    }
    ->
    plugin_zabbix::agent::userparameter {
      'ceph.osd_kbused':
        key      => 'ceph.osd_kbused',
        command => '/etc/zabbix/scripts/ceph-status.sh osd_kbused',
    } ->
    plugin_zabbix_template_link { "${plugin_zabbix::params::host_name} Template App OpenStack Ceph Cluster":
      host     => $plugin_zabbix::params::host_name,
      template => 'Template App OpenStack Ceph Cluster',
      api      => $plugin_zabbix::monitoring::api_hash,
    }
  }
  if member($roles, 'ceph-osd') {
    plugin_zabbix::agent::userparameter {
      'ceph_health':
        key     => 'ceph.health',
        command => '/etc/zabbix/scripts/ceph_health.sh'
    }
    ->
    plugin_zabbix_template_link { "${plugin_zabbix::params::host_name} Template App OpenStack Ceph":
      host     => $plugin_zabbix::params::host_name,
      template => 'Template App OpenStack Ceph',
      api      => $plugin_zabbix::monitoring::api_hash,
    }
    ->
    plugin_zabbix_template_link { "${plugin_zabbix::params::host_name} Template App OpenStack Ceph OSD":
      host     => $plugin_zabbix::params::host_name,
      template => 'Template App OpenStack Ceph OSD',
      api      => $plugin_zabbix::monitoring::api_hash,
    }
  }

  if ($use_ceph == true and (member($roles, 'controller') or member($roles, 'primary-controller'))) {
    plugin_zabbix_template_link { "${plugin_zabbix::params::host_name} Template App OpenStack Ceph MON":
      host     => $plugin_zabbix::params::host_name,
      template => 'Template App OpenStack Ceph MON',
      api      => $plugin_zabbix::monitoring::api_hash,
    }
  }
}

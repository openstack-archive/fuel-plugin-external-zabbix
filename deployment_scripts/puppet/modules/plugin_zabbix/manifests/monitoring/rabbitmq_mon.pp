class plugin_zabbix::monitoring::rabbitmq_mon {

  include plugin_zabbix::params

  #RabbitMQ server
  if defined_in_state(Class['Rabbitmq']) {

    plugin_zabbix_template_link { "${plugin_zabbix::params::host_name} Template App OpenStack RabbitMQ":
      host        => $plugin_zabbix::params::host_name,
      template    => 'Template App OpenStack HA RabbitMQ',
      api         => $plugin_zabbix::monitoring::api_hash,
    }

    exec { 'enable rabbitmq management plugin':
      command     => 'rabbitmq-plugins enable rabbitmq_management',
      path        => ['/usr/sbin', '/usr/bin', '/sbin', '/bin' ],
      unless      => 'rabbitmq-plugins list -m -E rabbitmq_management | grep -q rabbitmq_management',
      environment => 'HOME=/root',
    }

    firewall {'992 rabbitmq management':
      port        => '15672',
      proto       => 'tcp',
      action      => 'accept',
    }

    plugin_zabbix::agent::userparameter {
      'rabbitmq.queue.items':
        command   => '/etc/zabbix/scripts/check_rabbit.py queues-items';
      'rabbitmq.queues.without.consumers':
        command   => '/etc/zabbix/scripts/check_rabbit.py queues-without-consumers';
      'rabbitmq.missing.nodes':
        command   => '/etc/zabbix/scripts/check_rabbit.py missing-nodes';
      'rabbitmq.unmirror.queues':
        command   => '/etc/zabbix/scripts/check_rabbit.py unmirror-queues';
      'rabbitmq.missing.queues':
        command   => '/etc/zabbix/scripts/check_rabbit.py missing-queues';
    }
  }
}

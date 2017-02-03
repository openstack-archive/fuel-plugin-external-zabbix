#!/usr/bin/python
# Copyright 2015 Mirantis, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import base
import socket
import sys

class CephMonPlugin(base.ZabbixSender):
    """ Collect states and information about ceph cluster and placement groups.
    """
    def itermetrics_status(self):
        status = self.execute_to_json('ceph -s --format json')
        if not status:
            return

        if 'mons' in status['monmap']:
            monitor_nb = len(status['monmap']['mons'])
        else:
            monitor_nb = 0
        yield {
            'type': 'monitor_count',
            'value': monitor_nb
        }

        yield {
            'type': 'quorum_count',
            'value': len(status.get('quorum', []))
        }

        pgmap = status['pgmap']
        yield {
            'type': 'pg_bytes_used',
            'value': pgmap['bytes_used'],
        }
        yield {
            'type': 'pg_bytes_free',
            'value': pgmap['bytes_avail'],
        }
        yield {
            'type': 'pg_bytes_total',
            'value': pgmap['bytes_total'],
        }
        yield {
            'type': 'pg_data_bytes',
            'value': pgmap['data_bytes']
        }
        yield {
            'type': 'pg_count',
            'value': pgmap['num_pgs']
        }

        # see: http://ceph.com/docs/master/rados/operations/pg-states/
        pg_states = {
            'creating': 0,
            'active': 0,
            'clean': 0,
            'down': 0,
            'replay': 0,
            'splitting': 0,
            'scrubbing': 0,
            'deep': 0,
            'degraded': 0,
            'inconsistent': 0,
            'peering': 0,
            'repair': 0,
            'recovering': 0,
            'backfill': 0,
            'waitbackfill': 0,
            'backfilltoofull': 0,
            'incomplete': 0,
            'stale': 0,
            'remapped': 0,
            'undersized': 0,
            'peered': 0,
        }

        for state in pgmap['pgs_by_state']:
            if '+' in state['state_name']:
                states = state['state_name'].split('+')
            else:
                states = [state['state_name']]

            if not states:
                self.logger.error("Unknown state {}".format(state['state_name']))
                continue

            for s in states:
                if s in pg_states:
                    pg_states[s] += state['count']
                else:
                    self.logger.warning("PG state not known {}".format(s))

        for n, num in pg_states.iteritems():
            yield {
                'type': 'pg_state_count_{}'.format(n),
                'value': num
            }

    def itermetrics_df(self):
        df = self.execute_to_json('ceph df --format json')
        if not df:
            return

        objects_count = 0
        for pool in df['pools']:
            objects_count += pool['stats'].get('objects', 0)
            # TODO(scroiset): add low level discovery for pool names
            #for m in ('bytes_used', 'max_avail', 'objects'):
            #    yield {
            #        'type': 'pool_%s' % m,
            #        'type_instance': pool['name'],
            #        'value': pool['stats'].get(m, 0),
            #    }

        yield {
            'type': 'objects_count',
            'value': objects_count
        }
        yield {
            'type': 'pool_count',
            'value': len(df['pools'])
        }

        if 'total_bytes' in df['stats']:
            # compatibility with 0.84+
            total = df['stats']['total_bytes']
            used = df['stats']['total_used_bytes']
            avail = df['stats']['total_avail_bytes']
        else:
            # compatibility with <0.84
            total = df['stats']['total_space'] * 1024
            used = df['stats']['total_used'] * 1024
            avail = df['stats']['total_avail'] * 1024

        yield {
            'type': 'pool_total_bytes_used',
            'value': used
        }
        yield {
            'type': 'pool_total_bytes_free',
            'value': avail
        }
        yield {
            'type': 'pool_total_bytes_total',
            'value': total
        }
        yield {
            'type': 'pool_total_percent_used',
            'value': 100.0 * used / total
        }
        yield {
            'type': 'pool_total_percent_free',
            'value': 100.0 * avail / total
        }

    # TODO(scroiset): add low level discovery for pool names
    #def itermetrics_pool(self):
    #    stats = self.execute_to_json('ceph osd pool stats --format json')
    #    if not stats:
    #        return

    #    for pool in stats:
    #        client_io_rate = pool.get('client_io_rate', {})
    #        yield {
    #            'type': 'pool_bytes_rate',
    #            'type_instance': pool['pool_name'],
    #            'value': [client_io_rate.get('read_bytes_sec', 0),
    #                       client_io_rate.get('write_bytes_sec', 0)]
    #        }
    #        yield {
    #            'type': 'pool_ops_rate',
    #            'type_instance': pool['pool_name'],
    #            'value': client_io_rate.get('op_per_sec', 0)
    #        }

    def itermetrics_osd(self):
        osd = self.execute_to_json('ceph osd dump --format json')
        if not osd:
            return

        # TODO(scroiset): add low level discovery for pool names
        #for pool in osd['pools']:
        #    for name in ('size', 'pg_num', 'pg_placement_num'):
        #        yield {
        #            'type': 'pool_%s' % name,
        #            'type_instance': pool['pool_name'],
        #            'value': pool[name]
        #        }

        _up, _down, _in, _out = (0, 0, 0, 0)
        for osd in osd['osds']:
            if osd['up'] == 1:
                _up += 1
            else:
                _down += 1
            if osd['in'] == 1:
                _in += 1
            else:
                _out += 1

        yield {
            'type': 'osd_count_up',
            'value': _up
        }
        yield {
            'type': 'osd_count_down',
            'value': _down
        }
        yield {
            'type': 'osd_count_in',
            'value': _in
        }
        yield {
            'type': 'osd_count_out',
            'value': _out
        }

    def send(self):
        has_error = False
        for m in plugin.itermetrics_status():
            has_error = self.zabbix_sender(m['type'], m['value'])
        for m in plugin.itermetrics_df():
            has_error = self.zabbix_sender(m['type'], m['value'])
        for m in plugin.itermetrics_osd():
            has_error = self.zabbix_sender(m['type'], m['value'])
        return has_error


# print and return codes:
# 0: no error
# 1: failed to send some/all metrics
# 2: exception occured while retrieving metrics
# 3: missing arguments

if not len(sys.argv) == 3:
    # missing arguments!
    print 3
    sys.exit(3)

hostname = sys.argv[1]
server_ip = sys.argv[2]
plugin = CephMonPlugin(zbx_server_ip=server_ip, zbx_hostname=hostname)

try:
    has_error = plugin.send()
    if has_error:
        print 1
        sys.exit(1)
    else:
        print 0
except Exception as e:
    plugin.logger.error(e)
    print 2
    sys.exit(2)

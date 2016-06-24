#!/usr/bin/python
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
import urllib2
import simplejson as json
import sys
import base64
import ConfigParser
from zabbix_checks_logger import get_logger

CONF_FILE = '/etc/zabbix/check_rabbit.conf'


class RabbitmqAPI(object):
    def __init__(self, logger, config):
        self.logger = logger
        self.login = config.get('rabbitmq', 'user')
        self.password = config.get('rabbitmq', 'password')
        self.host = config.get('rabbitmq', 'host')
        self.auth_string = base64.encodestring('%s:%s' %
                                               (self.login,
                                                self.password)
                                               ).replace('\n', '')
        self.max_queues = int(config.get('rabbitmq', 'max_queues'))

    def get_http(self, url):
        try:
            request = urllib2.Request('%s/api/%s' % (self.host, url))
            request.add_header("Authorization", "Basic %s" % self.auth_string)
            return json.loads(urllib2.urlopen(request, timeout=2).read())
        except urllib2.URLError as e:
            self.logger.error("URL error: '%s'" % e)
            sys.exit(1)
        except ValueError as e:
            self.logger.error("Value error: '%s'" % e)
            sys.exit(1)

    def get_queues_items(self):
        response = self.get_http('overview')
        if 'queue_totals' in response:
            self.logger.critical(response['queue_totals']['messages'])
        else:
            self.logger.error('No queue_totals in response')

    def get_missing_queues(self):
        queues = len(self.get_http('queues'))
        self.logger.critical(self.max_queues-queues)

    def get_queues_without_consumers(self):
        queues_without_consumers = len([i for i in self.get_http('queues') \
            if not i.get('consumers') > 0])
        self.logger.critical(queues_without_consumers)

    def get_missing_nodes(self):
        missing_nodes = len([i for i in self.get_http('nodes') \
            if not i['running']])
        self.logger.critical(missing_nodes)

    def get_unmirror_queues(self):
        response = self.get_http('nodes')
        if (len(response) < 2):
            self.logger.critical(0)
            return

        response = self.get_http('queues')
        ha_nodes = len([i for i in self.get_http('queues') if queue.get('policy') == 'ha-all'])
        synchronised_slave_nodes = len([i for i in self.get_http('queues') if len(queue.get('synchronised_slave_nodes') > 0)
        unmirror_queues = ha_nodes - synchronised_slave_nodes
        self.logger.critical(unmirror_queues)

def usage():
    print("check_rabbit.py usage:\n \
            queues-items - item count in queues\n \
            queues-without-consumers - count queues without consumers\n \
            missing-nodes - count missing nodes from rabbitmq cluster\n \
            unmirror-queues - count unmirrored queues\n \
            missing-queues max_queues - compare queues count to max_queues\n")


def main():
    config = ConfigParser.RawConfigParser()
    config.read(CONF_FILE)
    logger = get_logger(config.get('rabbitmq', 'log_level'))

    API = RabbitmqAPI(logger, config)

    if len(sys.argv) < 2:
        logger.critical('No argvs, dunno what to do')
        sys.exit(1)

    if sys.argv[1] == 'missing-queues':
        API.get_missing_queues()
    elif sys.argv[1] == 'queues-items':
        API.get_queues_items()
    elif sys.argv[1] == 'queues-without-consumers':
        API.get_queues_without_consumers()
    elif sys.argv[1] == 'missing-nodes':
        API.get_missing_nodes()
    elif sys.argv[1] == 'unmirror-queues':
        API.get_unmirror_queues()
    else:
        usage()

if __name__ == "__main__":
    main()

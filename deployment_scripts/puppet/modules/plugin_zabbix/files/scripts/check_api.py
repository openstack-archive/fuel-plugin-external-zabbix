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
import sys
import simplejson as json
import ConfigParser
from zabbix_checks_logger import get_logger

CONF_FILE = '/etc/zabbix/check_api.conf'


class OSAPI(object):
    """Openstack API"""

    def __init__(self, logger, config):
        self.logger = logger
        self.config = config
        self.username = self.config.get('api', 'user')
        self.password = self.config.get('api', 'password')
        self.tenant_name = self.config.get('api', 'tenant')
        self.endpoint_keystone = self.config.get('api',
                                                 'keystone_endpoints'
                                                 ).split(',')
        self.token = None
        self.tenant_id = None
        self.get_token()

    def get_timeout(self, service):
        try:
            return int(self.config.get('api', '%s_timeout' % service))
        except ConfigParser.NoOptionError:
            return 1

    def get_token(self):
        data = json.dumps({
            "auth":
            {
                'tenantName': self.tenant_name,
                'passwordCredentials':
                {
                    'username': self.username,
                    'password': self.password
                    }
                }
            })
        fail_services = 0
        for keystone in self.endpoint_keystone:
            self.logger.info("Trying to get token from '%s'" % keystone)
            try:
                request = urllib2.Request(
                    '%s/tokens' % keystone,
                    data=data,
                    headers={
                        'Content-type': 'application/json'
                    })
                data = json.loads(
                    urllib2.urlopen(
                        request, timeout=self.get_timeout('keystone')).read())
                self.token = data['access']['token']['id']
                self.tenant_id = data['access']['token']['tenant']['id']
                self.logger.debug("Got token '%s'" % self.token)
                return
            except Exception as e:
                self.logger.debug("Got exception '%s'" % e)
                fail_services += 1
        if fail_services == len(self.endpoint_keystone):
            self.logger.critical(0)
            sys.exit(1)

    def check_api(self, url, service):
        self.logger.info("Trying '%s' on '%s'" % (service, url))
        try:
            request = urllib2.Request(url,
                                      headers={
                                          'X-Auth-Token': self.token,
                                      })
            urllib2.urlopen(request, timeout=self.get_timeout(service))
        except Exception as e:
            self.logger.debug("Got exception from '%s' '%s'" % (service, e))
            self.logger.critical(0)
            sys.exit(1)
        self.logger.critical(1)


def main():
    config = ConfigParser.RawConfigParser()
    config.read(CONF_FILE)
    logger = get_logger(config.get('api', 'log_level'))

    API = OSAPI(logger, config)

    if len(sys.argv) < 5:
        logger.critical('No argvs, dunno what to do')
        sys.exit(1)
    map = config.get('api', '%s_map' % sys.argv[1])

    url = '%s://%s:%s/%s' % (sys.argv[2], sys.argv[3], sys.argv[4], map)
    url = url % API.__dict__

    API.check_api(url, sys.argv[1])

if __name__ == "__main__":
    main()

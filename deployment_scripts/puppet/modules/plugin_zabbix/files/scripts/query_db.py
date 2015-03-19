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
import ConfigParser
import sys
import sqlalchemy
from zabbix_checks_logger import get_logger

CONF_FILE = '/etc/zabbix/check_db.conf'


def query_db(logger, connection_string, query_string):
    try:
        engine = sqlalchemy.create_engine(connection_string)
        res = engine.execute(query_string).first()
    except sqlalchemy.exc.OperationalError as e:
        logger.critical("Operational error '%s'" % e)
    except sqlalchemy.exc.ProgrammingError as e:
        logger.critical("Programming error '%s'" % e)
    else:
        return res[0]

config = ConfigParser.RawConfigParser()
config.read(CONF_FILE)

logger = get_logger(config.get('query_db', 'log_level'))

if __name__ == '__main__':
    if len(sys.argv) < 2:
        logger.critical('No argvs, dunno what to do')
        sys.exit(1)

    item = sys.argv[1]
    try:
        sql_connection = config.get('query_db', '%s_connection' % item)
        sql_query = config.get('query_db', '%s_query' % item)
    except ConfigParser.NoOptionError as e:
        logger.critical("Item '%s' not configured" % item)
        sys.exit(2)

    logger.info("Get request for item '%s'" % item)
    logger.debug("Sql connection: '%s', sql query: '%s'" %
                 (sql_connection, sql_query))
    logger.critical(query_db(logger, sql_connection, sql_query))

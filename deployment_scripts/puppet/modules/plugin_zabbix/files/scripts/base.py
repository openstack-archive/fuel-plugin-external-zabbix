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

import json
import logging
import re
import subprocess
import time
import traceback

ERROR_RE = "[Ff]ailed: (\d+);"
OK_RE = "[Pp]rocessed: (\d+);"

class ZabbixSender(object):
    """ Base class for writing Python plugins.
    """

    def __init__(self, zbx_server_ip, zbx_hostname, zbx_server_port=10051,
                 timeout=5, debug=False, log_file='/var/log/zabbix/sender.log'):
        self.timeout = timeout
        self.debug = debug
        if debug:
            level = logging.DEBUG
        else:
            level = logging.INFO
        logging.basicConfig(filename=log_file, level=level)
        self.logger = logging

        self.server_port = zbx_server_port
        self.server_ip = zbx_server_ip
        self.hostname = zbx_hostname

    def execute(self, cmd, shell=True, cwd=None, outputs_on_error=False):
        """
        Executes a program with arguments.

        Args:
            cmd: a list of program arguments where the first item is the
            program name.
            shell: whether to use the shell as the program to execute (default=
            True).
            cwd: the directory to change to before running the program
            (default=None).

        Returns:
            A tuple containing the standard output and error strings if the
            program execution has been successful.

            ("foobar\n", "")

            None if the command couldn't be executed or returned a non-zero
            status code unless outputs_on_error is True
        """
        start_time = time.time()
        try:
            proc = subprocess.Popen(
                cmd,
                cwd=cwd,
                shell=shell,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE
            )
            (stdout, stderr) = proc.communicate()
            stdout = stdout.rstrip('\n')
        except Exception as e:
            self.logger.error("Cannot execute command '%s': %s : %s" %
                              (cmd, str(e), traceback.format_exc()))
            return None

        returncode = proc.returncode

        if returncode != 0:
            self.logger.error("Command '%s' failed (return code %d): %s %s" %
                              (cmd, returncode, stderr, stdout))
            if not outputs_on_error:
                return None

        elapsedtime = time.time() - start_time

        if self.debug:
            self.logger.info("Command '%s' returned %s in %0.3fs" %
                             (cmd, returncode, elapsedtime))

        if not stdout and self.debug:
            self.logger.info("Command '%s' returned no output!", cmd)

        return (stdout, stderr)

    def execute_to_json(self, *args, **kwargs):
        """
        Executes a program and decodes the output as a JSON string.

        See execute().

        Returns:
            A Python object or None if the execution of the program failed.
        """
        outputs = self.execute(*args, **kwargs)
        if outputs:
            return json.loads(outputs[0])
        return

    def _response_has_error(self, response):
        err = re.findall(ERROR_RE, response)
        ok = re.findall(OK_RE, response)
        if (len(err) > 0 and err[0] != '0') or (len(ok) > 0 and int(ok[0]) == 0):
            return True
        return False

    def zabbix_sender(self, key, value):
        """ Use zabbix_sender to send metrics to zabbix server.

        Return True if successfully processed else False
        """

        #TODO(scroiset): implement zabbix_sender in pure python to avoid forking process
        cmd = "zabbix_sender -z {server_ip} -p {server_port} -s {hostname} "\
              "-k {key} -o {value}".format(
                  server_ip=self.server_ip, hostname=self.hostname,
                  server_port= self.server_port, key = key, value= value
              )
        resp = self.execute(cmd, outputs_on_error=True)
        return self._response_has_error(resp[0])

# -*- coding: utf-8 -*-

#
# Ansible is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Ansible is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Ansible.  If not, see <http://www.gnu.org/licenses/>.


# Copyright (c) 2023 AppDynamics LLC and its affiliates
# All Rights Reserved
# You may use this code under the terms contained in the LICENSE.txt provided to You with the package.

from __future__ import (absolute_import, division, print_function)

__metaclass__ = type

DOCUMENTATION = '''
    name: "appd_agent_status"
    type: notification
    requirements:
      - "invoked in the command line"
    short_description: Save agent status to files
    version_added: "0.0.1"
    options:
        appd_agent_status_suffix:
            version_added: "0.0.1"
            description: suffix for the agent status log file
            default: ""
            type: string
            ini:
                - section: appdynamics
                  key: agent_status_suffix
            env:
                - name: APPDYNAMICS_AGENT_STATUS_SUFFIX
            vars:
                - name: appdynamics_agent_status_suffix
        appd_agent_status_directory:
            version_added: "0.0.1"
            description: directory for the agent status log file
            default: ""
            type: path
            ini:
                - section: appdynamics
                  key: agent_status_directory
            env:
                - name: APPDYNAMICS_AGENT_STATUS_DIRECTORY
            vars:
                - name: appdynamics_agent_status_directory
    description:
        - write agent status to a file.
'''

import os
from ansible.module_utils._text import to_bytes, to_text
from ansible.plugins.callback import CallbackBase
from datetime import datetime
from ansible.utils.path import makedirs_safe, unfrackpath
import re
import copy


class CallbackModule(CallbackBase):
    CALLBACK_VERSION = 2.8
    CALLBACK_TYPE = u'aggregate'
    CALLBACK_NAME = u'appd_agent_status'
    CALLBACK_NEEDS_WHITELIST = True

    AGENT_STATUS_TASK_NAME_PREFIX = u"appdynamics_agent_status".encode('utf-8')

    def __init__(self, display=None, options=None):
        super(CallbackModule, self).__init__(display, options)
        self.current_start_time = None
        self.output_suffix = ""
        self.directory = os.getcwd()
        self.user_variable = ""
        self.failed_task_status = {}
        # To limit outputting user variables to playbook roles
        self.include_role_count = 1

    def set_options(self, task_keys=None, var_options=None, direct=None):
        ''' Initialize Plugin Configs '''

        super(CallbackModule, self).set_options(task_keys=task_keys, var_options=var_options, direct=direct)
        self.output_suffix = self.get_option('appd_agent_status_suffix')
        self.directory = self.get_option('appd_agent_status_directory')

    def report_agent_status_file(self, hostname, buf, task_name):
        """ Write Agent Status to File """
        buf = to_bytes(buf)
        now = datetime.now()
        timestamp = now.strftime("%m/%d/%Y-%H:%M:%S:")
        filename = "agent_status_{0}{1}.log".format(self.current_start_time, self.output_suffix)
        host_line = to_bytes("\n{0}##{1}##{2}\n".format(timestamp, hostname, task_name))

        self.directory = unfrackpath(self.directory)
        try:
            makedirs_safe(self.directory)
        except (OSError, IOError) as e:
            self._display.warning(
                u"Unable to access or create the configured directory (%s): %s" % (to_text(self.directory), to_text(e)))

        try:
            path = to_bytes(os.path.join(self.directory, filename))
            with open(path, 'ab+') as fd:
                fd.write(host_line)
                fd.write(buf)
        except (OSError, IOError) as e:
            self._display.warning(
                u"AppD agent status plugin: unable to write to %s's file: %s" % (hostname, to_text(e)))

    def mergeDictionary(self, dict_1, dict_2):
        dict_3 = {}
        if not dict_2:
            return dict_1
        dict_3.update(dict_2)
        print(dict_3)
        for key, value in dict_3.items():
            if key in dict_1 and key in dict_2:
                dict_3[key] = [value, dict_1[key]]
                print(dict_3)
        for key, value in dict_1.items():
            if key not in dict_3:
                dict_3[key] = dict_1[key]
        return dict_3

    def report_agent_status(self, result):
        self.report_agent_status_file(result._host.get_name(), self._dump_results(result._result), result.task_name)

    def playbook_on_start(self):
        self.current_start_time = datetime.now().strftime("%m_%d_%Y-%Hh_%Mm_%Ss")

    def v2_runner_on_ok(self, result):
        try:
            if self.is_report_agent_status(result.task_name):
                if str(result._host) in self.failed_task_status and "Failed" in result.task_name:
                    result._result = self.mergeDictionary(result._result, self.failed_task_status[str(result._host)])
                    self.failed_task_status.pop(str(result._host))
                self.report_agent_status(result)
        except Exception as e:
            self._display.warning(u"Ok task Exception happened at agent status plugin: %s" % to_text(e))

    def v2_runner_on_failed(self, result, ignore_errors=False):
        if "invocation" in result._result:
            result._result.pop("invocation")
        if str(result._host) in self.failed_task_status:
            self.failed_task_status[str(result._host)] = self.mergeDictionary(result._result, self.failed_task_status[str(result._host)])
        else:
            self.failed_task_status[str(result._host)] = result._result
        print(self.failed_task_status[str(result._host)])
        print(result._task)
        self.failed_task_status[str(result._host)]["failed_task"] = str(result._task)
        try:
            if self.is_report_agent_status(result.task_name):
                self.report_agent_status(result)
        except Exception as e:
            self._display.warning(u"Failed task Exception happened at agent status plugin: %s" % to_text(e))

    def v2_runner_on_unreachable(self, result):
        try:
            if self.is_report_agent_status(result.task_name):
                self.report_agent_status(result)
        except Exception as e:
            self._display.warning(u"Unreachable task Exception happened at agent status plugin: %s" % to_text(e))

    def is_report_agent_status(self, task_name):
        return task_name.encode('utf-8', 'ignore').startswith(self.AGENT_STATUS_TASK_NAME_PREFIX)

    def v2_playbook_on_task_start(self, task, is_conditional):
        # Logging User configurable variables to the file,
        # Bypassing is_report_agent_status check for avoid duplicate logging
        if self.include_role_count:
            if "_role_name" in task.__dict__ and re.match("appdynamics.agents.*", task._role_name):
                self.user_variable += "Fetched from " + task._role_name + "\n"
                for key in task._ds["vars"]:
                    print(key, '->', task._ds["vars"][key])
                    self.user_variable = self.user_variable + u"%s -> %s\n" % (key, task._ds["vars"][key])
                self.user_variable += "Fetched from args.yaml\n"
                for key in task.get_variable_manager()._vars_cache:
                    print(task.get_variable_manager()._vars_cache[key])
                    temp_variable = copy.deepcopy(task.get_variable_manager()._vars_cache.get(key))
                    temp_variable['controller_account_access_key'] = "****"
                    self.user_variable = self.user_variable + u"%s\n" % (temp_variable)
                    break
                self.user_variable += "Fetched extra vars from command line\n"
                print(task.get_variable_manager()._extra_vars)
                self.user_variable = self.user_variable + u"%s\n" % (task.get_variable_manager()._extra_vars)
                self.report_agent_status_file("", self.user_variable, " User Variable Output")
                self.include_role_count = self.include_role_count - 1
        self.user_variable = ""

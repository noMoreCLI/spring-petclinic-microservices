#!/usr/bin/python
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

from __future__ import absolute_import, division, print_function

__metaclass__ = type

DOCUMENTATION = r'''
---
module: appd_get_agent
short_description: Downaloads or prints the appdynamics download url for the agnet.
description:
     - Auto generates appdynamics configuration as fact data depending on the environment.
version_added: "0.0.1"
author:
    - Appdynamics Team <mail@example.com> (@_)
'''


from ansible.module_utils.basic import AnsibleModule

import json
import time
import logging
import urllib.request
import urllib.error
import urllib.parse


DEFAULT_DOWNLOAD_SITE = "https://download-files.appdynamics.com"
LATEST_VERSION_API = "https://download.appdynamics.com/download/latest"
MAX_RETRIES = 5
CHUNK_SIZE = 8 * 1024  # streaming chuck size
PORTAL_TEMPLATE = "https://download.appdynamics.com/download/downloadfile/?"\
                  "version={version}&apm={apm}&os={os}&platform_admin_os={platform_os}" \
                  "&events={events}&eum={eum}&apm_os={apm_os}"


def retry(max_retries):
    def decorator(func):
        def wrapper(*args, **kwargs):
            for n in range(max_retries):
                try:
                    return func(*args, **kwargs)
                except urllib.error.HTTPError as exception:
                    logging.debug("Error occurred: %s, retrying in %s seconds.", exception, 2 ** n)
                except urllib.error.URLError as exception:
                    logging.debug("URL Error: %s, retrying in %s seconds", exception.reason, 2 ** n)
                time.sleep(2 ** n)
            raise DownloadError("Failed after {0} retries".format(max_retries))
        return wrapper
    return decorator


class DownloadError(Exception):
    pass


class DownloadAgent:
    AGENT_OPTIONS = {
        "sun-java7": ("jvm,java-jdk8", "sun-jvm", "linux",
                      "download-file/sun-jvm/VERSION/AppServerAgent-VERSION.zip", "AppServerAgent-VERSION.zip"),
        "java7": ("jvm,java-jdk8", "sun-jvm", "linux",
                  "download-file/sun-jvm/VERSION/AppServerAgent-VERSION.zip", "AppServerAgent-VERSION.zip"),
        "sun-java": ("jvm,java-jdk8", "java-jdk8", "linux",
                     "download-file/java-jdk8/VERSION/AppServerAgent-1.8-VERSION.zip",
                     "AppServerAgent-1.8-VERSION.zip"),
        "java": ("jvm,java-jdk8", "java-jdk8", "linux",
                 "download-file/java-jdk8/VERSION/AppServerAgent-1.8-VERSION.zip", "AppServerAgent-1.8-VERSION.zip"),
        "ibm-java": ("jvm,java-jdk8", "ibm-jvm", "linux",
                     "download-file/ibm-jvm/VERSION/AppServerAgent-ibm-VERSION.zip", "AppServerAgent-ibm-VERSION.zip"),
        "machine": ("machine", "machineagent-bundle-64bit-linux", "linux",
                    "download-file/machine-bundle/VERSION/machineagent-bundle-64bit-linux-VERSION.zip",
                    "machineagent-bundle-64bit-linux-VERSION.zip"),
        "machine-win": ("machine", "machineagent-bundle-64bit-windows", "windows",
                        "download-file/machine-bundle/VERSION/machineagent-bundle-64bit-windows-VERSION.zip",
                        "machineagent-bundle-64bit-windows-VERSION.zip"),
        "machine-solaris": ("machine", "machineagent-bundle-64bit-solaris", "solaris",
                            "download-file/machine-bundle/VERSION/machineagent-bundle-64bit-solaris-x64-VERSION.zip",
                            "machineagent-bundle-64bit-solaris-x64-VERSION.zip"),
        "machine-solaris-sparcv9": ("machine", "sparcv9", "solaris-sparc,solaris",
                                    "download-file/machine-bundle/VERSION/machineagent-bundle-64bit-solaris-sparcv9"
                                    "-VERSION.zip",
                                    "machineagent-bundle-64bit-solaris-sparcv9-VERSION.zip"),
        "dotnet_msi": ("dotnet", "dotNetAgentSetup64", "windows",
                       "download-file/dotnet/VERSION/dotNetAgentSetup64-VERSION.msi",
                       "dotNetAgentSetup64-VERSION.msi"),
        "dotnet": ("dotnet,dotnet-core", "AppDynamics-DotNetCore-linux-x64", "linux",
                   "download-file/dotnet-core/VERSION/AppDynamics-DotNetCore-linux-x64-VERSION.zip",
                   "AppDynamics-DotNetCore-linux-x64-VERSION.zip"),
        "db": ("db", "db-agent", "linux", "download-file/db-agent/VERSION/db-agent-VERSION.zip",
               "db-agent-VERSION.zip"),
        "db-win": ("db", "db-agent-winx64", "windows",
                   "download-file/db-agent-winx64/VERSION/db-agent-64bit-windows-VERSION.zip",
                   "db-agent-64bit-windows-VERSION.zip"),
        "php-tar": ("php", "php-tar", "linux",
                    "download-file/php-tar/VERSION/appdynamics-php-agent-x64-linux-VERSION.tar.bz2",
                    "appdynamics-php-agent-x64-linux-VERSION.tar.bz2"),
        "php-zts-tar": ("php", "php-zts-tar", "linux",
                        "download-file/php-zts-tar/VERSION/appdynamics-php-zts-agent-x64-linux-VERSION.tar.bz2",
                        "appdynamics-php-zts-agent-x64-linux-VERSION.tar.bz2"),
        "python": ("python", "python", "linux",
                   "download-file/python/VERSION/appdynamics-pythonagent-VERSION-linux-64bit.tar.bz2",
                   "appdynamics-pythonagent-VERSION-linux-64bit.tar.bz2"),
        "python-alpine": ("python", "alpine-linux-64bit", "linux,alpine-linux",
                          "download-file/python/VERSION/appdynamics-pythonagent-VERSION-alpine-linux-64bit.tar.bz2",
                          "appdynamics-pythonagent-VERSION-alpine-linux-64bit.tar.bz2"),
        "apache": ("webserver", "nativeWebServer-64bit-linux", "linux",
                   "download-file/webserver-sdk/VERSION/appdynamics-sdk-native-nativeWebServer-64bit-linux-VERSION.tgz",
                   "appdynamics-sdk-native-nativeWebServer-64bit-linux-VERSION.tgz"),
        "apache-i386": ("webserver", "nativeWebServer-32bit-linux", "linux",
                        "download-file/webserver-sdk/VERSION/appdynamics-sdk-native-nativeWebServer-32bit-linux"
                        "-VERSION.tgz",
                        "appdynamics-sdk-native-nativeWebServer-32bit-linux-VERSION.tgz"),
        "iib": ("iib", "appdynamics-iib-linux-x64", "linux",
                "download-file/iib/VERSION/appdynamics-iib-linux-x64-VERSION.tbz2",
                "appdynamics-iib-linux-x64-VERSION.tbz2"),
        "iib-aix": ("iib", "appdynamics-iib-aix-64", "linux,aix",
                    "download-file/iib/VERSION/appdynamics-iib-aix-64-VERSION.tbz2",
                    "appdynamics-iib-aix-64-VERSION.tbz2"),
    }

    def __init__(self, agent_name, agent_version):
        self.events = None
        self.eum = None
        self.app_agent = None
        self.finder = None
        self.os_platform = None
        self.agent_name = agent_name
        self.agent_version = agent_version
        self.download_options()
        if self.agent_version == "latest":
            self.get_latest_version()
        self.s3_path = self.s3_path.replace("VERSION", self.agent_version)
        self.file_name = self.file_name.replace("VERSION", self.agent_version)

    def download_options(self):
        try:
            self.app_agent, self.finder, self.os_platform, self.s3_path, self.file_name = self.AGENT_OPTIONS[
                self.agent_name]
        except KeyError:
            raise DownloadError("unknown agent type: {0}".format(self.agent_name))

    @retry(MAX_RETRIES)
    def get_latest_version(self):
        req = urllib.request.Request(LATEST_VERSION_API)
        with urllib.request.urlopen(req) as response:
            data = response.read().decode("utf-8")
            response_code = response.getcode()

            if response_code == 200:
                json_data = json.loads(data)

                for version in json_data:
                    if self.finder in version['s3_path']:
                        self.agent_version = version['version']
                        return self.agent_version
                raise ValueError("Unable to find latest version in API response")
            else:
                raise urllib.error.HTTPError(url=LATEST_VERSION_API, code=response_code)

    @retry(MAX_RETRIES)
    def get_download_url_from_portal(self):
        portal_page = PORTAL_TEMPLATE.format(
            version=self.agent_version,
            apm=self.app_agent,
            os=self.os_platform,
            platform_os=self.os_platform,
            events=self.events,
            eum=self.eum,
            apm_os=self.os_platform
        )

        req = urllib.request.Request(portal_page)
        with urllib.request.urlopen(req) as response:
            data = response.read().decode("utf-8")
            response_code = response.getcode()

            if response_code == 200:
                json_data = json.loads(data)
                results = json_data['results']
                for result in results:
                    if self.finder in result['s3_path']:
                        self.s3_path = result['s3_path']
                        logging.debug("determined the download s3_path as %s", self.s3_path)
                        return self.s3_path
            else:
                raise urllib.error.HTTPError(url=portal_page, code=response_code)

    def download_agent_from_s3(self):
        url = urllib.parse.urljoin(base=DEFAULT_DOWNLOAD_SITE, url=self.s3_path)
        try:
            path, headers = urllib.request.urlretrieve(url, self.file_name)
            logging.debug("downloaded file to %s status headers %s", path, headers)
            return 200
        except urllib.error.HTTPError as e:
            logging.debug("unable to download the file from %s with status code %s", url, e.code)
            return e.code


def main():
    module_args = dict(
        agent=dict(type='str', required=True),
        version=dict(type='str', default='latest'),
        dryrun=dict(type='bool', default=False),
        latest=dict(type='bool', default=False),
        portal=dict(type='bool', default=False)
    )

    module = AnsibleModule(argument_spec=module_args, supports_check_mode=True)

    agent = module.params['agent']
    version = module.params['version']
    dryrun = module.params['dryrun']
    latest = module.params['latest']
    portal = module.params['portal']

    da = DownloadAgent(agent, version)

    try:
        if dryrun:
            module.exit_json(changed=False, result=urllib.parse.urljoin(base=DEFAULT_DOWNLOAD_SITE, url=da.s3_path))
        elif portal:
            module.exit_json(changed=False, result=da.get_download_url_from_portal())
        elif latest:
            module.exit_json(changed=False, result=da.get_latest_version())
        else:
            status_code = da.download_agent_from_s3()
            if status_code != 200:
                da.get_download_url_from_portal()
                status_code = da.download_agent_from_s3()
                if status_code != 200:
                    module.fail_json(msg="Could not download the requested agent. "
                                         "Please ensure that the agent version exists in"
                                         " https://download.appdynamics.com",
                                     result="failed")
                else:
                    module.exit_json(changed=True, result=da.get_download_url_from_portal())
    except DownloadError as derr:
        logging.error("module failure %s", str(derr))
        module.fail_json(msg="Could not download the requested agent. "
                             "Please ensure that the agent version exists in https://download.appdynamics.com",
                         result="failed")


if __name__ == '__main__':
    main()

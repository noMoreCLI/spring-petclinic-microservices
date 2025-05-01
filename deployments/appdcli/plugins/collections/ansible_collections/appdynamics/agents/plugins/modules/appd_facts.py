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

from __future__ import (absolute_import, division, print_function)

__metaclass__ = type

DOCUMENTATION = r'''
---
module: appd_facts
short_description: Auto generates appdynamics configuration as fact data depending on the environment.
description:
     - Auto generates appdynamics configuration as fact data depending on the environment.
version_added: "0.0.1"
options:
  strategy:
    description: Strategy to use for delivering auto naming; for example, tomcat, jboss, or default
    type: str
    required: false
    default: "default"
  path:
    description: path to the framework (tomcat, jboss)
    type: str
    required: false
    default: ""
  preferred_appname:
    description: The preferred application name specific by customer
    type: str
    required: false
    default: "default"
extends_documentation_fragment:
  -  action_common_attributes
  -  action_common_attributes.facts
attributes:
    check_mode:
        support: full
    diff_mode:
        support: none
    facts:
        support: full
    platform:
        platforms: posix, windows
author:
    - Appdynamics Team <mail@example.com> (@_)
'''

EXAMPLES = r'''
- name: Autogenerate appdynamics facts
  appd_facts:
    strategy: tomcat
    path: /opt/prod/apache-tomcat
- name: Autogenerate appdynamics facts (default)
  appd_facts:
'''

RETURN = r'''
ansible_facts:
  description: AppDynamics facts that will be appended to ansible_facts
  returned: always
  type: complex
  contains:
    appdynamics:
      description: AppDynamics App, Tier, Node names with appdynamics name as key.
      returned: always
      type: complex
      contains:
        app:
          description:
          - Suggested app name.
          returned: always
          type: str
          sample: tomcat
        tier:
          description:
          - Suggested tier name.
          returned: always
          type: str
          sample: java-tier
        node:
          description:
          - Suggested node name.
          type: str
          sample: hostname.appd
'''

from ansible.module_utils.basic import AnsibleModule

import logging
import os
import platform


def default_strategy(appname, path):
    if appname is None:
        appname = "default"
    tier = "default"
    if path is not None and path != "":
        tier = "java, " + path

    return dict(app=appname, tier=tier, node=platform.node())


def java_strategy(appname, path):
    if appname is None:
        appname = "default"
    tier = "java"
    if path is not None and path != "":
        tier = "java, " + path

    return dict(app=appname, tier=tier, node=platform.node())


def tomcat_strategy(appname, path):
    catalinabase = os.environ.get('CATALINA_BASE')

    tier = "tomcat"
    if catalinabase is None or catalinabase == "":
        if path is not None and path != "":
            tier = tier + ", " + path
    else:
        tier = tier + ", " + catalinabase

    if appname is None or appname == "":
        appname = "default"

    out = "path is " + path + " tier is " + tier
    logging.debug(out)

    return dict(app=appname, tier=tier, node=platform.node())


def jboss_strategy(appname, path):
    jboss_service = os.environ.get('JBOSS_SERVICE')

    tier = "jboss"
    if jboss_service is None or jboss_service == "":
        if path is not None and path != "":
            tier = tier + ", " + path
    else:
        tier = tier + ", " + jboss_service

    if appname is None:
        appname = "default"

    return dict(app=appname, tier=tier, node=platform.node())


# example:  https://docs.ansible.com/ansible/latest/dev_guide/developing_api.html#python-api-example


def main():
    appd_module = AnsibleModule(
        argument_spec=dict(
            strategy=dict(required=False, default="default", type="str"),
            path=dict(required=False, default="", type="str"),
            preferred_appname=dict(required=False, default="default", type="str")
        ),
        supports_check_mode=True,
    )

    strategy = appd_module.params['strategy']
    preferred_appname = appd_module.params['preferred_appname']
    path = appd_module.params['path']

    appd = dict()
    if strategy == 'tomcat':
        appd = tomcat_strategy(preferred_appname, path)
    elif strategy == 'jboss':
        appd = jboss_strategy(preferred_appname, path)
    elif strategy == 'java':
        appd = java_strategy(preferred_appname, path)
    else:
        appd = default_strategy(preferred_appname, path)

    results = dict(ansible_facts=dict(appdynamics=appd), changed=False)
    appd_module.exit_json(**results)


if __name__ == "__main__":
    main()

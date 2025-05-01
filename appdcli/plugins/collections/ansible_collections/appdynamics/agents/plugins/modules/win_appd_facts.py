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

DOCUMENTATION = r'''
---
module: win_appd_facts
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

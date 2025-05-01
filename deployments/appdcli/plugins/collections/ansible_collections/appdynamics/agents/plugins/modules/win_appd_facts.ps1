#!powershell

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

#AnsibleRequires -CSharpUtil Ansible.Basic

$spec = @{
    options = @{
        strategy = @{ type = "str"; default = "default" }
        path = @{ type = "str"; default = "" }
        preferred_appname = @{ type = "str"; default = "default" }
    }
    supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

$strategy = $module.Params.strategy
$path = $module.Params.path
$preferred_appname = $module.Params.preferred_appname

# all existing strategies use the same logic for application and node naming so set them upfront
$appdynamicsFacts = @{
    app = $preferred_appname
    tier = ''
    node = $Env:ComputerName
}

Function Use-Strategy-Default {
    $appdynamicsFacts.tier = If ('' -ne $path) { "java, $path" } Else { 'default' }
}

Function Use-Strategy-Java {
    $appdynamicsFacts.tier = If ('' -ne $path) { "java, $path" } Else { 'java' }
}

Function Use-Strategy-JBoss {
    $jbossService = $env:JBOSS_SERVICE
    $appdynamicsFacts.tier = If ('' -ne "$jbossService" ) { "jboss, $jbossService" } ElseIf ('' -ne $path) { "jboss, $path" } Else { 'jboss' }
}

Function Use-Strategy-Tomcat {
    $catalinaBase = $env:CATALINA_BASE
    $appdynamicsFacts.tier = If ('' -ne "$catalinaBase") { "tomcat, $catalinaBase" } ElseIf ('' -ne $path) { "tomcat, $path" } Else { 'tomcat' }
}

Switch ($strategy) {
    'tomcat' { Use-Strategy-Tomcat }
    'jboss' { Use-Strategy-JBoss }
    'java' { Use-Strategy-Java }
    default { Use-Strategy-Default }
}

$module.Result.ansible_facts = @{ appdynamics = $appdynamicsFacts }
$module.Result.changed = $False

$module.ExitJson()
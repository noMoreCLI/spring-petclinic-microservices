#!/bin/bash

set -e

AGENTS_DIR=/opt/appdynamics
SMARTAGENT_DIR_DEFAULT=${AGENTS_DIR}/appdcli
SMARTAGENT_DIR="$(cd "$(dirname "$0")" && pwd)" # the path to the directory containing the uninstall script

# Make sure APPD_USER and APPD_USER_GROUP are set
if [ -z "${APPD_USER}" ] || [ -z "${APPD_USER_GROUP}" ]; then
  APPD_USER=root
  APPD_USER_GROUP=root
fi

PLUGINS_DIR=${SMARTAGENT_DIR}/plugins
ENV_DIR=${PLUGINS_DIR}/appdenv
ENV_DIR_BAK=${PLUGINS_DIR}/appdenvbak

# Restore original appdenv backup if it exists
if [ -d "${ENV_DIR_BAK}" ]; then
    echo "restoring previous virtualenv from backup"
    rm -rf "${ENV_DIR}"
    mv "${ENV_DIR_BAK}" "${ENV_DIR}"
fi

# Remove Python virtual environment if it exists
if [ -d "${ENV_DIR}" ]; then
    echo "removing virtualenv directory: ${ENV_DIR}"
    rm -rf "${ENV_DIR}"
fi

# Check if sed is available
if which sed >/dev/null 2>&1; then
    # Remove LD_PRELOAD setting from /etc/environment if present using sed
    if grep -q "LD_PRELOAD=${SMARTAGENT_DIR}/lib/libpreload.so" /etc/environment; then
        echo "removing LD_PRELOAD setting from /etc/environment"
        sed -i "/LD_PRELOAD=.*\/lib\/libpreload.so/d" /etc/environment
    fi
else
    echo "sed is not available please remove LD_PRELOAD setting manually from /etc/environment"
fi

ETC_OPT_DIR=/etc/opt/appdynamics
ETC_LD_PRELOAD_CONFIG=${ETC_OPT_DIR}/ld_preload.json

# Remove LD_PRELOAD configuration file if it exists
if [ -L "${ETC_LD_PRELOAD_CONFIG}" ]; then
    echo "removing symbolic link ${ETC_LD_PRELOAD_CONFIG}/lib/libpreload.so"
    rm -f "${ETC_LD_PRELOAD_CONFIG}"
fi

# Check if 'sed' is available
if which sed >/dev/null 2>&1; then
    echo "updating ansible.cfg with default values"
    sed -i "s/${APPD_USER}/APPD_USER/g" "${PLUGINS_DIR}"/ansible.cfg
    sed -i "s:${SMARTAGENT_DIR}:${SMARTAGENT_DIR_DEFAULT}:g" "${PLUGINS_DIR}"/ansible.cfg
else
    echo "sed is not available please remove User and Group value manually in plugins/ansible.cfg"
fi

if [ -L "${SMARTAGENT_DIR}/lib/libpreload.so" ]; then
    echo "removing symbolic link ${SMARTAGENT_DIR}/lib/libpreload.so"
    rm -f "${SMARTAGENT_DIR}"/lib/libpreload.so
fi

echo "clean up completed successfully"

#!/bin/sh

set -e

SMARTAGENT_DIR="$(cd "$(dirname "$0")" && pwd)"
APPD_BIN="${SMARTAGENT_DIR}/appd"

# Autocompletion file paths
declare -A COMPLETION_FILES=(
    ["bash"]="/etc/profile.d/appdcli-completion.sh"
    ["zsh"]="/usr/local/share/zsh/site-functions/_appdcli-completion"
    ["fish"]="/usr/share/fish/vendor_completions.d/appdcli-completion.fish"
)

# Remove previous autocomplete shell scripts
for file in "${COMPLETION_FILES[@]}"; do
    rm -f "$file"
done

SHELL_NAME=$(basename "$SHELL")

if [[ -n "${COMPLETION_FILES[$SHELL_NAME]}" ]]; then
    echo "Adding smartagent cli autocompletion for the \"${SHELL_NAME}\" shell"
    ${APPD_BIN} completion "${SHELL_NAME}" > "${COMPLETION_FILES[$SHELL_NAME]}"
else
    echo "INFO: Autocomplete not supported for the ${SHELL_NAME} shell"
fi

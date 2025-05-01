#!/usr/bin/env bash

set -o nounset

readonly LATEST_VERSION_API="https://download.appdynamics.com/download/latest"
readonly ERR_BAD_RESPONSE=4
readonly APPD_LATEST_VERSIONS="appd_latest_versions"

get_latest_version() {
  _finder="appdsmartagent"
  http_response=$(curl --location --http1.0 --silent -o ${APPD_LATEST_VERSIONS} --write-out "%{http_code}" "${LATEST_VERSION_API}")
  if [ "$http_response" != "200" ]; then
      exit_with_error "bad HTTP response code while finding the latest version of $1 agent: ${http_response}" "${ERR_BAD_RESPONSE}"
  else
      latest_version=$(jq "first(.[]  | select(.s3_path | test(\"${_finder}\"))) | .version" < "${APPD_LATEST_VERSIONS}" )
      echo "${latest_version}" | tr -d '"'
  fi
}

main() {
  get_latest_version
}

main "$@"

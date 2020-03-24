#!/usr/bin/env bash

echo '##########################################################################'
echo '#               About to run setup_zookeeper.sh script                   #'
echo '##########################################################################'

set -ex

ZOOKEEPER_PROPERTIES_FILE=${ZOOKEEPER_PROPERTIES_FILE:-/opt/nifi/conf/zookeeper.properties}
HOSTNAME=$(hostname)

if [[ -z "${ZOOKEEPER_CONNECT_STRING}" ]]; then
    exit 0
fi

if [[ ! -f "${ZOOKEEPER_PROPERTIES_FILE}" ]]; then
    echo "[ERROR] NiFi properties file ${ZOOKEEPER_PROPERTIES_FILE} is missing" >&2
    exit 1
fi

sed -ie '/^server.1=/d' "${ZOOKEEPER_PROPERTIES_FILE}"
echo "##### NiFi Configuration #####" >>"${ZOOKEEPER_PROPERTIES_FILE}"
count=0
IFS=',' read -ra my_array <<<"${ZOOKEEPER_CONNECT_STRING}"
for i in "${my_array[@]}"; do
    count=$((count+1))
    server=$(awk -F: '{print $1}' <<<$i)
    port=$(awk -F: '{print $2}' <<<$i)
    echo "server.${count}=${server}:2888:3888;${port}" >>"${ZOOKEEPER_PROPERTIES_FILE}"
    if [[ "${HOSTNAME}" == "${server}" ]]; then
        mkdir -p /opt/nifi/state/zookeeper
        echo "${count}" >/opt/nifi/state/zookeeper/myid
        chown -R nifi:nifi /opt/nifi/state
    fi
done

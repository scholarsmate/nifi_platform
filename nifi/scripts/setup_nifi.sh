#!/usr/bin/env bash

echo '##########################################################################'
echo '#               About to run setup_nifi.sh script                        #'
echo '##########################################################################'

set -ex

NIFI_PROPERTIES_FILE=${NIFI_PROPERTIES_FILE:-/opt/nifi/conf/nifi.properties}
HOSTNAME=$(hostname)

if [[ ! -f "${NIFI_PROPERTIES_FILE}" ]]; then
    echo "[ERROR] NiFi properties file ${NIFI_PROPERTIES_FILE} is missing" >&2
    exit 1
fi

sed -ie "s/^nifi.web.proxy.host=/nifi.web.proxy.host=${HOSTNAME}/g" "${NIFI_PROPERTIES_FILE}"
sed -ie "s/^nifi.remote.input.host=/nifi.remote.input.host=${HOSTNAME}/g" "${NIFI_PROPERTIES_FILE}"
sed -ie "s/^nifi.remote.input.socket.port=/nifi.remote.input.socket.port=9998/g" "${NIFI_PROPERTIES_FILE}"

# If a ZOOKEEPER_CONNECT_STRING is populated, then configure a NiFi cluster
if [[ -n "${ZOOKEEPER_CONNECT_STRING}" ]]; then
    sed -ie "s/^nifi.cluster.is.node=false/nifi.cluster.is.node=true/g" "${NIFI_PROPERTIES_FILE}"
    sed -ie "s/^nifi.cluster.node.address=/nifi.cluster.node.address=${HOSTNAME}/g" "${NIFI_PROPERTIES_FILE}"
    sed -ie "s/^nifi.cluster.node.protocol.port=/nifi.cluster.node.protocol.port=9999/g" "${NIFI_PROPERTIES_FILE}"
    sed -ie "s/^nifi.zookeeper.connect.string=/nifi.zookeeper.connect.string=${ZOOKEEPER_CONNECT_STRING}/g" "${NIFI_PROPERTIES_FILE}"
    sed -ie "s/^nifi.state.management.embedded.zookeeper.start=false/nifi.state.management.embedded.zookeeper.start=true/g" "${NIFI_PROPERTIES_FILE}"
fi
chown -R nifi:nifi /opt/nifi*

# Start up NiFi as the nifi user
runuser -l nifi -c "JAVA_HOME=$(dirname $(dirname $(readlink $(readlink $(which javac))))) /opt/nifi/bin/nifi.sh start"

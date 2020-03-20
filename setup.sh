#!/usr/bin/env bash

# Make sure password less sudo is enabled
#sudo -v || ( echo "Please setup password-less sudo first" >&2 && exit 1 )

# Change the PWD to the directory where this script resides
cd $(dirname $(readlink -e $0))

if [[ -f ./setup.cfg ]]; then
  echo "Reading configuration from setup.cfg"
  source ./setup.cfg
fi

NIFI_VERSION=${NIFI_VERSION:-1.11.3}

cat << __EOF__ | tee ./setup.sav
##############################################################################
# Settings: $(date)
##############################################################################
NIFI_VERSION="${NIFI_VERSION}"
##############################################################################
__EOF__

set -x

cd "./nifi"

if [[ ! -f "./nifi-bin.tar.gz" ]]; then
    echo "Downloading Apache NiFi version ${NIFI_VERSION} ..."
    wget -O "./nifi-bin.tar.gz" "http://apache.mirrors.pair.com/nifi/${NIFI_VERSION}/nifi-${NIFI_VERSION}-bin.tar.gz"
fi

vagrant up --provider=libvirt
vagrant status

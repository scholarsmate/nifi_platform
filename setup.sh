#!/usr/bin/env bash

# Make sure password less sudo is enabled
#sudo -v || ( echo "Please setup password-less sudo first" >&2 && exit 1 )

# Change the PWD to the directory where this script resides
cd $(dirname $(readlink -e $0))

if [[ -f ./setup.cfg ]]; then
  echo "[INFO] Reading configuration from setup.cfg"
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
echo "[INFO] Preserve settings used by copying setup.sav to setup.cfg"

set -x

cd "./nifi"
mkdir -p packages
if [[ ! -f "./packages/nifi-bin.tar.gz" ]]; then
    echo "[INFO] Downloading Apache NiFi version ${NIFI_VERSION} ..."
    wget -O ./packages/nifi-bin.tar.gz http://apache.mirrors.pair.com/nifi/${NIFI_VERSION}/nifi-${NIFI_VERSION}-bin.tar.gz
fi

vagrant up --provider=libvirt --no-parallel
vagrant status

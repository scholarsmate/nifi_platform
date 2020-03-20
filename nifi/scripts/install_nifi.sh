#!/usr/bin/env bash

echo '##########################################################################'
echo '#               About to run install_nifi.sh script                      #'
echo '##########################################################################'

set -ex

[[ -d /home/nifi ]] || useradd nifi
cd /opt
tar -xvf /vagrant/packages/nifi-*.tar.gz
ln -s /opt/nifi-* /opt/nifi
chown -R nifi:nifi /opt/nifi*

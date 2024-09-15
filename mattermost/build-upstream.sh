#!/bin/bash -ex

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd ${DIR}
BUILD_DIR=${DIR}/../build/snap/mattermost

mkdir -p ${BUILD_DIR}

wget https://github.com/cyberb/mattermost/archive/refs/heads/master.tar.gz
tar xf master.tar.gz
cd mattermost-master/server
make setup-go-work
make build-linux BUILD_NUMBER='syncloud'
cp bin/mattermost ${BUILD_DIR}/mattermost/bin/

cp -r /lib ${BUILD_DIR}
cp -r /mattermost ${BUILD_DIR}
cp --remove-destination -R ${DIR}/bin ${BUILD_DIR}/sbin




#!/bin/bash -ex

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd ${DIR}
BUILD_DIR=${DIR}/../build/snap/mattermost

mkdir -p ${BUILD_DIR}

wget https://github.com/cyberb/mattermost/archive/refs/heads/syncloud.tar.gz
tar xf syncloud.tar.gz
cd mattermost-syncloud/server
make setup-go-work
make build-linux BUILD_NUMBER='syncloud'
make prepackaged-plugins

mkdir -p ${BUILD_DIR}/mattermost/bin
cp bin/mattermost ${BUILD_DIR}/mattermost/bin
cp bin/mmctl ${BUILD_DIR}/mattermost/bin
cp -r fonts ${BUILD_DIR}/mattermost
cp -r i18n ${BUILD_DIR}/mattermost
cp -r prepackaged_plugins ${BUILD_DIR}/mattermost

cp -r /usr ${BUILD_DIR}
cp -r /lib ${BUILD_DIR}
cp --remove-destination -R ${DIR}/bin ${BUILD_DIR}/sbin

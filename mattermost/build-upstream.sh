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
cp bin/mattermost ${BUILD_DIR}/mattermost/bin/


#!/bin/bash -ex

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd ${DIR}
BUILD_DIR=${DIR}/../build/snap/mattermost
mkdir -p ${BUILD_DIR}

cd ${DIR}/mattermost-syncloud/server
make build-templates
cp -r templates ${BUILD_DIR}/mattermost

cd ${DIR}/mattermost-syncloud/webapp
npm i
npm run build
ls -la dist
mv dist ${BUILD_DIR}/mattermost/client

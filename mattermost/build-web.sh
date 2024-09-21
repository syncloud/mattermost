#!/bin/bash -ex

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd ${DIR}
BUILD_DIR=${DIR}/../build/snap/mattermost
mkdir -p ${BUILD_DIR}

cd ${DIR}/mattermost-syncloud/server
#make build-templates
cd templates && make build
cd ..
cp -r templates ${BUILD_DIR}/mattermost

cd ${DIR}/mattermost-syncloud/webapp
npm config set fetch-retry-mintimeout 200000
npm config set fetch-retry-maxtimeout 1200000
npm i
npm run build

ls -la
ls -la platform/client
ls -la platform/components
ls -la platform/types

mv platform/client/dist ${BUILD_DIR}/mattermost/client

#!/bin/bash -ex

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd ${DIR}
BUILD_DIR=${DIR}/../build/snap/mattermost
mkdir -p ${BUILD_DIR}
cd mattermost-syncloud/webapp
npm i
npm run build
ls -la dist
mv dist ${BUILD_DIR}/mattermost/client

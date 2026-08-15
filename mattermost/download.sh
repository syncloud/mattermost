#!/bin/bash -ex

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd ${DIR}
BUILD_DIR=${DIR}/../build/snap/mattermost

mkdir -p ${BUILD_DIR}
ARCH=$1
VERSION=$2

${DIR}/../apt.sh wget

cd ${DIR}/../build
mkdir mattermost
cd mattermost
${DIR}/../download-retry.sh https://github.com/cyberb/mattermost/releases/download/$VERSION/server-$ARCH-$VERSION.tar.gz server.tar.gz
tar xf server.tar.gz
rm -rf server.tar.gz
mv * ${BUILD_DIR}
cd ..
rm -rf mattermost


mkdir web
cd web
${DIR}/../download-retry.sh https://github.com/cyberb/mattermost/releases/download/$VERSION/web-$VERSION.tar.gz web.tar.gz
tar xf web.tar.gz
rm -rf web.tar.gz
mv * ${BUILD_DIR}
cd ..
rm -rf web

cp --remove-destination -R ${DIR}/bin ${BUILD_DIR}/sbin

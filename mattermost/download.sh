#!/bin/bash -ex

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd ${DIR}
BUILD_DIR=${DIR}/../build/snap/mattermost

mkdir -p ${BUILD_DIR}
ARCH=$1
VERSION=$2

apt update
apt -y install wget

cd ${DIR}/../build
mkdir mattermost
cd mattermost
wget --progress=dot:giga https://github.com/cyberb/mattermost/releases/download/$VERSION/server-$ARCH-$VERSION.tar.gz -O server.tar.gz
tar xf server.tar.gz
cd ..
mv mattermost/* ${BUILD_DIR}


mkdir web
cd web
wget --progress=dot:giga https://github.com/cyberb/mattermost/releases/download/$VERSION/web-$VERSION.tar.gz -O web.tar.gz
tar xf web.tar.gz
mv client ${BUILD_DIR}
cd ..
rm -rf web

cp --remove-destination -R ${DIR}/bin ${BUILD_DIR}/sbin

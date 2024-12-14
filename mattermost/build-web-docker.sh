#!/bin/sh -ex

DIR=$( cd "$( dirname "$0" )" && pwd )
cd ${DIR}
VERSION=$1
BUILD_DIR=${DIR}/../build/snap/mattermost
while ! docker create --name=app mattermost/mattermost-enterprise-edition:$VERSION ; do
  sleep 1
  echo "retry docker"
done
mkdir -p ${BUILD_DIR}
cd ${DIR}/../build
docker export app -o app.tar
tar xf app.tar
rm -rf app.tar
cp -R mattermost/mattermost/client ${BUILD_DIR}/

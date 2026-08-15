#!/bin/bash -ex

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd ${DIR}/..

NAME=$1
VERSION=$(cat version)

./package.sh ${NAME} ${VERSION}

#!/bin/bash -e
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
/bin/rm -f $SNAP_COMMON/web.socket
source $SNAP_DATA/config/mattermost.env
$DIR/wait-for-configure.sh
exec $SNAP/mattermost/sbin/mattermost -c $SNAP_DATA/config/config.json

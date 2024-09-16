#!/bin/bash -e
/bin/rm -f $SNAP_COMMON/web.socket
source $SNAP_DATA/config/mattermost.env
exec $SNAP/mattermost/sbin/mattermost -c $SNAP_DATA/config/config.json

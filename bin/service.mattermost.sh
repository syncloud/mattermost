#!/bin/bash -e
source $SNAP_DATA/config/mattermost.env
exec $SNAP/mattermost/sbin/mattermost -c $SNAP_DATA/config/config.json

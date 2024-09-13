#!/bin/bash -e
source $SNAP_DATA/config/mattermost.env
exec $SNAP/mattermost/sbin/mattermost

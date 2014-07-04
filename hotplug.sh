#!/bin/bash
################################################################################
# Copyright 2011 by the Digital Aggregates Corporation, Colorado, USA
# Licensed under the terms in README.h
# Chip Overclock <coverclock@diag.com>
# http://www.diag.com/navigation/downloads/Biscuit
# Install (if /sbin/hotplug and /etc/hotplug.d doesn't already exist):
#  cp hotplug.sh /sbin/hotplug
#  chmod 755 /sbin/hotplug
#  mkdir -p /etc/hotplug.d/block
################################################################################
DIR="/etc/hotplug.d"
for FF in ${DIR}/$1/*.hotplug ${DIR}/default/*.hotplug; do
    if [ -x ${FF} ]; then
        ${FF} $1 </dev/null 1>/dev/null 2>/dev/null
    fi
done
exit 0

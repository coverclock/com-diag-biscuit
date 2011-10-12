#!/bin/bash
################################################################################
# Copyright 2011 by the Digital Aggregates Corporation, Colorado, USA
# Licensed under the terms in README.h
# Chip Overclock <coverclock@diag.com>
# http://www.diag.com/navigation/downloads/Biscuit
# Install (if using /sbin/hotplug and /etc/hotplug.d):
#  cp biscuit.hotplug.sh /etc/hotplug.d/block/biscuit.hotplug
#  chmod 755 /etc/hotplug.d/block/biscuit.hotplug
# Or (if not):
#  cp biscuit.hotplug.sh /sbin/hotplug
#  chmod 755 /sbin/hotplug
################################################################################

NAM="`basename $0`"
TMP="/tmp"
BIS="/usr/local/bin/biscuit"
DEV="/dev/`basename ${DEVNAME}`"

if [ "$1" != "block" ]; then
    exit 1
fi

if [ "${ACTION}" != "add" ]; then
    exit 2
fi

if [ -n "${BISCUITBIN}" ]; then
    BIS="${BISCUITBIN}/biscuit"
fi

if [ -x "${BIS}" ]; then
    exit 4
fi

DIR="`mktemp -d /tmp/${NAM}.XXXXXXXXXX`"
trap "umount ${DIR} && rm -rf ${DIR}" 1 2 3 15

if [ ! -d ${DIR} ]; then
    exit 5
fi

if mount -t auto -o async,relatime ${DEV} ${DIR}; then
    ( cd ${DIR}; ${BIS} )
else
    rm -rf ${DIR}
    exit 6
fi

umount ${DIR}
rm -rf ${DIR}

exit 0

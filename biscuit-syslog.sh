#!/bin/bash
################################################################################
# Copyright 2011 by the Digital Aggregates Corporation, Colorado, USA
# Licensed under the terms in README.h
# Chip Overclock <coverclock@diag.com>
# http://www.diag.com/navigation/downloads/Biscuit
# Tarballs up /var/log and stores it WORKING.
################################################################################
NAME="`basename $0`"
echo "${NAME}: begin"
WORKING="`pwd`"
SOURCE="`dirname $0`"
[ -z "${SOURCE}" ] && SOURCE="${WORKING}"
HOSTNAME="`uname -n`"
[ -z "${HOSTNAME}" ] && HOST="unknown"
MACHNAME="`uname -m`"
[ -z "${HOSTNAME}" ] && HOST="unknown"
MACHINEID="`ifconfig -a | awk '/HWaddr/ { gsub(/:/,"",$5); MID=MID $5; } END { print MID; }'`"
[ -z "${MACHINEID}" ] && MACADDRESS="XXXXXXXXXXXX"
TIMESTAMP="`date -u '+%Y%m%dT%H%M%S'`"
cd ${SOURCE}
PREFIX="${MACHNAME}-${HOSTNAME}-${MACHINEID}-${TIMESTAMP}"
tar -C /var/log -czf - . 1> ${WORKING}/${PREFIX}.tgz 2> /dev/null
sync
sync
sync
echo "${NAME}: end"
exit 0

#!/bin/bash
################################################################################
# Copyright 2011 by the Digital Aggregates Corporation, Colorado, USA
# Licensed under the terms in README.h
# Chip Overclock <coverclock@diag.com>
# http://www.diag.com/navigation/downloads/Biscuit
################################################################################
NAME="`basename $0`"
SOURCE="`dirname $0`"
[ -z "${SOURCE}" ] && SOURCE="."
WORKING="`pwd`"
echo "${NAME}: PATH=\"${PATH}\"" 1>&2
echo "${NAME}: LD_LIBRARY_PATH=\"${LD_LIBRARY_PATH}\"" 1>&2
echo "${NAME}: HOME=\"${HOME}\"" 1>&2
echo "${NAME}: SOURCE=\"${SOURCE}\"" 1>&2
echo "${NAME}: WORKING=\"${WORKING}\"" 1>&2
rm -f ${WORKING}/biscuit-unittest3a.dat
[ -f ${SOURCE}/biscuit-unittest3a.txt ] && touch ${WORKING}/biscuit-unittest3a.dat || exit 1
rm -f ${WORKING}/biscuit-unittest3b.dat
[ -f ${SOURCE}/subdir/biscuit-unittest3b.txt ] && touch ${WORKING}/biscuit-unittest3b.dat || exit 2
exit 0

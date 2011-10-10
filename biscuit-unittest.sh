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
echo "${NAME} PATH=\"${PATH}\"" 1>&2
echo "${NAME} LD_LIBRARY_PATH=\"${LD_LIBRARY_PATH}\"" 1>&2
echo "${NAME} HOME=\"${HOME}\"" 1>&2
ls -lR ${HOME} 1>&2
echo "${NAME} SOURCE=\"${SOURCE}\"" 1>&2
ls -lR ${SOURCE} 1>&2
echo "${NAME} WORKING=\"${WORKING}\"" 1>&2
ls -lR ${WORKING} 1>&2
rm -f ${WORKING}/biscuit-unittest.dat
[ -f ${SOURCE}/millay.txt ] || exit 1
touch ${WORKING}/biscuit-unittest.dat
exit 0

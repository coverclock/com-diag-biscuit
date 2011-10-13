#!/bin/bash
################################################################################
# Copyright 2011 by the Digital Aggregates Corporation, Colorado, USA
# Licensed under the terms in README.h
# Chip Overclock <coverclock@diag.com>
# http://www.diag.com/navigation/downloads/Biscuit
################################################################################
NAME="`basename $0`"
echo "${NAME}: begin"
WORKING="`pwd`"
SOURCE="`dirname $0`"
[ -z "${SOURCE}" ] && SOURCE="."
echo "${NAME}: PATH=\"${PATH}\"" >${WORKING}/biscuit-unittest3.txt
echo "${NAME}: LD_LIBRARY_PATH=\"${LD_LIBRARY_PATH}\"" >>${WORKING}/biscuit-unittest3.txt
echo "${NAME}: HOME=\"${HOME}\"" >>${WORKING}/biscuit-unittest3.txt
echo "${NAME}: SOURCE=\"${SOURCE}\"" >>${WORKING}/biscuit-unittest3.txt
echo "${NAME}: WORKING=\"${WORKING}\"" >>${WORKING}/biscuit-unittest3.txt
rm -f ${WORKING}/biscuit-unittest3a.txt; [ -f ${SOURCE}/biscuit-unittest3a.txt ] && cp ${SOURCE}/biscuit-unittest3a.txt ${WORKING}
rm -f ${WORKING}/biscuit-unittest3b.txt; [ -f ${SOURCE}/subdir/biscuit-unittest3b.txt ] && cp ${SOURCE}/subdir/biscuit-unittest3b.txt ${WORKING}
echo "${NAME}: end"
exit 0

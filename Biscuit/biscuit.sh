#!/bin/bash
################################################################################
# Copyright 2011 by the Digital Aggregates Corporation, Colorado, USA
# Licensed under the terms in README.h
# Chip Overclock <coverclock@diag.com>
# http://www.diag.com/navigation/downloads/Biscuit
################################################################################

NAM="biscuit"
TMP="/tmp"
GPG="/usr/local/bin/gpg"
ETC="/usr/local/etc"
CWD="`pwd`"
FIL="${CWD}/${NAM}"
LOG="/usr/bin/logger"
FAC="user"
LEV="notice"
CON="/dev/console"
SUD="/usr/bin/sudo"

if [ -f /no${NAM} ]; then
    exit 1
fi

if [ ! -f ${FIL} ]; then
    exit 2
fi

if [ -z "${EUID}" ]; then
    SUD=""
elif [ ${EUID} -eq 0 ]; then
    SUD=""
elif [ ! -x ${SUD} ]; then
    SUD=""
else
    :
fi

MNT="`mktemp -d ${TMP}/${NAM}.XXXXXX`"
trap "sudo umount ${MNT}; rm -rf ${MNT}; exit 3" 1 2 3 15
${SUD} mount -t tmpfs none ${MNT}
if [ $? -ne 0 ]; then
    rm -rf ${MNT}
    exit 4
fi

if [ -z "${EUID}" ]; then
    OWN=""
elif [ ${EUID} -eq 0 ]; then
    OWN="-R root"
else
    OWN=""
fi

${GPG} --homedir ${ETC} --batch --quiet --passphrase-file ${ETC}/passphrase.txt --decrypt ${FIL} | bunzip2 -c - | ( cd ${MNT}; cpio -i ${OWN} --quiet )
if [ $? -ne 0 ]; then
    ${SUD} umount ${MNT}
    rm -rf ${MNT}
    exit 5
fi

if [ ! -x ${MNT}/${NAM} ]; then
    ${SUD} umount ${MNT}
    rm -rf ${MNT}
    exit 6
fi

if [ ! -z "${PS1}" ]; then
    OUT="cat 1>&2"
elif [ -x ${LOG} ]; then
    OUT="${LOG} -i -p ${FAC}.${LEV} -t ${NAM} 1>/dev/null 2>/dev/null"
elif [ -c ${CON} ]; then
    OUT="tee ${CON} 1>/dev/null 2>/dev/null"
else
    OUT="cat 1>/dev/null 2>/dev/null"
fi

export PATH=${MNT}:${PATH}
export LD_LIBRARY_PATH=${MNT}:${LD_LIBRARY_PATH}
${MNT}/${NAM} < /dev/null 2>&1 | ${OUT}

${SUD} umount ${MNT}
rm -rf ${MNT}

exit 0

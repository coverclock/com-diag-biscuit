#!/bin/bash
################################################################################
# Copyright 2011 by the Digital Aggregates Corporation, Colorado, USA
# Licensed under the terms in README.h
# Chip Overclock <coverclock@diag.com>
# http://www.diag.com/navigation/downloads/Biscuit
# If a biscuit binary file exists in the current directory, decrypts it,
# decompresses it, and unpacks it into a temporary directory, and if a biscuit
# executable exists in that temporary directory, executes it.
################################################################################

NAM="biscuit"
TMP="/tmp"
GPG="/usr/local/bin/gpg"
ETC="/usr/local/etc"
LOG="/usr/bin/logger"
FAC="user"
LEV="notice"
CON="/dev/console"
TTY="/dev/tty"

NOB="/no${NAM}"
CWD="`pwd`"
DIR="${TMP}/${NAM}.XXXXXXXXXX"
FIL="${CWD}/${NAM}.bin"

if [ -f ${NOB} ]; then
    exit 2
fi

if [ ! -f ${FIL} ]; then
    exit 3
fi

MNT="`mktemp -d ${DIR}`"

if [ -z "${EUID}" ]; then
    MOU=":"
    OWN=""
    UMO="rm -rf ${MNT}"
elif [ ${EUID} -eq 0 ]; then
    MOU="mount -t tmpfs none ${MNT}"
    OWN="-R root"
    UMO="umount ${MNT}; rm -rf ${MNT}"
else
    MOU=":"
    OWN=""
    UMO="rm -rf ${MNT}"
fi

trap "eval ${UMO}; exit 4" 1 2 3 15
${MOU}
if [ $? -ne 0 ]; then
    rm -rf ${MNT}
    exit 5
fi

if [ ! -z "${BISCUITBIN}" ]; then
    GPG="${BISCUITBIN}/gpg"
fi

if [ ! -z "${BISCUITETC}" ]; then
    ETC="${BISCUITETC}"
fi

# busybox cpio lacks "-R user" and "--quiet".
${GPG} --homedir ${ETC} --batch --quiet --passphrase-file ${ETC}/passphrase.txt --decrypt ${FIL} | bunzip2 -c - | ( cd ${MNT}; cpio -id 1>/dev/null 2>/dev/null )
if [ $? -ne 0 ]; then
    eval ${UMO}
    exit 6
fi

if [ ! -x ${MNT}/${NAM} ]; then
    eval ${UMO}
    exit 7
fi

if [ -z "${EUID}" ]; then
    OUT="tee ${TTY}"
elif [ ${EUID} -ne 0 ]; then
    OUT="tee ${TTY}"
elif [ -x ${LOG} ]; then
    # busybox logger lacks "-i".
    OUT="${LOG} -t ${NAM} -p ${FAC}.${LEV}"
elif [ -c ${CON} ]; then
    OUT="tee ${CON}"
else
    OUT="tee ${TTY}"
fi

export PATH=${MNT}:${PATH}
export LD_LIBRARY_PATH=${MNT}:${LD_LIBRARY_PATH}
${MNT}/${NAM} </dev/null 2>&1 | ${OUT} 1>/dev/null 2>/dev/null

eval ${UMO}

exit 0

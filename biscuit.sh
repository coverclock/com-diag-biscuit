#!/bin/bash
################################################################################
# Copyright 2011 by the Digital Aggregates Corporation, Colorado, USA
# Licensed under the terms in README.h
# Chip Overclock <coverclock@diag.com>
# http://www.diag.com/navigation/downloads/Biscuit
# If a biscuit binary file exists in the current directory, decrypts it,
# decompresses it, and unpacks it into a temporary directory, and if a biscuit
# executable exists in that temporary directory, executes it.
# Install (or choose another directory):
#  cp biscuit.sh /usr/local/bin/biscuit
#  chmod 755 /usr/local/bin/biscuit
# Decide whether you want to add biscuit to the sudo-capable commands to allow
# otherwise unprivileged users to invoke it to run a biscuit.bin manually.
################################################################################

NAM="biscuit"
TMP="/tmp"
GPG="/usr/local/bin/gpg"
ETC="/usr/local/etc/gnupg"
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
    exit 1
fi

if [ ! -f ${FIL} ]; then
    exit 2
fi

MNT="`mktemp -d ${DIR}`"
chmod 700 ${MNT}

grep -q tmpfs /proc/filesystems
if [ $? -ne 0 ]; then
    MOU="true"
    UMO="true"
elif [ -z "${EUID}" ]; then
    MOU="true"
    UMO="true"
elif [ ${EUID} -ne 0 ]; then
    MOU="true"
    UMO="true"
else
    MOU="mount -t tmpfs -o async,relatime none ${MNT}"
    UMO="umount ${MNT}"
fi

trap "${UMO} && rm -rf ${MNT}; exit 3" 1 2 3 15
${MOU}
if [ $? -ne 0 ]; then
    rm -rf ${MNT}
    exit 4
fi

if [ -n "${BISCUITBIN}" ]; then
    GPG="${BISCUITBIN}/gpg"
fi

if [ -n "${BISCUITETC}" ]; then
    ETC="${BISCUITETC}"
fi

# busybox cpio lacks "-R user" and "--quiet".
${GPG} --homedir ${ETC} --batch --quiet --passphrase-file ${ETC}/passphrase.txt --decrypt <${FIL} | bunzip2 -c - | ( cd ${MNT}; exec cpio -id >/dev/null )
if [ $? -ne 0 ]; then
    ${UMO} && rm -rf ${MNT}
    exit 5
fi

if [ ! -x ${MNT}/${NAM} ]; then
    ${UMO} && rm -rf ${MNT}
    exit 6
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
${MNT}/${NAM} </dev/null 2>&1 | ${OUT} >/dev/null

${UMO} && rm -rf ${MNT}

exit 0

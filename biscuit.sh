#!/bin/bash
################################################################################
# Copyright 2011 by the Digital Aggregates Corporation, Colorado, USA
# Licensed under the terms in README.h
# Chip Overclock <coverclock@diag.com>
# http://www.diag.com/navigation/downloads/Biscuit
# Usage
#  biscuit [ -C directory ] [ -f package ] [ -? ]
# Abstract
#  If a biscuit binary package exists in the current directory, decrypt it,
#  decompress it, and unpack it into a temporary directory, and if a biscuit
#  executable exists in that temporary directory, execute it. A biscuit binary
#  package can be specified to override the default behavior ("-f"), as can a
#  directory to change to prior to executing the biscuit executable ("-C").
#  Note that even if the default directory is overridden ("-C"), the biscuit
#  binary package is still expected in the current directory unless it too is
#  overridden ("-f"); this conforms to how other utilities work. All behavior
#  can be suppressed by the presence of a /nobiscuit file, which is a way to
#  immunize a particular system, temporarily or permanently, against biscuits.
# Install (for example):
#  install -m 755 biscuit.sh /usr/local/bin
# Caveats
#  Decide whether you want to add biscuit to the sudo-eligible commands to
#  allow otherwise unprivileged users to invoke it to run a biscuit package
#  manually. Under no circumstances should you make the biscuit command set-uid
#  root; that's just crazy talk.
################################################################################

# These are default values. By all means change them to meet your own
# requirements.

NAM="`basename $0`"
TMP="/tmp"
GPG="/usr/local/bin/gpg"
ETC="/usr/local/etc/gnupg"
LOG="/usr/bin/logger"
FAC="user"
LEV="notice"
CON="/dev/console"
TTY="/dev/tty"

# These are derived values.

NOB="/no${NAM}"
CWD="`pwd`"
DIR="${TMP}/${NAM}.XXXXXXXXXX"
FIL="${CWD}/${NAM}.bin"

# If the file /nobiscuit exists, this system has been immunized
# against biscuits. This file is expected to be in the root directory
# because then we can build embedded systems that are immunized right
# from boot, even if they are running from RAM disk or from XIP flash.

if [ -f ${NOB} ]; then
    exit 1
fi

# Parse the command line.

while getopts "?C:f:" OPT; do
    case "${OPT}" in
    C)      CWD="${OPTARG}";;
    f)      FIL="${OPTARG}";;
    [?])    echo "Usage: ${NAM} [ -C ${CWD} ] [ -f ${FIL} ] [ -? ]" 1>&2; exit 2;;
    esac
done

# Gotta have a current working directory. By default this is the directory
# from which this script is executed. But it could be something else.

if [ ! -d ${CWD} ]; then
    exit 3
fi

# Gotta have a biscuit binary package. By default its name is biscuit.bin. But
# it could be something else.

if [ ! -f ${FIL} ]; then
    exit 4
fi

# Gets us a temporary mount point whose name is guaranteed to be unique. Change
# its mode so onlookers can't gawk at what we're doing or change stuff that
# comes out of the package.

MNT="`mktemp -d ${DIR}`"
chmod 700 ${MNT}

# See if tmpfs (temporary RAM disk file system) is available and if we are
# likely to be able to use it. If not, then we just unpack directly into
# the directory. Embedded systems may have no read/write storage other than
# RAM disk. This limits the size of biscuit packages we can use.

grep -q tmpfs /proc/filesystems
if [ $? -ne 0 ]; then
    MOU="true"
    RMD="rm -rf ${MNT}"
    UMO="true"
elif [ -z "${EUID}" ]; then
    MOU="true"
    RMD="rm -rf ${MNT}"
    UMO="true"
elif [ ${EUID} -ne 0 ]; then
    MOU="true"
    RMD="rm -rf ${MNT}"
    UMO="true"
else
    MOU="mount -t tmpfs -o async,relatime none ${MNT}"
    RMD="rmdir ${MNT}"
    UMO="umount ${MNT}"
fi

${MOU}
if [ $? -ne 0 ]; then
    RMD="rm -rf ${MNT}"
    UMO="true"
fi

trap "${UMO}; ${RMD}; exit 5" 1 2 3 15

# We allow environmental variables to override where we expect to find GPG and
# its keys. This expedites testing, and doesn't seem like a huge security hole.
# But feel free to remove this if it makes you nervous.

if [ -n "${BISCUITBIN}" ]; then
    GPG="${BISCUITBIN}/gpg"
fi

if [ -n "${BISCUITETC}" ]; then
    ETC="${BISCUITETC}"
fi

# Decrypt the biscuit package, decompress it, and unpack it into the temporary
# directory. This is done in a pipeline so temporary files don't clutter up
# what little space we have.

# busybox cpio lacks "-R user" and "--quiet".
${GPG} --homedir ${ETC} --batch --quiet --passphrase-file ${ETC}/passphrase.txt --decrypt <${FIL} | bunzip2 -c - | ( cd ${MNT}; exec cpio -id >/dev/null )
if [ $? -ne 0 ]; then
    ${UMO}
    ${RMD}
    exit 6
fi

# Gotta have an executable biscuit script or binary.

if [ ! -x ${MNT}/${NAM} ]; then
    ${UMO}
    ${RMD}
    exit 7
fi

# Figure out if there's somewhere we can sent the output of the executable.
# Maybe we can use the system log, the console, or the current terminal.

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

# The biscuit executable may come with other scripts or executables, shared
# libraries, or other collateral in the package. The current working directory
# points to where we found the package (for example, a USB drive) in case the
# executable wants to put something there, and the temporary directory can be
# derived from the directory portion of the executable's name.

export PATH=${MNT}:${PATH}
export LD_LIBRARY_PATH=${MNT}:${LD_LIBRARY_PATH}
( cd ${CWD}; exec ${MNT}/${NAM} </dev/null 2>&1 ) | ${OUT} >/dev/null

# Clean up and we're done. We're finished with the temporary directory and all
# its contents. But the biscuit executable could have left something in its
# current working directory.

${UMO}
${RMD}

exit 0

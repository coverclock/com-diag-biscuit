#!/bin/bash
################################################################################
# Copyright 2011 by the Digital Aggregates Corporation, Colorado, USA
# Licensed under the terms in README.h
# Chip Overclock <coverclock@diag.com>
# http://www.diag.com/navigation/downloads/Biscuit
# Install:
#  cp /sbin/hotplug /sbin/hotplug.bak
#  cp hotplug-unittest4.sh /sbin/hotplug
#  chmod 755 /sbin/hotplug
#  cp printenv /usr/local/bin/printenv # (if your BusyBox lacks printenv)
#  chmod 755 /usr/local/bin/printenv
################################################################################
printenv | awk -v NAME="$0" -v ARGS="$*" '{ print NAME, ARGS, $0; }' > /dev/ttyS2
exit 0

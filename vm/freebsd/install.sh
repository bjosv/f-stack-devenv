#!/bin/sh
set -e
set -x

# Install deps
pkg install -y git

# Get source (~7min)
git clone -b stable/13 https://git.freebsd.org/src.git /usr/src
cd /usr/src
git config pull.ff only
# or
# git clone -b stable/13 --depth 1 https://git.freebsd.org/src.git /usr/src
# Get all later: git pull --unshallow

#===========================
# Install from source
# From: FreeBSD 13.0-STABLE (GENERIC) #0 stable/13-n248936-972796d007c: Thu Jan 13 02:34:59 UTC 2022
# To:   FreeBSD 13.0-STABLE (GENERIC) #0 stable/13-n249026-eccfee8330e: Tue Jan 18 14:27:10 UTC 2022
#===========================
# Compile the new compiler and a few related tools, then use the new compiler
# to compile the rest of the new world. The result is saved to /usr/obj.
# ~55min
#make -j8 buildworld

# Use the new compiler residing in /usr/obj to build the new kernel, and install it
# ~6min, uses ~3GB
#make -j8 kernel

# ~2min
# make installworld

# Merge config files
#mergemaster -Ui

# Use new system
#shutdown -r now
#cd /usr/src
#make check-old

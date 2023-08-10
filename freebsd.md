# FreeBSD

## Prepare: setup VM using Vagant

```
cd <repo>/vm/freebsd/
vagrant up
vagrant ssh
sudo su
cd /usr/src/
```

## Build

In FreeBSD, the term “world” includes the kernel, core system binaries, libraries, programming files, and built-in compiler.
The order in which these components are built and installed is important.

```
cd /usr/src/

> optional:
git co main
make cleanworld

# Compile the new compiler and a few related tools, then use the new compiler
# to compile the rest of the new world. The result is saved to /usr/obj.
# ~55min
make -j8 buildworld

# Use the new compiler residing in /usr/obj to build the new kernel, and install it
# ~6min, uses ~3GB
make -j8 buildkernel

# ~2min
make installworld

# Merge config files
mergemaster -Ui

# Use new system
shutdown -r now
cd /usr/src
make check-old
```

## Enable kernel modules
```
# FreeBSD 13, SCTP support was shifted to a module -- sctp.ko

sctp_load="YES" to /boot/loader.conf
or
kld_list="sctp" to /etc/rc.conf
or
kldload sctp

# Show loaded modules
kldstat

* parameter tunings in /etc/sysctl.conf are only applied if the SCTP module
  is loaded from /bootl/loader.conf.
* If the module is not loaded yet, a user must have root privileges to run
  a program using SCTP sockets.
```

### Setup VM manually
https://freebsdfoundation.org/freebsd-project/resources/installing-freebsd-with-virtualbox/

```
> Install tools
pkg install lang/gcc

> Get source
su
cd /usr/src
svnlite checkout https://svn.freebsd.org/base/head .

> or
git clone https://git.freebsd.org/src.git /usr/src
git config pull.ff only
git pull
```

## Links

PRs: https://docs.freebsd.org/en/articles/pr-guidelines/

https://docs.freebsd.org/en/articles/committers-guide/#git-primer
Git WG: https://github.com/bsdimp/freebsd-git-docs/

http://bsdimp.blogspot.com/2020/10/freebsd-git-primer-for-users.html

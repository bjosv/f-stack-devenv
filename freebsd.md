# FreeBSD

## Prepare

Using VM
https://freebsdfoundation.org/freebsd-project/resources/installing-freebsd-with-virtualbox/
but setup a larger number of CPUs

Setup
- ssh keys for git

Install tools
```
pkg install lang/gcc
```

## Get source
```
su
cd /usr/src
svnlite checkout https://svn.freebsd.org/base/head .
```

or
```
git clone https://git.freebsd.org/src.git /usr/src
git config pull.ff only
git pull

```

## Build

In FreeBSD, the term “world” includes the kernel, core system binaries, libraries, programming files, and built-in compiler.
The order in which these components are built and installed is important.

```
export $NUMBER_OF_PROCESSORS=$(sysctl hw.ncpu | tr -d 'a-z.: ')

sudo make -j${NUMBER_OF_PROCCESORS} buildkernel KERNCONF=UFFIE -DNO_CLEAN
```

## Enable kernel modules
```
sctp_load="YES" to /boot/loader.conf
or
kld_list="sctp" to /etc/rc.conf
or
kldload sctp

* parameter tunings in /etc/sysctl.conf are only applied if the SCTP module
  is loaded from /bootl/loader.conf.
* If the module is not loaded yet, a user must have root privileges to run
  a program using SCTP sockets.
```

## Links

PRs: https://docs.freebsd.org/en/articles/pr-guidelines/

https://docs.freebsd.org/en/articles/committers-guide/#git-primer
Git WG: https://github.com/bsdimp/freebsd-git-docs/

http://bsdimp.blogspot.com/2020/10/freebsd-git-primer-for-users.html

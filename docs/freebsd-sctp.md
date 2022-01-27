# SCTP in FreeBSD

## Install module
kldload sctp

## SCTP code / module
> Enabled via kernel option: SCTP_SUPPORT
/usr/src/sys/modules/sctp/Makefile
/usr/src/sys/netinet/sctp_module.c
/usr/src/sys/netinet/sctp...
/usr/src/sys/netinet6/sctp...

### Socket create
sys/netinet/sctp_usrreq.c:      .pru_attach = sctp_attach,
sys/netinet/sctp_usrreq.c:      .pru_sosend = sctp_sosend,

## Default values
sb_lowat='2048'
? max send buffersize: 54400 -> 67768 bytes in total

## Interesting commits

### sendfile
https://marc.info/?l=freebsd-arch&m=140135887226056&w=2
- Netflix and Nginx: improving FreeBSD wrt sending large amounts of static data via HTTP.
- new sendfile impl, no block on I/O read blocking
- Split of socket buffer sb_cc field into sb_acc and sb_ccc
  sb_acc - "available character count"
  sb_ccc - "claimed character count"
  - This allows us to write data to a socket, that is not ready yet.
  - The data sits in the socket, consumes its space, and keeps itself in the right order with earlier or later writes to socket.
  - But it can be send only after it is marked as ready.

https://github.com/freebsd/freebsd-src/commit/0f9d0a73a495
Nov 30, 2014
  Merge from projects/sendfile
  - SCTP has its own sockbufs.
  - Unfortunately, FreeBSD stack doesn't yet allow protocol specific sockbufs.
  - Thus, SCTP does some hacks to make itself compatible with FreeBSD: it manages sockbufs on its own,
    but keeps sb_cc updated to inform the stack of amount of data in them.
  - The new notion of "not ready" data isn't supported by SCTP.

  -> Not ready buffers

https://github.com/freebsd/freebsd-src/commit/4e88d37a2a73
Dec 2, 2014 - Introduce macro: #define sb_cc sb_ccc

https://github.com/freebsd/freebsd-src/commit/5ba11c4c2ef4
https://github.com/freebsd/freebsd-src/commit/975c975bf0f1
Mar 11, 2015 - Update macro and comment:
  It seems that sb_acc is a better replacement for sb_cc than sb_ccc. At
  least it unbreaks the use of select() for SCTP sockets.

https://github.com/freebsd/freebsd-src/commit/db4493f7b649
  sendfile() does currently not support SCTP sockets

## Run tests
See: https://bugs.freebsd.org/bugzilla/show_bug.cgi?id=260116

### Setup SCTP and network
kldload sctp
ifconfig lo0 inet 127.0.0.2/32 alias
ifconfig lo0 inet 127.0.0.3/32 alias
ifconfig lo0 inet 127.0.0.4/32 alias
ifconfig lo0 inet 127.0.0.5/32 alias
ifconfig lo0 inet 127.0.0.6/32 alias
ifconfig lo0 inet 127.0.0.7/32 alias

### Build and run
cd /root/sctp-test/
g++ -o client client.cpp utils.cpp
g++ -o server server.cpp utils.cpp

/root/sctp-test/server --poll --ipv4 --sctp --test-pollout
/root/sctp-test/client --poll --ipv4 --sctp --test-pollout
grep BJOSV /var/log/messages


## Links
Userland SCTP details
https://www.mail-archive.com/freebsd-net@freebsd.org/msg62806.html

Linux kernel SCTP project
https://github.com/sctp

SCTP over UDP in the Linux kernel
https://developers.redhat.com/articles/2021/06/04/easier-way-go-sctp-over-udp-linux-kernel

https://lists.freebsd.org/pipermail/svn-src-head/2014-November/065503.html
https://marc.info/?l=freebsd-commits-all&m=141737396609331&w=2
https://git.furworks.de/opensourcemirror/opnsense-src/commit/4e88d37a2a73e1b859e8dd89f94f318ae7933230
https://pt.slideshare.net/facepalmtarbz2/new-sendfile-in-english?smtNoRedir=1

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
5ba11c4c2ef4
975c975bf0f1
  It seems that sb_acc is a better replacement for sb_cc than sb_ccc. At
  least it unbreaks the use of select() for SCTP sockets.

db4493f7b64926d0c9b564bd15119382318a6584
  sendfile() does currently not support SCTP sockets

4e88d37a2a73
  Introduce macro

## Run tests
See: https://bugs.freebsd.org/bugzilla/show_bug.cgi?id=260116

### Setup network
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
https://lists.freebsd.org/pipermail/svn-src-head/2014-November/065503.html
https://marc.info/?l=freebsd-commits-all&m=141737396609331&w=2
https://git.furworks.de/opensourcemirror/opnsense-src/commit/4e88d37a2a73e1b859e8dd89f94f318ae7933230
https://pt.slideshare.net/facepalmtarbz2/new-sendfile-in-english?smtNoRedir=1

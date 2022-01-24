# FreeBSD development

## Install
pkg install lang/gcc

## Build and install
su
cd /usr/src
make -j8 kernel
rm /var/log/messages
touch /var/log/messages
shutdown -r now

## Run FreeBSD tests
make checkworld

## Build and reinstall libc
cd /usr/src/lib/libc
make obj all install

## Debug kernel modules
> printf() will go to: /var/log/messages
> uprintf() goes to shell

## Log from process
https://forums.freebsd.org/threads/using-the-syslog-api.57072/

## Maillist
https://lists.freebsd.org/archives/freebsd-net/

## Links
https://www.netbsd.org/docs/internals/en/chap-networking-core.html


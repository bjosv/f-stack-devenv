# f-stack development environment

## Prepare

### Install deps
```
sudo apt-get install -y make meson git gcc
sudo apt-get install -y openssl libssl-dev
sudo apt-get install -y linux-headers-$(uname -r) bc libnuma1 libnuma-dev libpcre3 libpcre3-dev zlib1g-dev

pip3 install pyelftools --upgrade
```

### Prepare source
```
git clone https://github.com/F-Stack/f-stack.git

# To "Compile dpdk in virtual machine":
sed -i 's/pci_intx_mask_supported/true || pci_intx_mask_supported/' f-stack/dpdk/kernel/linux/igb_uio/igb_uio.c
```

## Build

### DPDK
```
# For branch 1.21: using Make and a target directory (always uses gcc?)
make -C dpdk V=1 install T=x86_64-native-linuxapp-gcc

# For dev branch: create build files in directory 'build'
cd dpdk
meson -Denable_kmods=true -Ddisable_libs=flow_classify build
ninja -C build
sudo ninja -C build install
```

### f-stack lib
```
# For branch 1.21
cd f-stack
export FF_PATH=$(pwd)
export FF_DPDK=$(pwd)/dpdk/x86_64-native-linuxapp-gcc
CC=gcc-14 CXX=g++-14 make -C lib

# For dev branch:
cd f-stack
export FF_PATH=$(pwd)
export PKG_CONFIG_PATH=/usr/local/lib/x86_64-linux-gnu/pkgconfig
CC=gcc-14 CXX=g++-14 make -C lib

sudo FF_PATH=$(pwd) PKG_CONFIG_PATH=/usr/local/lib64/pkgconfig make -C lib install
```

### Tools
```
cd f-stack/tools

# "Updates for Ubuntu"
sed -i 's/\\#define/#define/'  netstat/Makefile
make
```

### Examples
```
cd f-stack/examples
make
```

### Issues
```
## In apps/nginx:

src/event/modules/ngx_ff_module.c:549:1: error: conflicting types for ‘gettimeofday’
  549 | gettimeofday(struct timeval *tv, struct timezone *tz)
      | ^~~~~~~~~~~~
In file included from src/event/modules/ngx_ff_module.c:73:
/usr/include/x86_64-linux-gnu/sys/time.h:66:12: note: previous declaration of ‘gettimeofday’ was here
   66 | extern int gettimeofday (struct timeval *__restrict __tv,
      |            ^~~~~~~~~~~~
make[1]: *** [objs/Makefile:849: objs/src/event/modules/ngx_ff_module.o] Error 1
make[1]: Leaving directory '/home/bjorn/git/f-stack/app/nginx-1.16.1'

## In tools:

nhops.c: In function ‘print_nhop_entry_sysctl’:
nhops.c:286:39: error: ‘%s’ directive output may be truncated writing up to 127 bytes into a region of size 64 [-Werror=format-truncation=]
  286 |   snprintf(gw_addr, sizeof(gw_addr), "%s/resolve", iface_name);
      |                                       ^~           ~~~~~~~~~~
nhops.c:286:3: note: ‘snprintf’ output between 9 and 136 bytes into a destination of size 64
  286 |   snprintf(gw_addr, sizeof(gw_addr), "%s/resolve", iface_name);
      |   ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
cc1: all warnings being treated as errors
make[1]: *** [<builtin>: nhops.o] Error 1
```

### Other

#### Run DPDK in virtualbox (6.1.26 Ubuntu)

```
cd vm/dpdk/
vagrant up
vagrant ssh
cd dpdk-21.11/examples/helloworld/
make
sudo ./build/helloworld --log-level lib.eal:debug
(Probing takes ~2 minutes... ??)
```

## Deps
### FreeBSD
v1.22 - Upgrade to FreeBSD-releng-13.0
v1.20 - Changeset from Freebsd releng-11.0/release-11.1/release-11.2/release-11.3/release-12

### DPDK
dev     22.11.3
1.23    21.11.5
1.22.1  20.11.9
1.22    20.11.6
1.21.3  19.11.14 (branch 1.21)

## Links
https://github.com/F-Stack/f-stack/blob/dev/doc/F-Stack_Build_Guide.md

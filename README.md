# f-stack development environment

## Prepare

### Install deps
```
sudo apt-get install make meson git
sudo apt-get install gcc openssl libssl-dev linux-headers-$(uname -r) bc libnuma1 libnuma-dev libpcre3 libpcre3-dev zlib1g-dev python
sudo apt-get install -y python3-pyelftools python-pyelftools
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
cd f-stack/dpdk

meson -Denable_kmods=true build
ninja -C build
sudo ninja -C build install
```

### f-stack lib
```
cd f-stack
export FF_PATH=$(pwd)
export PKG_CONFIG_PATH=/usr/local/lib64/pkgconfig

make -C lib
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

## Links
https://github.com/F-Stack/f-stack/blob/dev/doc/F-Stack_Build_Guide.md

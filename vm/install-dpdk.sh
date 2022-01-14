#!/bin/sh
set -e
set -x
alias sudo="sudo -E"

export DPDK=dpdk-21.11
export DPDK_DIR=${PWD}/${DPDK}
export DPDK_IF=enp0s8

# https://doc.dpdk.org/guides/linux_gsg/sys_reqs.html
sudo apt-get -q update
sudo apt-get -q install -y build-essential git python meson ninja-build \
     python3-pyelftools libnuma-dev linux-headers-$(uname -r) \
     net-tools pkg-config
# To compile and use the bpf library.
#apt-get -q install -y libelf-dev

# Configure hugepages
# https://doc.dpdk.org/guides/linux_gsg/sys_reqs.html#use-of-hugepages-in-the-linux-environment
echo 1024 | sudo tee /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages
# Make the hugepages available for DPDK
sudo mkdir /mnt/huge
sudo mount -t hugetlbfs nodev /mnt/huge
grep Huge /proc/meminfo

# Get dpdk
wget -q http://fast.dpdk.org/rel/${DPDK}.tar.xz
tar xf ${DPDK}.tar.xz

# Get dpdk-kmods for igb_uio
git clone http://dpdk.org/git/dpdk-kmods
cp -r dpdk-kmods/linux/igb_uio ${DPDK}/kernel/linux/
cp meson.build ${DPDK}/kernel/linux/igb_uio/
sed -i "s/'kni'/'kni', 'igb_uio'/" ${DPDK}/kernel/linux/meson.build

# ?? Patch igb_uio for virtualbox needed ??
# https://github.com/F-Stack/f-stack/blob/dev/doc/F-Stack_Build_Guide.md#compile-dpdk-in-virtual-machine
sed -i 's/pci_intx_mask_supported/true || pci_intx_mask_supported/' ${DPDK}/kernel/linux/igb_uio/igb_uio.c

# Build and install dpdk
cd ${DPDK_DIR}
meson -Denable_kmods=true build
cd build
ninja
sudo ninja install
sudo ldconfig

# Linux drivers / Offload NIC
# https://doc.dpdk.org/guides/linux_gsg/linux_drivers.html
# https://doc.dpdk.org/guides/prog_guide/kernel_nic_interface.html
# Install kernel modules
sudo modprobe uio
sudo insmod ${DPDK_DIR}/build/kernel/linux/igb_uio/igb_uio.ko

# carrier=on is necessary otherwise need to be up <IF> via
# `echo 1 > /sys/class/net/<IF>/carrier`
sudo insmod ${DPDK_DIR}/build/kernel/linux/kni/rte_kni.ko carrier=on

# Print info
#ifconfig ${DPDK_IF}
#ethtool -i ${DPDK_IF}

sudo ifconfig ${DPDK_IF} down
sudo ${DPDK_DIR}/usertools/dpdk-devbind.py --bind=igb_uio ${DPDK_IF}
sudo ${DPDK_DIR}/usertools/dpdk-devbind.py --status


#sudo modprobe vfio-pci

#sudo /usr/bin/chmod a+x /dev/vfio
#sudo /usr/bin/chmod 0666 /dev/vfio/*
#sudo ${DPDK_DIR}/usertools/dpdk-devbind.py --bind=vfio-pci eth1
#sudo ${DPDK_DIR}/usertools/dpdk-devbind.py --status

# Example:
# sudo build/helloworld --log-level lib.eal:debug --block 0000:00:08.0

# Poll time ~173 s

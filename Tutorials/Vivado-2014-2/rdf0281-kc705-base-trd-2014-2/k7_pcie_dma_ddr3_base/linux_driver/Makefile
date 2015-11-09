#
#	Makefile for Xilinx Kintex-7 PCIe-DMA-DDR3 Base Targeted Reference Design
#

MKNOD = `awk '/xdma_stat/ {print $$1}' /proc/devices`

all::
		$(MAKE) -C xdma
		$(MAKE) -C xrawdata0
		$(MAKE) -C xrawdata1
		@echo "***** Driver Compiled *****"

clean::
		$(MAKE) -C xdma clean
		$(MAKE) -C xrawdata0 clean
		$(MAKE) -C xrawdata1 clean

insert:: xdma/xdma_k7.ko xrawdata0/xrawdata0.ko xrawdata1/xrawdata1.ko
		/sbin/insmod xdma/xdma_k7.ko; sleep 1
		/bin/mknod /dev/xdma_stat c $(MKNOD) 0
		/sbin/insmod xrawdata0/xrawdata0.ko; sleep 1
		/sbin/insmod xrawdata1/xrawdata1.ko
		@echo "***** Driver Loaded *****"

remove::
		/sbin/rmmod xrawdata1.ko; sleep 1
		/sbin/rmmod xrawdata0.ko; sleep 1; rm -f /dev/xdma_stat
		/sbin/rmmod xdma_k7.ko
		@echo "***** Driver Unloaded *****"


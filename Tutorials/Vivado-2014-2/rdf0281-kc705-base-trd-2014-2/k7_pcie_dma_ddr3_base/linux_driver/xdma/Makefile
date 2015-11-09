obj-m := xdma_base.c
obj-m += xdma.o
obj-m += xdma_bdring.o
obj-m += xdma_user.o
obj-m := xdma_k7.o
xdma_k7-objs :=  xdma_base.o xdma.o xdma_bdring.o xdma_user.o

KDIR= /lib/modules/$(shell uname -r)/build
ROOTDIR = $(PWD)

EXTRA_CFLAGS += -DK7_TRD -DX86_PC -DNWLDMA -DXENV_LINUX -DUSE_IO_MACROS -DXLITTLE_ENDIAN -DPCI_LINUX -I $(ROOTDIR)/xdma -I $(ROOTDIR)/include 

# Add the following to EXTRA_CFLAGS to enable interrupt mode
#-DTH_BH_ISR

all:
	$(MAKE) $(CFLAGS) -C $(KDIR) SUBDIRS=$(PWD)/xdma 
	
clean: 
	   rm -rf *.o *.ko *.mod.* .c* .t* 

# LOGGING: ---------------------------------------------------------------
# Add to EXTRA_CFLAGS, based on the logging level desired:
# -DDEBUG_NORMAL: To enable normal logging levels 
# -DDEBUG_VERBOSE: To enable verbose logging levels 

obj-m := sguser.c
obj-m := xrawdata0.o
xrawdata0-objs :=  sguser.o 

KDIR= /lib/modules/$(shell uname -r)/build
ROOTDIR = $(PWD)
EXTRA_CFLAGS += -DK7_TRD -DX86_PC -DUSE_IO_MACROS -DNWLDMA -DXRAWDATA0  -I $(ROOTDIR)/xrawdata0/ -I $(ROOTDIR)/include/ 
#EXTRA_CFLAGS += -DK7_TRD -DX86_PC -DUSE_IO_MACROS -DNWLDMA -DXRAWDATA0 -DDATA_VERIFY -I $(ROOTDIR)/xrawdata0/ -I $(ROOTDIR)/include/ 

all:
	$(MAKE) $(CFLAGS) -C $(KDIR) SUBDIRS=$(PWD)/xrawdata0 
	#$(MAKE) $(CFLAGS) -C $(KDIR) SUBDIRS=$(PWD)/xaui modules
clean: 
	   rm -rf *.o *.ko *.mod.* .c* .t*

# LOGGING: ---------------------------------------------------------------
# Add to EXTRA_CFLAGS, based on the logging level desired:
# -DDEBUG_NORMAL: To enable normal logging levels 
# -DDEBUG_VERBOSE: To enable verbose logging levels 
#

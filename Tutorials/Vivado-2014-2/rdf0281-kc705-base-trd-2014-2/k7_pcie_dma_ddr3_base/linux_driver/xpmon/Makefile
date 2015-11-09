
CC = gcc
CFLAGS = -DK7_TRD -DHARDWARE -I$(PWD) `pkg-config --cflags gtk+-2.0`
LFLAGS = `pkg-config --libs gtk+-2.0`

GUI_OBJS = xpmon.o
#-DHARDWARE
all = GUI

GUI:	$(GUI_OBJS)
	$(CC) -o xpmon $(CFLAGS) $(GUI_OBJS) $(LFLAGS)

xpmon.o:	ConfigGui.c ../include/xpmon_be.h ConfigGui.h
	$(CC) -c $(CFLAGS) -I ../include/ ConfigGui.c -o xpmon.o

clean:
	rm -f $(GUI_OBJS) xpmon *.exe *.out

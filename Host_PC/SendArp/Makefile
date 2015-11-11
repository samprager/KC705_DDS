CC=gcc

SRT =  send_arp.c
# SRC = 
OBJ = $(SRC:.c=.o) $(SRT:.c=.o)

CFLAGS = -Wall -g
LDFLAGS= -lpcap

send_arp: $(OBJ)
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS) 
	
send_arp.o: send_arp.c send_arp.h
	$(CC) $(CFLAGS) -c $<

clean:
	rm -f $(OBJ)


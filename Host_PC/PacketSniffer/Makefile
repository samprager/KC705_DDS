CC=gcc

SRT =  psniffer.c
# SRC = 
OBJ = $(SRC:.c=.o) $(SRT:.c=.o)

CFLAGS = -Wall -g
LDFLAGS= -lpcap

psniffer: $(OBJ)
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS) 
	
psniffer.o: psniffer.c psniffer.h
	$(CC) $(CFLAGS) -c $<

clean:
	rm -f $(OBJ)


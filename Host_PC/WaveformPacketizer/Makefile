CC=gcc

SRT =  pwave.c
# SRC = 
OBJ = $(SRC:.c=.o) $(SRT:.c=.o)

CFLAGS = -Wall -g
LDFLAGS= -lpcap

pwave: $(OBJ)
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS) 
	
pwave.o: pwave.c pwave.h
	$(CC) $(CFLAGS) -c $<

clean:
	rm -f $(OBJ)


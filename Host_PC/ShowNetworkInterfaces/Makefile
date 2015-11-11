CC=gcc

SRT =  showif.c
# SRC = 
OBJ = $(SRC:.c=.o) $(SRT:.c=.o)

CFLAGS = -Wall -g
LDFLAGS= 

showif: $(OBJ)
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS) 
	
showif.o: showif.c showif.h
	$(CC) $(CFLAGS) -c $<

clean:
	rm -f $(OBJ)


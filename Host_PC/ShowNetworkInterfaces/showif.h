
//
//  showif.h
//
//
//  Created by Sam Prager on 11/9/15.
//
//

#ifndef showif_h
#define showif_h

#include <stdio.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <net/if.h>
#include <netdb.h>

static void show_interface(int fd, const char *name);

static void list_interfaces(int fd, void (*show)(int fd, const char *name));

void show_all_interfaces(int family);

#endif /* showif_h */
#include <stdio.h>

/*
 * Because of potential incompatibility between 32-bit and 64-bit pcap files
 * check if this is a 64-bit compile and if so, emit a helpful message.
 */

main () {
    if (sizeof (long) != 4 || getenv("TEST64BIT")) {
	fprintf(stderr,
	    "\n\nIf output from Gulp is not compatible with "
	    "tcpdump or wireshark,\nPlease see: "
	    "http://staff.washington.edu/corey/gulp/gulp.html#64bit\n\n\n");
	sleep(5);
	}
    }

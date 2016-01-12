
//
//  psniffer.c
//
//
//  Created by Sam Prager on 11/9/15.
//
//

#include "psniffer.h"
#include <pcap.h>
#include <netinet/in.h>
#include <netinet/ip.h>
#include <net/if.h>
#include <netinet/if_ether.h>
#include <arpa/inet.h>

void pcap_fatal(const char *failed_in, const char *errbuf) {
    printf("Fatal Error in %s: %s\n", failed_in, errbuf);
    exit(1);
}

/* We've included the UDP header struct for your ease of customization.
 * For your protocol, you might want to look at netinet/tcp.h for hints
 * on how to deal with single bits or fields that are smaller than a byte
 * in length.
 *
 * Per RFC 768, September, 1981.
 */
struct UDP_hdr {
    u_short	uh_sport;		/* source port */
    u_short	uh_dport;		/* destination port */
    u_short	uh_ulen;		/* datagram length */
    u_short	uh_sum;			/* datagram checksum */
};


/* Some helper functions, which we define at the end of this file. */

/* Returns a string representation of a timestamp. */
const char *timestamp_string(struct timeval ts);

/* Report a problem with dumping the packet with the given timestamp. */
void problem_pkt(struct timeval ts, const char *reason);

/* Report the specific problem of a packet being too short. */
void too_short(struct timeval ts, const char *truncated_hdr);

/* dump_UDP_packet()
 *
 * This routine parses a packet, expecting Ethernet, IP, and UDP headers.
 * It extracts the UDP source and destination port numbers along with the UDP
 * packet length by casting structs over a pointer that we move through
 * the packet.  We can do this sort of casting safely because libpcap
 * guarantees that the pointer will be aligned.
 *
 * The "ts" argument is the timestamp associated with the packet.
 *
 * Note that "capture_len" is the length of the packet *as captured by the
 * tracing program*, and thus might be less than the full length of the
 * packet.  However, the packet pointer only holds that much data, so
 * we have to be careful not to read beyond it.
 */
void dump_UDP_packet(const unsigned char *packet, struct timeval ts,
                     unsigned int capture_len)
{
    struct ip *ip;
    struct UDP_hdr *udp;
    unsigned int IP_header_length;
    
    /* For simplicity, we assume Ethernet encapsulation. */
    if (capture_len < sizeof(struct ether_header))
    {
        /* We didn't even capture a full Ethernet header, so we
         * can't analyze this any further.
         */
        too_short(ts, "Ethernet header");
        return;
    }
    
    /* Skip over the Ethernet header. */
    packet += sizeof(struct ether_header);
    capture_len -= sizeof(struct ether_header);
    
    if (capture_len < sizeof(struct ip))
    { /* Didn't capture a full IP header */
        too_short(ts, "IP header");
        return;
    }
    
    ip = (struct ip*) packet;
    IP_header_length = ip->ip_hl * 4;	/* ip_hl is in 4-byte words */
    
    if (capture_len < IP_header_length)
    { /* didn't capture the full IP header including options */
        too_short(ts, "IP header with options");
        return;
    }
    
    
    if (ip->ip_p != IPPROTO_UDP)
    {
        problem_pkt(ts, "non-UDP packet");
        return;
    }
    
    /* Skip over the IP header to get to the UDP header. */
    packet += IP_header_length;
    capture_len -= IP_header_length;
    
    if (capture_len < sizeof(struct UDP_hdr))
    {
        too_short(ts, "UDP header");
        return;
    }
    
    udp = (struct UDP_hdr*) packet;
    
    printf("%s UDP src_port=%d dst_port=%d length=%d\n",
           timestamp_string(ts),
           ntohs(udp->uh_sport),
           ntohs(udp->uh_dport),
           ntohs(udp->uh_ulen));
    
}

void dump_packet(const unsigned char *packet, struct timeval ts,
                  unsigned int capture_len){
    for(int i=0;i<capture_len;i++)
        printf("%02x ",*(packet+i));
    printf("\n\n");
}


/* Note, this routine returns a pointer into a static buffer, and
 * so each call overwrites the value returned by the previous call.
 */
const char *timestamp_string(struct timeval ts)
{
    static char timestamp_string_buf[256];
    
    sprintf(timestamp_string_buf, "%d.%06d",
            (int) ts.tv_sec, (int) ts.tv_usec);
    
    return timestamp_string_buf;
}

void problem_pkt(struct timeval ts, const char *reason)
{
    fprintf(stderr, "%s: %s\n", timestamp_string(ts), reason);
}

void too_short(struct timeval ts, const char *truncated_hdr)
{
    fprintf(stderr, "packet with timestamp %s is truncated and lacks a full %s\n",
            timestamp_string(ts), truncated_hdr);
}

int main() {
    struct pcap_pkthdr header;
    const u_char *packet;
    char errbuf[PCAP_ERRBUF_SIZE];
    char *device;
    pcap_t *pcap_handle;
    int i;
    
    pcap_if_t *alldevsp, *currdevp;
    pcap_addr_t *curraddr;
    sa_family_t currfamily;
    pcap_findalldevs(&alldevsp,errbuf);
    currdevp = alldevsp;
    
    while((currdevp)!=NULL){
        printf("found dev %s\t", currdevp->name);
        printf("desc: %s\t",currdevp->description);
        //printf("addr: %s\t",curraddr->addr->sa_data);
        printf("flag: %u\n",currdevp->flags);
    
        
        curraddr = currdevp->addresses;
        while((curraddr)!=NULL){
            //printf("\t%s\taddr:", currdevp->name);
            currfamily = curraddr->addr->sa_family;
            
            if(currfamily == AF_INET){
                struct sockaddr_in *saddress_in = (struct sockaddr_in *)curraddr->addr;
                char ipAddress[INET_ADDRSTRLEN];
                inet_ntop(currfamily, &(saddress_in->sin_addr), ipAddress, INET_ADDRSTRLEN);
                printf("\tipv4:   %s",ipAddress);
            }
            else if(currfamily == AF_INET6){
                struct sockaddr_in6 *saddress_in = (struct sockaddr_in6 *)curraddr->addr;
                char ipAddress[INET6_ADDRSTRLEN];
                inet_ntop(currfamily, &(saddress_in->sin6_addr), ipAddress, INET6_ADDRSTRLEN);
                printf("\tipv6:   %s",ipAddress);
            }
            else if(currfamily == AF_LINK){
                printf("\tether:  ");
                for(int i=9;i<15;i++){
                    printf("%02x",(unsigned char) *(curraddr->addr->sa_data+i));
                    if(i<14) printf(":");
                }
            }
            //printf("\tfamily: %u\n",(unsigned int)currfamily);
            printf("\n");
            curraddr = curraddr->next;
        }

        currdevp = currdevp->next;
    }
    currdevp = alldevsp;
    
    //device = pcap_lookupdev(errbuf);
    device = "en4";
    if(device == NULL)
        pcap_fatal("pcap_lookupdev", errbuf);
    
    printf("Sniffing on device %s\n", device);
    
    pcap_handle = pcap_open_live(device, 4096, 1, 0, errbuf);
    if(pcap_handle == NULL)
        pcap_fatal("pcap_open_live", errbuf);
    
    for(i=0; i < 5; i++) {
        packet = pcap_next(pcap_handle, &header);
        printf("Got a %d byte packet\n", header.len);
        dump_UDP_packet(packet, header.ts, header.caplen);
        
        printf("Dumping entire %d byte packet\n", header.len);
        dump_packet(packet, header.ts, header.caplen);
    }
    /* Now just loop through extracting packets as long as we have
     * some to read.
     */
    /*
    while ((packet = pcap_next(pcap, &header)) != NULL)
        dump_UDP_packet(packet, header.ts, header.caplen);
    
    */

    
    pcap_close(pcap_handle);
    return 0;
    
}
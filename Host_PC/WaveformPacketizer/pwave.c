
//
//  pwave.c
//
//
//  Created by Sam Prager on 11/9/15.
//
//

#include "pwave.h"


void my_callback(u_char *user, const struct pcap_pkthdr *pkthdr, const u_char *packet) {
    
    int i = 0;
    int k = 0;
    
    for (i = 0; i < pkthdr->len; i++) {
        if ((i % 16) == 0) {
            fprintf(stdout, "\n%03x0\t", k);
            k++;
        }
        fprintf(stdout, "%02x ", packet[i]);
    }
    
    fprintf(stdout, "\n*******************************************************\n");
    
    u_char ethernet_packet[14];
    u_char ip_header[24];
    u_char udp_header[8];
    int udp_header_start = 34;
    int data_length;
    
    for (i = 0; i < 14; i++) {
        ethernet_packet[i] = packet[0 + i];
    }
    
    fprintf(stdout, "Destination Address\t\t%02X:%02X:%02X:%02X:%02X:%02X\n", ethernet_packet[0], ethernet_packet[1], ethernet_packet[2], ethernet_packet[3], ethernet_packet[4], ethernet_packet[5]);
    fprintf(stdout, "Source Address\t\t\t%02X:%02X:%02X:%02X:%02X:%02X\n", ethernet_packet[6], ethernet_packet[7], ethernet_packet[8], ethernet_packet[9], ethernet_packet[10], ethernet_packet[11]);
    
    if (ethernet_packet[12] == 0x08 &&
        ethernet_packet[13] == 0x00) {
        
        fprintf(stdout, "Ethertype\t\t\t\tIP Packet\n");
        
        for (i = 0; i < 20; i++) {
            ip_header[i] = packet[14 + i];
        }
        
        fprintf(stdout, "Version\t\t\t\t\t%d\n", (ip_header[0] >> 4));
        fprintf(stdout, "IHL\t\t\t\t\t\t%d\n", (ip_header[0] & 0x0F));
        fprintf(stdout, "Type of Service\t\t\t%d\n", ip_header[1]);
        fprintf(stdout, "Total Length\t\t\t%d\n", ip_header[2]);
        fprintf(stdout, "Identification\t\t\t0x%02x 0x%02x\n", ip_header[3], ip_header[4]);
        fprintf(stdout, "Flags\t\t\t\t\t%d\n", ip_header[5] >> 5);
        fprintf(stdout, "Fragment Offset\t\t\t%d\n", (((ip_header[5] & 0x1F) << 8) + ip_header[6]));
        fprintf(stdout, "Time To Live\t\t\t%d\n", ip_header[7]);
        if (ip_header[9] == 0x11) {
            
            fprintf(stdout, "Protocol\t\t\t\tUDP\n");
        }
        else {
            fprintf(stdout, "Protocol\t\t\t\t%d\n", ip_header[9]);
        }
        fprintf(stdout, "Header Checksum\t\t\t0x%02x 0x%02x\n", ip_header[10], ip_header[11]);
        fprintf(stdout, "Source Address\t\t\t%d.%d.%d.%d\n", ip_header[12], ip_header[13], ip_header[14], ip_header[15]);
        fprintf(stdout, "Destination Address\t\t%d.%d.%d.%d\n", ip_header[16], ip_header[17], ip_header[18], ip_header[19]);
        if ((ip_header[0] & 0x0F) > 5) {
            udp_header_start = 48;
            fprintf(stdout, "Options\t\t\t\t\t0x%02x 0x%02x 0x%02x 0x%02x\n", ip_header[20], ip_header[21], ip_header[22], ip_header[23]);
        }
        
        if (ip_header[9] == 0x11) {
            
            fprintf(stdout, "\t\t\t\tUDP HEADER\n");
            
            for (i = 0; i < 8; i++) {
                udp_header[i] = packet[udp_header_start + i];
            }
            
            fprintf(stdout, "Source Port\t\t\t\t%d\n", (udp_header[0] << 8) + udp_header[1]);
            fprintf(stdout, "Destination Port\t\t%d\n", (udp_header[2] << 8) + udp_header[3]);
            fprintf(stdout, "Length\t\t\t\t\t%d\n", (udp_header[4] << 8) + udp_header[5]);
            fprintf(stdout, "Checksum\t\t\t\t0x%02x 0x%02x\n", udp_header[6], udp_header[7]);
            
            data_length = pkthdr->len - (udp_header_start + 8);
            
            fprintf(stdout, "Data\n");
            for (i = 0; i < data_length; i++) {
                
                fprintf(stdout, "%02x ", packet[udp_header_start + 8 + i]);
            }
            fprintf(stdout, "\n");
        }
    }
    else {
        fprintf(stdout, "Ethertype\t\t\t\tUnknow\n");
    }
}

int main(int argc,char **argv) {
    
    char *dev;
    char errbuf[PCAP_ERRBUF_SIZE];
    pcap_t* descr;
    struct bpf_program fp;
    bpf_u_int32 maskp;
    bpf_u_int32 netp;
    
    dev = pcap_lookupdev(errbuf);
    if(dev == NULL) {
        fprintf(stderr,"%s\n",errbuf); exit(1);
    }
    
    pcap_lookupnet(dev, &netp, &maskp, errbuf);
    descr = pcap_open_live(dev, BUFSIZ, 1, 1000, errbuf);
    
    if(descr == NULL) {
        printf("pcap_open_live(): %s\n",errbuf);
        exit(1);
    }
    
    char filter[] = "udp";
    if(pcap_compile(descr,&fp, filter,0,netp) == -1) {
        fprintf(stderr,"Error calling pcap_compile\n");
        exit(1);
    }
    
    if(pcap_setfilter(descr,&fp) == -1) {
        fprintf(stderr,"Error setting filter\n");
        exit(1);
        
    }
    
    pcap_loop(descr,-1,my_callback,NULL);
    
    /* write a packet
     //define a new packet and for each position set its values
     u_char packet[86];
     
     
     // Send down the packet
     if (pcap_sendpacket(descr, packet, 86) != 0) {
     
     fprintf(stderr,"\nError sending the packet: %s\n", pcap_geterr(descr));
     return 2;
     }
     */
    return 0;
}
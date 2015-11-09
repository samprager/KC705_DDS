/******************************************************************************
*
* (c) Copyright 2010-13 Xilinx, Inc. All rights reserved.
*
* This file contains confidential and proprietary information of Xilinx, Inc.
* and is protected under U.S. and international copyright and other
* intellectual property laws.
*
* DISCLAIMER
* This disclaimer is not a license and does not grant any rights to the
* materials distributed herewith. Except as otherwise provided in a valid
* license issued to you by Xilinx, and to the maximum extent permitted by
* applicable law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND WITH ALL
* FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS,
* IMPLIED, OR STATUTORY, INCLUDING BUT NOT LIMITED TO WARRANTIES OF
* MERCHANTABILITY, NON-INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE;
* and (2) Xilinx shall not be liable (whether in contract or tort, including
* negligence, or under any other theory of liability) for any loss or damage
* of any kind or nature related to, arising under or in connection with these
* materials, including for any direct, or any indirect, special, incidental,
* or consequential loss or damage (including loss of data, profits, goodwill,
* or any type of loss or damage suffered as a result of any action brought by
* a third party) even if such damage or loss was reasonably foreseeable or
* Xilinx had been advised of the possibility of the same.
*
* CRITICAL APPLICATIONS
* Xilinx products are not designed or intended to be fail-safe, or for use in
* any application requiring fail-safe performance, such as life-support or
* safety devices or systems, Class III medical devices, nuclear facilities,
* applications related to the deployment of airbags, or any other applications
* that could lead to death, personal injury, or severe property or
* environmental damage (individually and collectively, "Critical
* Applications"). Customer assumes the sole risk and liability of any use of
* Xilinx products in Critical Applications, subject only to applicable laws
* and regulations governing limitations on product liability.
*
* THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS PART OF THIS FILE
* AT ALL TIMES.
*
******************************************************************************/
/**
*
* @file xaxiethernet_example.h
*
* Defines common data types, prototypes, and includes the proper headers
* for use with the Axi Ethernet example code residing in this directory.
*
* This file along with xaxiethernet_example_util.c are utilized with the
* specific example code in the other source code files provided.
*
* These examples are designed to be compiled and utilized within the EDK
* standalone BSP development environment. The readme file contains more
* information on build requirements needed by these examples.
*
* <pre>
* MODIFICATION HISTORY:
*
* Ver   Who  Date     Changes
* ----- ---- -------- -------------------------------------------------------
* 1.00a asa  4/30/10 First release based on the ll temac driver
* 3.02a srt  4/26/13 Added function prototype for *_ConfigureInternalPhy().
* 
* </pre>
*
******************************************************************************/
#ifndef XAXIETHERNET_EXAMPLE_H
#define XAXIETHERNET_EXAMPLE_H


/***************************** Include Files *********************************/

#include "xparameters.h"	/* defines XPAR values */
#include "xaxiethernet.h"	/* defines Axi Ethernet APIs */
#include "stdio.h"		/* stdio */

/************************** Constant Definitions ****************************/
#define AXIETHERNET_LOOPBACK_SPEED	100	/* 100Mb/s for Mii */
#define AXIETHERNET_LOOPBACK_SPEED_1G 	1000	/* 1000Mb/s for GMii */
#define AXIETHERNET_PHY_DELAY_SEC	4	/*
					 	 * Amount of time to delay waiting on
					 	 * PHY to reset.
					 	 */

#define MAX_MULTICAST_ADDR   (1<<23)	/*
					 * Maximum number of multicast ethernet
					 * mac addresses.
					 */

/***************** Macros (Inline Functions) Definitions *********************/


/**************************** Type Definitions ******************************/

/*
 * Define an aligned data type for an ethernet frame. This declaration is
 * specific to the GNU compiler
 */
typedef unsigned char EthernetFrame[XAE_MAX_JUMBO_FRAME_SIZE] __attribute__ ((aligned(64)));


/************************** Function Prototypes *****************************/

/*
 * Utility functions implemented in xaxiethernet_example_util.c
 */
void AxiEthernetUtilSetupUart(void);
void AxiEthernetUtilFrameHdrFormatMAC(EthernetFrame * FramePtr,
							char *DestAddr);
void AxiEthernetUtilFrameHdrFormatType(EthernetFrame * FramePtr,
							u16 FrameType);
void AxiEthernetUtilFrameSetPayloadData(EthernetFrame * FramePtr,
							int PayloadSize);
void AxiEthernetUtilFrameHdrVlanFormatVid(EthernetFrame * FramePtr,
						u32 VlanNumber,u32 Vid);
void AxiEthernetUtilFrameHdrVlanFormatType(EthernetFrame * FramePtr,
						u16 FrameType,u32 VlanNumber);
void AxiEthernetUtilFrameSetVlanPayloadData(EthernetFrame * FramePtr,
					int PayloadSize,u32 VlanNumber);
int AxiEthernetUtilFrameVerify(EthernetFrame * CheckFrame,
			 EthernetFrame * ActualFrame);
void AxiEthernetUtilFrameMemClear(EthernetFrame * FramePtr);
int AxiEthernetUtilEnterLoopback(XAxiEthernet * AxiEthernetInstancePtr,
								int Speed);
void AxiEthernetUtilErrorTrap(char *Message);
void AxiEthernetUtilPhyDelay(unsigned int Seconds);
int AxiEthernetUtilConfigureInternalPhy(XAxiEthernet *AxiEthernetInstancePtr,
					int Speed);

/************************** Variable Definitions ****************************/

extern char AxiEthernetMAC[];		/* Local MAC address */

#endif /* XAXIETHERNET_EXAMPLE_H */


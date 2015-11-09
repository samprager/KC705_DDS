/* $Id: xhwicap_low_level_example.c,v 1.1.2.1 2011/08/11 09:23:07 vidhum Exp $ */
/******************************************************************************
*
* (c) Copyright 2003-2011 Xilinx, Inc. All rights reserved.
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
/*****************************************************************************/
/**
*
*
* @file xhwicap_low_level_example.c
*
* Contains a design example of how to use the low-level macros and functions
* of the XHwIcap driver.
*
* This example reads back the value stored in the IDCODE register.
*
* This example assumes that there is a UART Device or STDIO Device in the
* hardware system.
*
*
* @note
*
* This example should run on a Virtex4 or a Virtex5 or Virtex6 or
* a Spartan6 or a Kintex 7 device.
*
* <pre>
* MODIFICATION HISTORY:
*
* Ver   Who  Date     Changes
* ----- ---- -------- -------------------------------------------------------
* 1.00a bjb  11/21/03 First release
* 1.00a sv   07/18/05 Minor changes to comply to Doxygen and coding guidelines
* 1.01a sv   04/10/07 Changes to support V4
* 2.00a sv   10/10/07 Changes to support V5
* 4.00a hvm  11/20/09 Added support for V6 and updated with HAL phase 1
*		      modifications
* 5.00a hvm  02/08/10 Added support for S6
* 5.00a hvm  04/28/10 Added Check for the control bit clearance in the CR
*			register for regsiter read and write operations.
* 5.00a hvm  05/04/10 Updated the example to read Id twice so as to igonore
*			the first read.
* 5.00a hvm  05/21/10 Updated the ID sequence to be consistent across V4/V5/V6
*			devices. Added an extra NOP before Type1 Read device ID
*			and removed  extra NOP after the device ID. This
*			change removed the need of reading ID twice.
*			Removed the extra read ID.
* 5.01a hvm  07/29/10 Code to check whether read/write bit in control register
*			is cleared after the initiation of respective transfer
*			is added for all devices. This check was earlier done
*			only for S6 devices
* 6.00a hvm  08/05/11 Added support for K7 family
*
* </pre>
*
******************************************************************************/

/***************************** Include Files *********************************/

#include <xparameters.h>
#include <xstatus.h>
#include <xil_types.h>
#include <xil_assert.h>
#include <xhwicap_i.h>
#include <xhwicap_l.h>
#include <stdio.h>

/************************** Constant Definitions *****************************/

/*
 * The following constants map to the XPAR parameters created in the
 * xparameters.h file. They are defined here such that a user can easily
 * change all the needed parameters in one place.
 */
#define HWICAP_BASEADDR         XPAR_HWICAP_0_BASEADDR

/*
 * Number of words to Read for getting Id code.
 */
#if XHI_FAMILY == XHI_DEV_FAMILY_S6
#define HWICAP_IDCODE_SIZE		    2
#else
#define HWICAP_IDCODE_SIZE		    1
#endif

/*
 * Bitstream that reads back ID Code Register
 */
#if ((XHI_FAMILY == XHI_DEV_FAMILY_V4) ||(XHI_FAMILY == XHI_DEV_FAMILY_V5) \
|| (XHI_FAMILY == XHI_DEV_FAMILY_V6) || (XHI_FAMILY == XHI_DEV_FAMILY_7SERIES))

//ORIG for IDCODE:#define HWICAP_EXAMPLE_BITSTREAM_LENGTH     6
// Length = 8 for IPROG
#define HWICAP_EXAMPLE_BITSTREAM_LENGTH     8

//static u32 ReadId[HWICAP_EXAMPLE_BITSTREAM_LENGTH] =
//{
//	XHI_DUMMY_PACKET, /* Dummy Word */
//	XHI_SYNC_PACKET, /* Sync Word*/
//	XHI_NOOP_PACKET, /* Type 1 NO OP */
//	XHI_NOOP_PACKET, /* Type 1 NO OP */
//	XHI_DEVICE_ID_READ, /* Read Product ID Code Register */
//	XHI_NOOP_PACKET, /* Type 1 NO OP */
//};

// Reusing IDCODE array and code to send IPROG
// From UG470 p. 126, Table 7-1
static u32 ReadId[HWICAP_EXAMPLE_BITSTREAM_LENGTH] =
{
	0xFFFFFFFF, /* Dummy Word */
	0xAA995566, /* Sync Word*/
	0x20000000, /* Type 1 NO OP */
	0x30020001, /* Write WBSTAR cmd */
	0x00400000, /* Addr in SPI Flash of Multiboot bitstream */
	0x30008001, /* Write CMD */
	0x0000000F, /* Write IPROG */
	0x20000000, /* Type 1 NO OP  */
};

#elif XHI_FAMILY == XHI_DEV_FAMILY_S6/* Spartan 6*/

#define HWICAP_EXAMPLE_BITSTREAM_LENGTH     7

static u32 ReadId[HWICAP_EXAMPLE_BITSTREAM_LENGTH] =
{
	XHI_DUMMY_PACKET, /* Dummy Word */
	XHI_SYNC_PACKET1, /* Sync Word*/
	XHI_SYNC_PACKET2, /* Sync Word*/
	XHI_NOOP_PACKET, /* Type 1 NO OP */
	XHI_NOOP_PACKET, /* Type 1 NO OP */
	XHI_DEVICE_ID_READ, /* Read Product ID Code Register */
	XHI_NOOP_PACKET, /* Type 1 NO OP */
 };
#else

#error Unsupported Family of FPGAs

#endif

#define printf  xil_printf           /* A smaller footprint printf */

/**************************** Type Definitions *******************************/


/***************** Macros (Inline Functions) Definitions *********************/


/************************** Function Prototypes ******************************/

u32 HwIcapLowLevelExample(u32 BaseAddress, u32 *IdCode);


/************************** Variable Definitions *****************************/


/*****************************************************************************/
/**
* Main function to call the HWICAP Low Level example.
*
* @param    None
*
* @return   XST_SUCCESS if successful, otherwise XST_FAILURE
*
* @note     None
*
******************************************************************************/
//int main(void)
int fpga_iprog(u32 iprog_address)
{
	int Status;

	/*
	 * Run the HwIcap Low Level example, specify the Base Address
	 * generated in xparameters.h.
	 */
//	Status = HwIcapLowLevelExample(HWICAP_BASEADDR, &IdCode);

	ReadId[4] = iprog_address;
	Status = HwIcapLowLevelExample(HWICAP_BASEADDR, iprog_address);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	printf("IPROG ISSUED\r\n");
	//printf("The IDCODE is %x \r\n", IdCode);
	printf("\r\nHwIcapLowLevelExample Passed Successfully. \r\n\r\n");

	return XST_SUCCESS;

}


/*****************************************************************************/
/**
*
* This function returns the IDCODE of the target device.
*
* @param	BaseAddress is the base address of the HwIcap instance.
* @param	IdCode is the IDCODE of the part this code is running on.
*
* @return	XST_SUCCESS if successful, otherwise XST_FAILURE
*
* @note		None
*
******************************************************************************/
u32 HwIcapLowLevelExample(u32 BaseAddress, u32 *IdCode)
{

	u32 Index;
	u32 Retries;
    u32 RegData;
	// Adding in Abort Sequence

	/*
	 * Initiate the Abort sequence in the ICAP by setting the Abort bit in
	 * the Control Register.
	 */
	RegData = XHwIcap_ReadReg(BaseAddress, XHI_CR_OFFSET);

	XHwIcap_WriteReg(BaseAddress, XHI_CR_OFFSET, RegData | XHI_CR_SW_ABORT_MASK);




	/*
	 * Write command sequence to the FIFO
	 */
	for (Index = 0; Index < HWICAP_EXAMPLE_BITSTREAM_LENGTH; Index++) {
		XHwIcap_WriteReg(BaseAddress, XHI_WF_OFFSET, ReadId[Index]);
	}

	/*
	 * Start the transfer of the data from the FIFO to the ICAP device.
	 */
	XHwIcap_WriteReg(BaseAddress, XHI_CR_OFFSET, XHI_CR_WRITE_MASK);

	/*
	 * Poll for done, which indicates end of transfer
	 */
	Retries = 0;
	while ((XHwIcap_ReadReg(BaseAddress, XHI_SR_OFFSET) &
			XHI_SR_DONE_MASK) != XHI_SR_DONE_MASK) {
		Retries++;
		if (Retries > XHI_MAX_RETRIES) {

			/*
			 * Waited to long. Exit with error.
			 */
			printf("\r\nHwIcapLowLevelExample failed- retries  \
			failure. \r\n\r\n");

			return XST_FAILURE;
		}
	}

	/*
	 * Wait till the Write bit is cleared in the CR register.
	 */
	while ((XHwIcap_ReadReg(BaseAddress, XHI_CR_OFFSET)) &
					XHI_CR_WRITE_MASK);
	/*
	 * Write to the SIZE register. We want to readback one word.
	 */
	XHwIcap_WriteReg(BaseAddress, XHI_SZ_OFFSET, HWICAP_IDCODE_SIZE);


	/*
	 * Start the transfer of the data from ICAP to the FIFO.
	 */
	XHwIcap_WriteReg(BaseAddress, XHI_CR_OFFSET, XHI_CR_READ_MASK);

	/*
	 * Poll for done, which indicates end of transfer
	 */
	Retries = 0;
	while ((XHwIcap_ReadReg(BaseAddress, XHI_SR_OFFSET) &
			XHI_SR_DONE_MASK) != XHI_SR_DONE_MASK) {
		Retries++;
		if (Retries > XHI_MAX_RETRIES) {

			/*
			 * Waited to long. Exit with error.
			 */

			return XST_FAILURE;
		}
	}


//  Skipping when doing IPROG
//	/*
//	 * Wait till the Read bit is cleared in the CR register.
//	 */
//	while ((XHwIcap_ReadReg(BaseAddress, XHI_CR_OFFSET)) &
//					XHI_CR_READ_MASK);
//	/*
//	 * Return the IDCODE value
//	 */
//	*IdCode =  XHwIcap_ReadReg(BaseAddress, XHI_RF_OFFSET);

#if (XHI_FAMILY == XHI_DEV_FAMILY_S6)

	*IdCode =  (*IdCode << 16 | (XHwIcap_ReadReg(BaseAddress,
					XHI_RF_OFFSET)));
#endif

	return XST_SUCCESS;
}


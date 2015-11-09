/******************************************************************************
*
* (c) Copyright 2007-2012 Xilinx, Inc. All rights reserved.
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
* @file xilflash_protection_example.c
*
*
* This file contains a design example using the Generic Flash Library.
* This example tests the Lock and UnLock features of the Flash Device.
*
* A block is Locked and an attempt is made to erase a Page in that block. This
* should return an error. The block is then unlocked and an attempt is made to
* erase a page in that block which should succeed. A page of data is written,
* read back and compared with the data written for correctness.
*
* @note		This example has been tested with an Intel CFI compliant
*		Flash device.
*		This example has not been tested with an AMD CFI compliant Flash
*		device. The AMD CFI compliant Flash devices require the user to
*		apply a 12V DC voltage on the RP pin while performing the Lock
*		and Unlock operations.
*
*<pre>
* MODIFICATION HISTORY:
*
* Ver   Who  Date     Changes
* ----- ---- -------- ---------------------------------------------------------
* 1.01a mta  10/09/07 First release
* 1.01a sdm  02/24/09 Updated the notes with information about using the example
*		      with AMD CFI compliant Flash devices
* 2.00a ktn  12/04/09 Updated to use the HAL processor APIs/macros
* 3.00a sdm  03/03/11 Updated to pass BaseAddress and Flash Width to _Initialize
*		      API, as required by the new version of the library
*</pre>
******************************************************************************/

/***************************** Include Files *********************************/

#include <xilflash.h>
#include <xil_types.h>
#include <stdio.h>

/************************** Constant Definitions *****************************/

/*
 * The following constants define the baseaddress and width the flash memory.
 * These constants map to the XPAR parameters created in the xparameters.h file.
 * They are defined here such that a user can easily change all the needed
 * parameters in one place.
 */
#define FLASH_BASE_ADDRESS	XPAR_EMC_0_S_AXI_MEM0_BASEADDR

/*
 * The following constant defines the total byte width of the flash memory. The
 * user needs to update this width based on the flash width in the design/board.
 * The total flash width on some of the Xilinx boards is listed below.
 * -------------------------------
 * Board		Width
 * -------------------------------
 * ML403		4 (32 bit)
 * ML5xx		2 (16 bit)
 * Spartan3S 1600E	2 (16 bit)
 * Spartan-3A DSP	2 (16 bit)
 * Spartan-3A		2 (16 bit)
 * Spartan-3AN		2 (16 bit)
 * ML605		2 (16 bit)
 * SP605		2 (16 bit)
 * SP601		1 (8 bit)
 */
#define FLASH_MEM_WIDTH		2

#define FLASH_TEST_SIZE		256
#define START_ADDRESS		0x3F60000
#define BLOCK_OFFSET_ADDR	0x3F68000

/**************************** Type Definitions *******************************/

/***************** Macros (Inline Functions) Definitions *********************/

/************************** Function Prototypes ******************************/
int FlashProtectionExample(void);

/************************** Variable Definitions *****************************/

XFlash FlashInstance; /* XFlash Instance. */

/*
 * Buffers used during read and write transactions.
 */
u8 ReadBuffer[FLASH_TEST_SIZE]; /* Buffer used to store the data read. */
u8 WriteBuffer[FLASH_TEST_SIZE]; /* Write buffer. */

/************************** Function Definitions ******************************/

/*****************************************************************************/
/**
*
* Main function to execute the Flash protection example.
*
* @param	None
*
* @return	XST_SUCCESS if successful else XST_FAILURE.
*
* @note		None.
*
******************************************************************************/
/*int main(void)
{
	int Status;

	Status = FlashProtectionExample();
	if(Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	return XST_SUCCESS;
}
*/
/*****************************************************************************/
/**
*
* This function verifies the locking and unlocking features of the Flash device.
*
* @param	None
*
* @return	XST_SUCCESS if successful else XST_FAILURE.
*
* @note		None.
*
******************************************************************************/
int FlashProtectionExample(void)
{
	int Status;
	u32 Index;

	/*
	 * Initialize the Flash Library.
	 */
	Status = XFlash_Initialize(&FlashInstance, FLASH_BASE_ADDRESS,
				   FLASH_MEM_WIDTH, 0);
	if(Status != XST_SUCCESS) {
		xil_printf("-- Fail at Initialize --\r\n");
		return XST_FAILURE;
	}

	xil_printf("-- Initialized the Flash library successfully --\r\n");

	/*
	 * Reset the Flash Device. This clears the Status registers and puts
	 * the device in Read mode.
	 */
	Status = XFlash_Reset(&FlashInstance);
	if(Status != XST_SUCCESS) {
		xil_printf("-- Fail at reset --\r\n");
		return XST_FAILURE;
	}

	/*
	 * Lock the Block.
	 */
	Status = XFlash_Lock(&FlashInstance, BLOCK_OFFSET_ADDR, 0);
	if(Status != XST_SUCCESS) {
		xil_printf("-- Lock error --\r\n");
		return XST_FAILURE;
	}
	xil_printf("-- Locked all the blocks successfully --\r\n");

	/*
	 * Perform the Erase operation. This should fail as the block is locked.
	 */
	Status = XFlash_Erase(&FlashInstance, START_ADDRESS, FLASH_TEST_SIZE);
	if(Status == XST_SUCCESS) {
		xil_printf("-- Erase failed --\r\n");
		return XST_FAILURE;
	}
	xil_printf("-- Erased the Flash memory contents at offset 0x%07x successfully --\r\n",
			START_ADDRESS);
	/*
	 * Unlock the Block.
	 */
	Status = XFlash_Unlock(&FlashInstance, BLOCK_OFFSET_ADDR, 0);
	if(Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	xil_printf("-- Unlocked all the blocks successfully --\r\n");

	/*
	 * Perform the Erase operation. This should succeed as the block is
	 * unlocked.
	 */
	Status = XFlash_Erase(&FlashInstance, START_ADDRESS, FLASH_TEST_SIZE);
	if(Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Prepare the write buffer. Fill in the data need to be written into
	 * Flash Device.
	 */
	xil_printf("-- Writing: ");
	for(Index = 0; Index < FLASH_TEST_SIZE; Index++) {
		WriteBuffer[Index] = (u8)Index;
		xil_printf("%02x", WriteBuffer[Index]);
	}
	xil_printf("\r\n");

	/*
	 * Perform the Write operation.
	 */
	Status = XFlash_Write(&FlashInstance, START_ADDRESS, FLASH_TEST_SIZE,
			      WriteBuffer);
	if(Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	xil_printf("-- Write operation at offset 0x%07x completed successfully --\r\n",
			START_ADDRESS);
	/*
	 * Perform the read operation.
	 */
	Status = XFlash_Read(&FlashInstance, START_ADDRESS, FLASH_TEST_SIZE,
			     ReadBuffer);
		if(Status != XST_SUCCESS) {
			return XST_FAILURE;
	}
	xil_printf("-- Read operation completed successfully --\r\n");

	/*
	 * Compare the data read against the data Written.
	 */
	for(Index = 0; Index < FLASH_TEST_SIZE; Index++) {
		if(ReadBuffer[Index] != (u8)Index) {
			return XST_FAILURE;
		}
	}
	xil_printf("-- Data comparison successful --\r\n");
	return XST_SUCCESS;
}

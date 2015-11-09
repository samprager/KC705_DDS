/* $Id: v6_ddrx_mem_test_example.c,v 1.1.2.1 2010/04/12 06:07:17 sadanan Exp $ */
/******************************************************************************
*
* (c) Copyright 2010 Xilinx, Inc. All rights reserved.
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
* @file v6_ddrx_mem_test_example.c
*
* This file contains a memory test example using the V6 DDRX hardware device.
* This example tests the memory by writing and reading test patterns to the
* specified region of the memory. This example tests an instance of the  V6
* DDRX device whose baseaddress and highaddress are spcified by the definitions
* BASE_ADDR and HIGH_ADDR.
*
* The various memory tests that are performed as a part of this example are :
*  - Write all zeroes, read and verify.
*  - Write all ones, read and verify.
*  - Test for stuck together Row/Column.
*  - Maximum Band Address/Row/Column noise.
*  - Data NOT EQUAL TO Address Test.
*
* @note
*
* The following definitions can be changed by the user depending on the
* requirements :
*
* BASE_ADDR - This definition specifies the base address of the V6 DDRX device
* on which the memory tests have to be run.
*
* HIGH_ADDR - This definition specifies the high address of the V6 DDRX device
* on which the memory tests have to be run.
*
* MEM_OFFSET - This definition specifies the offset from the Memory Baseaddress,
* for a V6 DDRX device, from which the memory tests have to be run.
*
* V6_DDRX_TEST - This definition provides an option to enable or disable each
* individual memory test. All the memory tests are enabled by default.
*
* V6_DDRX_CACHE_TEST - This definition specifies the combination of
* Instruction Cache and Data Cache that are tested a part of the memory
* tests. The different combinations that can be tested are
* - ICache is enabled and DCache is enabled
* - ICache is disabled and DCache is disabled
* - ICache is enabled and DCache is disabled
* - ICache is disabled and DCache is enabled
* V6_DDRX_CACHE_TEST_0 and V6_DDRX_CACHE_TEST_1 are enabled by default.
*
* NUM_ITERATIONS - This definition specifies the number of times the test
* has to be run. If it is set to -1 the tests will run infinitely. The default
* value of this constant is set to 1.
*
* The users can either modify these defitions within this file or through
* command line using the format -D <CONSTANT_NAME>=<new_value>.
*
* <pre>
* MODIFICATION HISTORY:
*
* Ver   Who  Date     Changes
* ----- ---- -------- --------------------------------------------------------
* 1.00a sdm  04/05/10 First release.
* </pre>
*
******************************************************************************/

/***************************** Include Files *********************************/

#include "xparameters.h"
#include "xuartns550_l.h"
#include "xil_cache.h"
#include <stdio.h>

/************************** Constant Definitions ******************************/
#ifndef UART_BASEADDR
#define UART_BASEADDR XPAR_UARTNS550_0_BASEADDR
#endif
#define UART_CLOCK    XPAR_XUARTNS550_CLOCK_HZ

#if !SIM
#define UART_BAUDRATE 9600                      /* real hardware */
#else
#define UART_BAUDRATE (UART_CLOCK / 16 / 3)     /* simulation */
#endif

/*
 * The following constants map to the XPAR parameters created in the
 * xparameters.h file. They are defined here such that a user can easily
 * change all the needed parameters in one place.
 */
#define BASE_ADDR		XPAR_BRAM_0_BASEADDR

#define HIGH_ADDR		XPAR_BRAM_0_HIGHADDR

#define BANK_WIDTH		1
#define ROW_WIDTH		13
#define COL_WIDTH		10
#define MEM_WIDTH		32

/*
 * This constant specifies the offset from the Memory Baseaddress, for a V6 DDRX
 * device, from which the memory tests have to be run. By default this value is
 * set to 0x00020000.
 * Offset can be used to run the program out of the memory to test and not
 * clobber our software. Set this value to power of 2 larger than the size of
 * this program.
 * Offset should be set to a value less than half the size of the
 * V6_DDRX memory for 'Maximum Bank Address/Row/Column noise' test
 * (V6_DDRX_TEST_3) and to a value less than the size of the V6_DDRX memory for
 * remaining tests.
 */
#ifndef MEM_OFFSET
 #define MEM_OFFSET		0x00030000
#endif

/*
 * Bit masks for the tests that are to be done on the memory.
 */
#define V6_DDRX_TEST_0	0x0001 /* V6_DDRX_TEST_0 - Write all zeros and verify */
#define V6_DDRX_TEST_1	0x0002 /* V6_DDRX_TEST_1 - Write all ones and verify */
#define V6_DDRX_TEST_2	0x0004 /* V6_DDRX_TEST_2 - Test for stuck together
				  row/col bits*/
#define V6_DDRX_TEST_3	0x0008 /* V6_DDRX_TEST_3 - MAX BA/ROW/COL NOISE */
#define V6_DDRX_TEST_4	0x0010 /* V6_DDRX_TEST_4 - DATA = !ADDR test */

/*
 * Tests to be done. All the tests are enabled by default.
 */
#ifndef V6_DDRX_TEST
 #define V6_DDRX_TEST	(V6_DDRX_TEST_0 | V6_DDRX_TEST_1 | V6_DDRX_TEST_2 | \
			  V6_DDRX_TEST_4)
#endif

/*
 * Cache options for the tests.
 */
#define V6_DDRX_CACHE_TEST_0	0x0001 /* ICache: ON , DCache: ON */
#define V6_DDRX_CACHE_TEST_1	0x0002 /* ICache: OFF, DCache: OFF */
#define V6_DDRX_CACHE_TEST_2	0x0004 /* ICache: ON, DCache: OFF */
#define V6_DDRX_CACHE_TEST_3	0x0008 /* ICache: OFF, DCache: ON */

/*
 * Cache options for the tests to be done.
 * V6_DDRX_CACHE_TEST_0 and V6_DDRX_CACHE_TEST_1 are enabled by default.
 */
#ifndef V6_DDRX_CACHE_TEST
 #define V6_DDRX_CACHE_TEST	(V6_DDRX_CACHE_TEST_0 | V6_DDRX_CACHE_TEST_1)
#endif

/*
 * Specifies how many passes of the test to run, -1 == infinite.
 */
#ifndef NUM_ITERATIONS
 #define NUM_ITERATIONS		1
#endif

/**************************** Type Definitions ********************************/

/*
 * This type is a word address ptr.
 */
typedef volatile u32 *U32Ptr;

/***************** Macros (Inline Functions) Definitions **********************/

/*
 * Macros to read and write words directly to memory.
 */
#define WR_WORD(ADDR, DATA)	(*(U32Ptr)(ADDR) = (DATA))
#define RD_WORD(ADDR, DATA)	((DATA) = *(U32Ptr)(ADDR))

/*
 * Macros to enable/disable caches.
 */
#define ENABLE_ICACHE()		Xil_ICacheEnable()
#define ENABLE_DCACHE()		Xil_DCacheEnable()
#define DISABLE_ICACHE()	Xil_ICacheDisable()
#define DISABLE_DCACHE()	Xil_DCacheDisable()

#define printf			xil_printf	/* Small foot print printf */

/************************** Function Prototypes *******************************/

static u32 V6_BramMemTest(u32 BaseAddr, u32 HighAddr);
static int V6_BramMemTestExample(u32 BaseAddr, u32 HighAddr);

/************************** Variable Definitions ******************************/

static u32 PassCount = 1;	/* Current iteration */

/*
 * The following variables are used to read from the V6_DDRX memory, these are
 * defined as global to avoid having large buffers on the stack.
 */
#if (V6_DDRX_TEST & V6_DDRX_TEST_3)
 u32 DataBuffer[32];
#endif /* V6_DDRX_TEST & V6_DDRX_TEST_3 */

/******************************************************************************/
/**
*
* Main function to call the V6_DDRX memory test example.
*
* @param	None.
*
* @return	Total number of errors for all iterations.
*
* @note		None.
*
*******************************************************************************/
int hello_bram (void)
{
	u32 TotalErrors;
   XUartNs550_SetBaud(UART_BASEADDR, UART_CLOCK, UART_BAUDRATE);
   XUartNs550_SetLineControlReg(UART_BASEADDR, XUN_LCR_8_DATA_BITS);

  xil_printf("\n\r********************************************************");
  xil_printf("\n\r********************************************************");
  xil_printf("\n\r**     KC705 - AXI BRAM TEST                          **");
  xil_printf("\n\r********************************************************");
  xil_printf("\n\r********************************************************\r\n");


	TotalErrors = V6_BramMemTestExample(BASE_ADDR, HIGH_ADDR);

	if (TotalErrors) {
		printf("\r\n### Program finished with errors ###\r\n");
	} else {
		printf("\r\n### Program finished successfully ###\r\n");
	}
	return TotalErrors;
}

/******************************************************************************/
/**
*
* This function runs the memory tests on a V6 DDRX device.
*
* @param	BaseAddr is the base address of the V6 DDRX device.
* @param	HighAddr is the high address of the V6 DDRX device.
*
* @return	Total number of errors for all iterations, for a V6 DDRX device.
*
* @note		None.
*
*******************************************************************************/
int V6_BramMemTestExample(u32 BaseAddr, u32 HighAddr)
{
	u32 MemError = 0;
	u32 TotalErrors = 0;
	//int Status;



	PassCount = 1;
	/*
	 * If NUM_ITERATIONS set to -1, loop will be infinite.
	 */
	while (PassCount <= NUM_ITERATIONS || NUM_ITERATIONS == -1) {
		printf("\n\r\nK7 AXI BRAM Memory Test");
		printf("\r\nTesting address range 0x%08X-0x%08X.",
			BaseAddr + MEM_OFFSET, HighAddr);
		printf("\r\nIteration %d", PassCount);
		if (NUM_ITERATIONS != -1) {
			printf(" of %d", NUM_ITERATIONS);
		}

#if (V6_DDRX_CACHE_TEST & V6_DDRX_CACHE_TEST_0)
		ENABLE_ICACHE();
		ENABLE_DCACHE();
		Xil_DCacheInvalidate();
		printf("\r\nPass A) ICache:  On, DCache:  On");
		MemError = V6_BramMemTest(BaseAddr, HighAddr);
		printf("\r\n\t\tNumber of errors in this pass = %d\r\n",
			MemError);
		TotalErrors += MemError;

#endif /* V6_DDRX_CACHE_TEST & V6_DDRX_CACHE_TEST_0 */

#if (V6_DDRX_CACHE_TEST & V6_DDRX_CACHE_TEST_1)
		DISABLE_ICACHE();
		DISABLE_DCACHE();
		printf("\r\nPass B) ICache: Off, DCache: Off");
		MemError = V6_BramMemTest(BaseAddr, HighAddr);
		printf("\r\n\t\tNumber of errors in this pass = %d\r\n",
			MemError);
		TotalErrors += MemError;
#endif /* V6_DDRX_CACHE_TEST & V6_DDRX_CACHE_TEST_1 */

#if (V6_DDRX_CACHE_TEST & V6_DDRX_CACHE_TEST_2)
		ENABLE_ICACHE();
		DISABLE_DCACHE();
		printf("\r\nPass C) ICache:  On, DCache: Off");
		MemError = V6_BramMemTest(BaseAddr, HighAddr);
		printf("\r\n\tNumber of errors in this pass = %d\r\n",
			MemError);
		TotalErrors += MemError;
#endif /* V6_DDRX_CACHE_TEST & V6_DDRX_CACHE_TEST_2 */

#if (V6_DDRX_CACHE_TEST & V6_DDRX_CACHE_TEST_3)
		DISABLE_ICACHE();
		ENABLE_DCACHE();
		printf("\r\nPass D) ICache: Off, DCache:  On");
		MemError = V6_BramMemTest(BaseAddr, HighAddr);
		printf("\r\n\tNumber of errors in this pass = %d\r\n",
			MemError);
		TotalErrors += MemError;
#endif /* V6_DDRX_CACHE_TEST & V6_DDRX_CACHE_TEST_0 */

		printf("\r\nAXI BRAM test ");
		printf("iteration #%d ", PassCount);

		if (TotalErrors == 0) {
			printf("has PASSED!");
		} else {
			printf("has FAILED!");
		}
		PassCount++;
	}

	printf("\r\nTotal number of errors for all iterations = %d",
		TotalErrors);

	return TotalErrors;
}

/******************************************************************************/
/**
*
* This function runs the V6_DDRX memory tests for a V6 DDRX memory device.
* It returns back 0 if there were no errors, else it returns the number of
* memory errors.
*
* @param	BaseAddr is the base address of the V6 DDRX memory.
* @param	HighAddr is the high address of the V6 DDRX memory.
*
* @return
*		 - 0 - No Errors.
*		 - Greater than 1 indicates the number of errors detected.
*
* @note		None.
*
*******************************************************************************/
static u32 V6_BramMemTest(u32 BaseAddr, u32 HighAddr)
{
	u32 MyAdr;
	u32 StartAdr;
	u32 MemSize;
	u32 Range;
	u32 Offset;
	u32 Error = 0;
	u32 TotalErrors = 0;
	u32 DataRead;
	u32 WriteAdr;
	int i;
	int j;
#if (V6_DDRX_TEST & V6_DDRX_TEST_3)
	u32 BankAddr;
	u32 Row;
	u32 Col;
	u16 MemWidth;
	u16 StartBit;
	u32 RowAddrMask;
	u32 ColAddrMask;
	u32 BankAddrMask;
#endif /* V6_DDRX_TEST & V6_DDRX_TEST_3 */

	Offset   = MEM_OFFSET;
	StartAdr = BaseAddr + Offset;
	MemSize  = HighAddr - BaseAddr + 1;
	Range    = MemSize - Offset;

	/*
	 * V6_DDRX_TEST_0 - Write all zeros and verify.
	 */
#if (V6_DDRX_TEST & V6_DDRX_TEST_0)
	if (Offset > MemSize) {
		printf("\n\r\tMemory Offset can't be greater than the size of" \
			"the memory");
		return ++Error;
	}

	printf("\r\n\tTEST0: " \
		"Write all memory to 0x00000000 and check" \
		"\r\n\t\tWriting...");

	/*
	 * Clear the range of memory.
	 */
	for (MyAdr = StartAdr; MyAdr < StartAdr + Range; MyAdr += 4) {
		WR_WORD(MyAdr, 0x00000000);
	}

	printf("\r\n\t\tReading...");

	/*
	 * Read it all back.
	 */
	for (MyAdr = StartAdr; MyAdr < StartAdr + Range; MyAdr += 4) {
		RD_WORD(MyAdr, DataRead);
		if (DataRead != 0x00000000) {
			Error++;
			printf("\r\n\t\tTEST0 - ERROR #%d: Address = 0x%08x, " \
				"Data Expected was 0x00000000, Data Received " \
				"was 0x%08x", Error, MyAdr, DataRead);
		}
	}

	printf("\r\n\tTest Complete Status = ");

	if (Error) {
		printf("FAILURE");
	} else {
		printf("SUCCESS");
	}

	TotalErrors += Error;
#endif /* V6_DDRX_TEST & V6_DDRX_TEST_0 */

	/*
	 * V6_DDRX_TEST_1 - Write all ones and verify.
	 */
#if (V6_DDRX_TEST & V6_DDRX_TEST_1)
	if (Offset > MemSize) {
		printf("\n\r\tMemory Offset can't be greater than the size of" \
			"the memory");
		return ++Error;
	}

	printf("\r\n\tTEST1: " \
		"Write all memory to 0xFFFFFFFF and check" \
		"\r\n\t\tWriting...");

	/*
	 * Clear range of memory to 0xFFFFFFFF.
	 */
	for (MyAdr = StartAdr; MyAdr < StartAdr + Range; MyAdr += 4) {
		WR_WORD(MyAdr, 0xFFFFFFFF);
	}

	printf("\r\n\t\tReading...");

	for (MyAdr = StartAdr; MyAdr < StartAdr + Range; MyAdr += 4) {
	     RD_WORD(MyAdr, DataRead);

		if (DataRead != 0xFFFFFFFF) {
			Error++;
			printf("\r\n\t\tTEST1 - ERROR #%d: Address = 0x%08x, " \
				"Data Expected was 0xFFFFFFFF, Data Received " \
				"was 0x%08x", Error, MyAdr, DataRead);
		}
	}

	printf("\r\n\tTest Complete Status = ");
	if (Error) {
		printf("FAILURE \r\n");
	} else {
		printf("SUCCESS \r\n");
	}

	TotalErrors += Error;
#endif /* V6_DDRX_TEST & V6_DDRX_TEST_1 */

	/*
	 * V6_DDRX_TEST_2 - Test for stuck together row/col bits.
	 */
#if (V6_DDRX_TEST & V6_DDRX_TEST_2)
	if (Offset > MemSize) {
		printf("\n\r\tMemory Offset can't be greater than the size of" \
			"the memory");
		return ++Error;
	}

	printf("\r\n\tTEST2: " \
		"Testing for stuck together bank/row/col bits" \
		"\r\n\t\tClearing memory to zeros...");

	/*
	 * Clear all of memory.
	 */
	for (MyAdr = StartAdr; MyAdr < StartAdr + Range; MyAdr += 4) {
		WR_WORD(MyAdr, 0x00000000);
	}

	printf("\r\n\t\tWriting and Reading...");

	for (i = 1, WriteAdr = StartAdr; WriteAdr < StartAdr + Range;
	     ++i, WriteAdr = StartAdr | (u32) (1 << i)) {

		/*
		 * Write out the value we'll be checking for later.
		 */
		WR_WORD(WriteAdr, 0xFFFFFFFF);

		for (j = 1, MyAdr = StartAdr; MyAdr < StartAdr + Range;
		     ++j, MyAdr = StartAdr | (u32)(1 << j)) {

			/*
			 * Read back a word of data.
			 */
			RD_WORD(MyAdr, DataRead);

			/*
			 * Check to make sure it is zero.
			 */
			if ((DataRead != 0) && (WriteAdr != MyAdr)) {
				Error++;
				printf("\r\n\t\tTEST2 - ERROR #%d:, " \
					"Address = 0x%08x, " \
					"Data Expected was 0x00000000, " \
					"Data Received was 0x%08x",
					Error, MyAdr, DataRead);
			}
		}

		/*
		 * Clean out the old value before pointer update.
		 */
		WR_WORD(WriteAdr, 0x00000000);
	}
	printf("\r\n\tTest Complete Status = ");

	if (Error) {
		printf("FAILURE \r\n");
	} else {
		printf("SUCCESS \r\n");
	}

	TotalErrors += Error;
#endif /* V6_DDRX_TEST & V6_DDRX_TEST_2 */

	/*
	 * V6_DDRX_TEST_3 - MAX BA/ROW/COL NOISE.
	 */
#if (V6_DDRX_TEST & V6_DDRX_TEST_3)
	if (Offset > (MemSize / 2)) {
		printf("\n\r\tMemory Offset can't be greater than half the" \
			"size of the memory");
		return ++Error;
	}

	printf("\r\n\tTEST3: " \
		"Testing for maximum ba/row/col noise");
	printf("\r\n\t\tThis test performs 16 word writes followed by 16 word" \
		" reads");
	printf("\r\n\t\tEach 64 bytes inverts the ba/row/col address" \
		"\r\n\t\tInitializing Memory to 0xA5A5A5A5...");

	/*
	 * Calculate our bit masks for Column, Row and Bank addresses,
	 * we are assuming the memory is a power of 2 and even alignment.
	 */
	MemWidth = MEM_WIDTH;
	StartBit = (MemWidth == 8 ? 0 : MemWidth == 16 ? 1 :
		    MemWidth == 32 ? 2 : MemWidth == 64 ? 3 : 4);
	ColAddrMask = (((1 << COL_WIDTH) - 1) << (StartBit)) & (MemSize - 1);
	RowAddrMask = (((1 << ROW_WIDTH) - 1) << (StartBit + COL_WIDTH)) &
			(MemSize - 1);
	BankAddrMask = (((1 << BANK_WIDTH) - 1) << (StartBit + COL_WIDTH +
			 ROW_WIDTH)) & (MemSize - 1);

	/*
	 * Set the range of memory to 0xA5A5A5A5.
	 */
	for (MyAdr = StartAdr; MyAdr < StartAdr + Range; MyAdr += 4) {
		WR_WORD(MyAdr, 0xA5A5A5A5);
	}

	/*
	 * Setup initial values.
	 */
	WriteAdr = StartAdr;
	MyAdr = WriteAdr;

	printf("\r\n\t\tWriting and Reading...");

	/*
	 * Going to ping pong and meet in middle.
	 */
	for (i = 0; i < ((Range - Offset) / 128); i++) {
		BankAddr  = WriteAdr & BankAddrMask;
		Row = WriteAdr & RowAddrMask;
		Col = WriteAdr & ColAddrMask & 0xFFFFFFFC;

		/*
		 * Write out 64 bytes.
		 */
		for (j = 0; j < 8; j++) {
			WR_WORD(WriteAdr, 0xFFFFFFFF);
			WR_WORD(WriteAdr + 4, 0x00000000);
			WriteAdr += 8;
		}

		WriteAdr = MyAdr;

		/*
		 * Read back the 64 bytes.
		 */
		for (j = 0; j < 16; j++) {
			RD_WORD(WriteAdr, DataBuffer[j]);
			WriteAdr += 4;
		}

		WriteAdr = MyAdr;

		/*
		 * Lets compare the results to the expected values now....
		 */
		for (j = 0; j < 16; j += 2) {
			if (DataBuffer[j] != 0xFFFFFFFF) {
				Error++;
				printf("\r\n\t\tTEST3.1 - ERROR #%d: " \
					"Address = 0x%08x, " \
					"Data Expected was 0xFFFFFFFF, " \
					"Data Received was 0x%08x", Error,
					(MyAdr + 4 * j), DataBuffer[j]);
			}

			if (DataBuffer[j + 1] != 0x00000000) {
				Error++;
				printf("\r\n\t\tTEST3.2 - ERROR #%d: " \
					"Address = 0x%08x, " \
					"Data Expected was 0x00000000, " \
					"Data Received was 0x%08x", Error,
					MyAdr + (4 * j) + 4, DataBuffer[j + 1]);
			}
		}

		/*
		 * Calculate the inverse address for DDR SDRAM.
		 */
		BankAddr  = ~BankAddr  & BankAddrMask;
		Row = ~Row & RowAddrMask;
		Col = ~Col & ColAddrMask & 0xFFFFFFFC;
		WriteAdr = (BankAddr | Row | Col) - 60 + BaseAddr;
		MyAdr = WriteAdr;

		/*
		 * Write out 64 bytes.
		 */
		for (j = 0; j < 8; j++) {
			WR_WORD(WriteAdr, 0xFFFFFFFF);
			WR_WORD(WriteAdr + 4, 0x00000000);
			WriteAdr += 8;
		}

		WriteAdr = MyAdr;

		/*
		 * Read back the 64 bytes.
		 */
		for (j = 16; j < 32; j++) {
			RD_WORD(WriteAdr, DataBuffer[j]);
			WriteAdr += 4;
		}

		/*
		 * Lets compare the results to the expected values now....
		 */
		for (j = 16; j < 32; j += 2) {
			if (DataBuffer[j] != 0xFFFFFFFF) {
				Error++;
				printf("\r\n\t\tTEST3.3 - ERROR #%d: " \
					"Address = 0x%08x, " \
					"Data Expected was 0xFFFFFFFF, " \
					"Data Received was 0x%08x", Error,
					(MyAdr + 4 * (j - 16)), DataBuffer[j]);
			}
			if (DataBuffer[j + 1] != 0x00000000) {
				Error++;
				printf("\r\n\t\tTEST3.4 - ERROR #%d: " \
					"Address = 0x%08x, " \
					"Data Expected was 0xFFFFFFFF, " \
					"Data Received was 0x%08x", Error,
					(MyAdr + (4 * (j - 16)) + 4),
					DataBuffer[j + 1]);
			}
		}

		/*
		 * Calculate the "normal" address for the next cycles.
		 */
		BankAddr  = ~BankAddr  & BankAddrMask;
		Row = ~Row & RowAddrMask;
		Col = ~Col & ColAddrMask & 0xFFFFFFFC;

		/*
		 * Increase by one 64 byte quantum.
		 */
		WriteAdr = (BankAddr | Row | Col) + 64 + BaseAddr;
	}

	printf("\r\n\tTest Complete Status = ");
	if (Error) {
		printf("FAILURE");
	} else {
		printf("SUCCESS");
	}

	TotalErrors += Error;
#endif /* V6_DDRX_TEST & V6_DDRX_TEST_3 */

	/*
	 * V6_DDRX_TEST_4 - DATA = !ADDR test
	 */
#if (V6_DDRX_TEST & V6_DDRX_TEST_4)
	if (Offset > MemSize) {
		printf("\n\r\tMemory Offset can't be greater than the size of" \
			"the memory");
		return ++Error;
	}

	printf("\r\n\tTEST4: " \
		"Testing for Inverse Data at Address" \
		"\r\n\t\tWriting...");

	for (MyAdr = StartAdr; MyAdr < StartAdr + Range; MyAdr += 4) {
		WR_WORD(MyAdr, ~MyAdr);
	}

	printf("\r\n\t\tReading...");

	/*
	 * Read it all back.
	 */
	for (MyAdr = StartAdr; MyAdr < StartAdr + Range; MyAdr += 4) {
		RD_WORD(MyAdr, DataRead);

		if (DataRead != ~MyAdr) {
		Error++;
		printf("\n\t\t\tTEST4 - ERROR #%d: Address = 0x%08x, " \
			"Data Expected was 0x%08x, Data Received was 0x%08x",
			Error, MyAdr, ~MyAdr, DataRead);
		}
	}

	printf("\r\n\tTest Complete Status = ");
	if (Error) {
		printf("FAILURE \r\n");
	} else {
		printf("SUCCESS \r\n");
	}

	TotalErrors += Error;
#endif /* V6_DDRX_TEST & V6_DDRX_TEST_4 */

	return TotalErrors;
}

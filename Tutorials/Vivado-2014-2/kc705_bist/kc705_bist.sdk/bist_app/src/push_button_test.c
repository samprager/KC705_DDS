/******************************************************************************
*
*       XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS"
*       AS A COURTESY TO YOU, SOLELY FOR USE IN DEVELOPING PROGRAMS AND
*       SOLUTIONS FOR XILINX DEVICES.  BY PROVIDING THIS DESIGN, CODE,
*       OR INFORMATION AS ONE POSSIBLE IMPLEMENTATION OF THIS FEATURE,
*       APPLICATION OR STANDARD, XILINX IS MAKING NO REPRESENTATION
*       THAT THIS IMPLEMENTATION IS FREE FROM ANY CLAIMS OF INFRINGEMENT,
*       AND YOU ARE RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE
*       FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY DISCLAIMS ANY
*       WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE
*       IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR
*       REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF
*       INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
*       FOR A PARTICULAR PURPOSE.
*
*       (c) Copyright 2008 - 2009 Xilinx Inc.
*       All rights reserved.
*
******************************************************************************/

/*****************************************************************************/
/**
* @file push_button_test.c
*
*
* This file contains the application for testing the Pushbutton & LED
* functionality for the Kintex-7 KC705 Development kit.
*
* @note     None.
*
* <pre>
*
* MODIFICATION HISTORY:
*
* Ver   Who  Date     Changes
* ----- ---- -------- --------------------------------------------------------
* 1.00  sun  02/29/08  First release.
* </pre>
*
******************************************************************************/

#include "xgpio_l.h"
#include "xuartns550_l.h"
#include <stdlib.h>
#include <stdio.h>
#include "xgpio.h"
#include "xparameters.h"

#if !SIM
#include "stdio.h"
#endif

/************************** Constant Definitions *****************************/

#define XPAR_PUSH_BUTTONS_5BITS_BASEADDR XPAR_AXI_GPIO_3_BASEADDR


int hello_button()
{
	u32 Button = 0;
    volatile int Delay;

	/*
	 * Set gpio bits to input
	 */
	XGpio_WriteReg(XPAR_PUSH_BUTTONS_5BITS_BASEADDR, 0x4, 0x0000001F);

  xil_printf("\n\r********************************************************");
  xil_printf("\n\r********************************************************");
  xil_printf("\n\r**     KC705 - Button Test                            **");
  xil_printf("\n\r********************************************************");
  xil_printf("\n\r********************************************************\r\n");

	/*
	 * Set gpio bits to all output
	 */

	xil_printf("Press west button\r\n\r\n");
	Button =0;
	while (Button == 0){
		Button = XGpio_ReadReg(XPAR_PUSH_BUTTONS_5BITS_BASEADDR, 1) & 0x00000002;
	}

    for (Delay = 0; Delay < 80000; Delay++);
	XGpio_WriteReg(XPAR_PUSH_BUTTONS_5BITS_BASEADDR, 0, 0x0);

	xil_printf("Press south button\r\n\r\n");
	Button =0;
	while (Button == 0){
		Button = XGpio_ReadReg(XPAR_PUSH_BUTTONS_5BITS_BASEADDR, 1) & 0x00000004;
	}

    for (Delay = 0; Delay < 80000; Delay++);
	XGpio_WriteReg(XPAR_PUSH_BUTTONS_5BITS_BASEADDR, 0, 0x0);

	xil_printf("Press east button\r\n\r\n");
	Button = 0;
	while (Button == 0){
		Button = XGpio_ReadReg(XPAR_PUSH_BUTTONS_5BITS_BASEADDR, 1)  & 0x00000008;
	}

    for (Delay = 0; Delay < 80000; Delay++);
	XGpio_WriteReg(XPAR_PUSH_BUTTONS_5BITS_BASEADDR, 0, 0x0);

	xil_printf("Press north button\r\n\r\n");
	Button =0;
	while (Button == 0){
		Button = XGpio_ReadReg(XPAR_PUSH_BUTTONS_5BITS_BASEADDR, 1) & 0x00000010;
	}

    for (Delay = 0; Delay < 80000; Delay++);
	XGpio_WriteReg(XPAR_PUSH_BUTTONS_5BITS_BASEADDR, 0, 0x0);

	xil_printf("Press center button\r\n\r\n");
	Button =0;
	while (Button == 0){
		Button = XGpio_ReadReg(XPAR_PUSH_BUTTONS_5BITS_BASEADDR, 1)  & 0x00000001;
	}

    for (Delay = 0; Delay < 800000; Delay++);
	XGpio_WriteReg(XPAR_PUSH_BUTTONS_5BITS_BASEADDR, 0, 0x0);

	xil_printf("Press any button\r\n\r\n");
	Button =0;
	while (Button == 0){
		Button = XGpio_ReadReg(XPAR_PUSH_BUTTONS_5BITS_BASEADDR, 1)  & 0x0000001F;
	}
	XGpio_WriteReg(XPAR_PUSH_BUTTONS_5BITS_BASEADDR, 0, 0x0);

	return(0);
}


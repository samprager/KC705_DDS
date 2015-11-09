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
*       (c) Copyright 2009 Xilinx Inc.
*       All rights reserved.
*
******************************************************************************/


#include "xparameters.h"
#include <stdio.h>
#include <stdlib.h>
#include "xgpio.h"
#include "xil_types.h"
#include "xuartns550_l.h"
//#include "xil_sprintf.h"


#ifndef UART_BASEADDR
#define UART_BASEADDR XPAR_UARTNS550_0_BASEADDR
#endif
#define UART_CLOCK    XPAR_UARTNS550_0_CLOCK_FREQ_HZ

#if !SIM
#define UART_BAUDRATE 9600                      /* real hardware */
#else
#define UART_BAUDRATE (UART_CLOCK / 16 / 3)     /* simulation */
#endif

#define	XGpio_mSetDataReg		XGpio_WriteReg
#define	XGpio_mGetDataReg		XGpio_ReadReg
#define	XGpio_mSetDataDirection	XGpio_WriteReg

#define XPAR_ROTARY_GPIO_BASEADDR XPAR_AXI_GPIO_4_BASEADDR


#define	DIR_LEFT	(-1)
#define	DIR_RIGHT	(+1)

// Main Loop
int hello_rotary(void)
{

    unsigned int data;
    int pulses=0, dir;
    char button=0;
    char button_pressed_print=0;
    char button_released_print=1;

	/***
    XUartNs550_SetBaud(UART_BASEADDR, UART_CLOCK, UART_BAUDRATE);
    XUartNs550_mSetLineControlReg(UART_BASEADDR, XUN_LCR_8_DATA_BITS);
    ***/

    xil_printf("\n\r********************************************************");
    xil_printf("\n\r********************************************************");
    xil_printf("\n\r**     KC705 - Rotary Switch Test                     **");
    xil_printf("\n\r********************************************************");
    xil_printf("\n\r********************************************************\r\n");
    xil_printf("Watch the ROTARY pulses count:\r\n");

    xil_printf("press any key to exit the test\r\n");
    XUartNs550_ReadReg(STDIN_BASEADDRESS, XUN_RBR_OFFSET);

    //set GPIO input mode
	XGpio_mSetDataReg(XPAR_ROTARY_GPIO_BASEADDR, 4, 0xffffffff);

	while(1)
	{
		/////////////////////////////////////
		// STATE 1: Get the direction pulse
		do
		{
			data = XGpio_mGetDataReg(XPAR_ROTARY_GPIO_BASEADDR, 0);
		/////////////////////////////////////
		// Check for button press or release - print once in either case
			if((data & 0x2) && (button == 0) && (button_pressed_print == 0))
			{
				button=1;
				xil_printf("Button pressed  [Exit: press anykey]\r\n");
				button_pressed_print = 1;
				button_released_print = 0;
			}
			if( !(data & 0x2) && (button == 1) && (button_released_print == 0))
			{
				button=0;
				xil_printf("Button released  [Exit: press anykey]\r\n");
				button_pressed_print = 0;
				button_released_print = 1;
			}
			
			// get hold of a pulse that tells one of below
			// 		bits 2,0 = 01 Left rotation
			//		bits 2,0 = 10 Right rotation
			//		bit 1     =  1 button press

			if(data & 0x1)
			{
				dir = DIR_LEFT;
				break;
			}
			if(data & 0x4)
			{
				dir = DIR_RIGHT;
				break;
			}

			if( XUartNs550_IsReceiveData(STDIN_BASEADDRESS) )
				break;

		} while( (data & 0x5) == 0);

		//////////////////////////////////////////////
		// STATE 2: Get the pulses from both switches
		do
		{
		// Catch button pushes during State 2
			if((data & 0x2) && (button == 0) && (button_pressed_print == 0))
			{
				button=1;
				xil_printf("Button pressed  [Exit: press anykey]\r\n");
				button_pressed_print = 1;
				button_released_print = 0;
			}
			if( !(data & 0x2) && (button == 1) && (button_released_print == 0))
			{
				button=0;
				xil_printf("Button released  [Exit: press anykey]\r\n");
				button_pressed_print = 0;
				button_released_print = 1;
			}
			data = XGpio_mGetDataReg(XPAR_ROTARY_GPIO_BASEADDR, 0);
			if( XUartNs550_IsReceiveData(STDIN_BASEADDRESS) )
				break;

		} while( ( (data & 0x5) != 0x5 ));

		/////////////////////////////////////////////////////
		// STATE 3: Get the pulses from both switches to NULL
		do
		{
		// Catch button pushes during State 3
			if((data & 0x2) && (button == 0) && (button_pressed_print == 0))
			{
				button=1;
				xil_printf("Button pressed  [Exit: press anykey]\r\n");
				button_pressed_print = 1;
				button_released_print = 0;
			}
			if( !(data & 0x2) && (button == 1) && (button_released_print == 0))
			{
				button=0;
				xil_printf("Button released  [Exit: press anykey]\r\n");
				button_pressed_print = 0;
				button_released_print = 1;
			}
			data = XGpio_mGetDataReg(XPAR_ROTARY_GPIO_BASEADDR, 0);
			if( XUartNs550_IsReceiveData(STDIN_BASEADDRESS) )
				break;
		} while( (data & 0x5) != 0);

		// PRESS ANY KEY TO EXIT
		if( XUartNs550_IsReceiveData(STDIN_BASEADDRESS) )
			break;

		// RESULT TO USER
		pulses += dir;
		xil_printf("%s-%d  [Exit: press anykey]\r\n",
				(dir==DIR_RIGHT) ? "Right" : "Left",
				abs(pulses) );
	}
	XUartNs550_ReadReg(STDIN_BASEADDRESS, XUN_RBR_OFFSET);

	return 0;
}

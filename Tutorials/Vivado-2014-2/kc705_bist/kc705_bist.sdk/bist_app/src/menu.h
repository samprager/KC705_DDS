/* $Id: */
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
/*****************************************************************************/
/**
*
* @file menu.h
*
* Defines the functions and includes the proper headers for the board_test_app.
*
* <pre>
* MODIFICATION HISTORY:
*
* Ver   Who  Date     Changes
* ----- ---- -------- -------------------------------------------------------
* 1.00a cmc  08/27/09 First release
* </pre>
*
******************************************************************************/
/***************************** Include Files *********************************/

#include "xparameters.h"	/* defines XPAR values */
#include "xuartns550_l.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/************************** Constant Definitions ****************************/
#define UART_BAUDRATE 9600

/***************** Macros (Inline Functions) Definitions *********************/


/**************************** Type Definitions ******************************/

/************************** Function Prototypes *****************************/

int hello_uart (int uartbaud);
int hello_led (void);
int hello_timer (void);
int hello_spi (void);
int hello_iic (void);
int hello_temac (void);
int hello_switch (void);
int hello_mem (void);


/************************** Variable Definitions ****************************/



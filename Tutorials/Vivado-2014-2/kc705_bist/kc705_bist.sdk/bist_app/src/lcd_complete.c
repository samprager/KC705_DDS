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
*       (c) Copyright 2007, 2009 Xilinx Inc.
*       All rights reserved.
*
******************************************************************************/

#include <stdio.h>
//#include "lcd_sleep.h"
#include "xgpio_l.h"
#include "xparameters.h"
#include <ctype.h>

// usec delay timer during initialization, important to change if
// clock speed changes
#define INIT_DELAY 100000
#define INST_DELAY 10000    //usec delay timer between instructions
#define DATA_DELAY 10000    //usec delay timer between data

#define	XGpio_mSetDataReg		XGpio_WriteReg
#define	XGpio_mSetDataDirection	XGpio_WriteReg

#ifndef true
#define true 1
#endif

#ifndef false
#define false 0
#endif

#define XPAR_LCD_GPIO_BASEADDR XPAR_AXI_GPIO_1_BASEADDR


extern char inbyte(void);

void InitInst(void);
void WriteInst(unsigned long inst1, unsigned long inst2);
void WriteData(unsigned long data1, unsigned long data2);
void LCDOn(void);
void LCDOff(void);
void LCDClear(void);
void LCDInit(void);
void MoveCursorHome(void);
void MoveCursorLeft(void);
void MoveCursorRight(void);
void LCDSetLine(int line);
void LCDPrintChar(char c);
void LCDPrintString(char * line1, char * line2);
void LCDTest(void);
void LCDTest_main(void);

void msleep(int delay);

/*
#------------------------------------------------------------------------------
# IO Pad Location Constraints / Properties for Character LCD GPIO
#------------------------------------------------------------------------------

SPARTAN:
NET gpio_char_lcd<6> LOC = AE13; # LCD_E
NET gpio_char_lcd<6> PULLDOWN;
NET gpio_char_lcd<5> LOC = AC17; # LCD_RS
NET gpio_char_lcd<4> LOC = AB17; # LCD_RW
NET gpio_char_lcd<3> LOC = AF12; # LCD_DB7
NET gpio_char_lcd<2> LOC = AE12; # LCD_DB6
NET gpio_char_lcd<1> LOC = AC10; # LCD_DB5
NET gpio_char_lcd<0> LOC = AB10; # LCD_DB4

KINTEX-7 (KC705):
Net LCD_GPIO_IO<0> ## E
Net LCD_GPIO_IO<1> ## RS
Net LCD_GPIO_IO<2> ## RW
Net LCD_GPIO_IO<3> ## DB7
Net LCD_GPIO_IO<4> ## DB6
Net LCD_GPIO_IO<5> ## DB5
Net LCD_GPIO_IO<6> ## DB4
*/


///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////

int kc_SendCmd(int cmd)
{
	int temp=0;

	// STEP1: send D7-D4, rs=0,rw=0,en=1
	// get upper nibble from given command
	temp |= (cmd& 0x10) << 2;	// place D4 in position 6
	temp |= (cmd& 0x20) << 0;	// place D5 in position 5
	temp |= (cmd& 0x40) >> 2;	// place D6 in position 4
	temp |= (cmd& 0x80) >> 4;	// place D7 in position 3
	// en=1, rs=0, rw=0
	temp |= 0x1;
	//xil_printf("cmd.h1: 0x%x\r\n", temp);
	msleep(1);
	XGpio_mSetDataReg(XPAR_LCD_GPIO_BASEADDR, 0, temp);
	// en=0, rs=0, rw=0
	temp &= ~(0x1);
	//xil_printf("cmd.h2: 0x%x\r\n", temp);
	msleep(1);
	XGpio_mSetDataReg(XPAR_LCD_GPIO_BASEADDR, 0, temp);


	// STEP2: send D3-D0, rs=0,rw=0,en=0
	// get lower nibble from given command
	temp=0;
	temp |= (cmd& 0x01) << 6;	// place D0 in position 6
	temp |= (cmd& 0x02) << 4;	// place D1 in position 5
	temp |= (cmd& 0x04) << 2;	// place D2 in position 4
	temp |= (cmd& 0x08) >> 0;	// place D3 in position 3
	// en=1, rs=0, rw=0
	temp |= 0x1;
	//xil_printf("cmd.l1: 0x%x\r\n", temp);
	msleep(1);
	XGpio_mSetDataReg(XPAR_LCD_GPIO_BASEADDR, 0, temp);
	// en=0, rs=0, rw=0
	temp &= ~(0x1);
	//xil_printf("cmd.l2: 0x%x\r\n\r\n", temp);
	msleep(1);
	XGpio_mSetDataReg(XPAR_LCD_GPIO_BASEADDR, 0, temp);

	// wait for busy / delay
	msleep(1);

	return 0;
}
int kc_SendData(int data)
{
	int temp=0;

	// STEP1: send D7-D4, rs=0,rw=0,en=1
	// get upper nibble from given command
	temp |= (data& 0x10) << 2;	// place D4 in position 6
	temp |= (data& 0x20) << 0;	// place D5 in position 5
	temp |= (data& 0x40) >> 2;	// place D6 in position 4
	temp |= (data& 0x80) >> 4;	// place D7 in position 3
	// en=1, rs=1, rw=0
	temp |= 0x3;
	//xil_printf("dat.h1: 0x%x\r\n", temp);
	msleep(1);
	XGpio_mSetDataReg(XPAR_LCD_GPIO_BASEADDR, 0, temp);
	XGpio_mSetDataReg(XPAR_LCD_GPIO_BASEADDR, 0, temp);	// to introduce little delay
	// en=0, rs=1, rw=0
	temp &= ~(0x1);
	//xil_printf("dat.h2: 0x%x\r\n", temp);
	msleep(1);
	XGpio_mSetDataReg(XPAR_LCD_GPIO_BASEADDR, 0, temp);


	// STEP2: send D3-D0, rs=0,rw=0,en=0
	// get lower nibble from given command
	temp=0;
	temp |= (data& 0x01) << 6;	// place D0 in position 6
	temp |= (data& 0x02) << 4;	// place D1 in position 5
	temp |= (data& 0x04) << 2;	// place D2 in position 4
	temp |= (data& 0x08) >> 0;	// place D3 in position 3
	// en=1, rs=1, rw=0
	temp |= 0x3;
	//xil_printf("dat.l1: 0x%x\r\n", temp);
	msleep(1);
	XGpio_mSetDataReg(XPAR_LCD_GPIO_BASEADDR, 0, temp);
	XGpio_mSetDataReg(XPAR_LCD_GPIO_BASEADDR, 0, temp);	// to introduce little delay
	// en=0, rs=1, rw=0
	temp &= ~(0x1);
	//xil_printf("dat.l2: 0x%x\r\n\r\n", temp);
	msleep(1);
	XGpio_mSetDataReg(XPAR_LCD_GPIO_BASEADDR, 0, temp);

	// wait for busy / delay
	msleep(1);


	return 0;
}
int kc_Busy(void)
{
	///// METHOD 1
	
	// set D7 input port
	// en=1
	// rs=0
	// rw=1
	// LOOP
	// 	en=0
	//	en=1
	//	if(D7==1) goto LOOP
	// set D7 output

	///// METHOD 2
	
	// for(i=0; i<10000; i++)

	return 0;
}

int kc_FunctionSet(int bits, int lines)
{
	int cmd= 0x28;	// default: 4bits, 2lines

	xil_printf("function set\r\n");
	if( (bits==8) && (lines==1) )
		cmd = 0x30;
	if( (bits==8) && (lines==2) )
		cmd = 0x38;
	if( (bits==4) && (lines==1) )
		cmd = 0x20;
	if( (bits==4) && (lines==2) )
		cmd = 0x28;

	kc_SendCmd(cmd);
	return 0;
}

int kc_EntryMode(int mode)
{
	int cmd = 0x6;	// no shift, auto increment

	xil_printf("entry mode\r\n");

	kc_SendCmd(cmd);
	return 0;
}

int kc_CursorMode(int mode)
{
	int cmd = 0xe;	// default: cursor ON

	xil_printf("cursor mode\r\n");

	if(mode==0) cmd=0x0c;	// display ON, cursor OFF
	if(mode==1) cmd=0x0e;	// display ON, cursor ON
	if(mode==2) cmd=0x0f;	// display ON, cursor BLINK

	kc_SendCmd(cmd);
	return 0;
}

int kc_DisplayMode(int mode)
{
	int cmd = 0x8;	// display OFF, cursor OFF (DDRAM content intact)

	xil_printf("display mode\r\n");

	if(mode==0) cmd=0x08;	// display OFF, DDRAM content INTACT
	if(mode==1) cmd=0x01;	// display OFF, DDRAM content CLEAR

	kc_SendCmd(cmd);
	return 0;
}

int kc_ShiftMode(int mode)
{
	int cmd = 0x18;	// shift left

	xil_printf("shift mode\r\n");

	if(mode==0) cmd=0x18;	// shift left
	if(mode==1) cmd=0x1c;	// shift right
	if(mode==2) cmd=0x10;	// move cursor left  by 1 position
	if(mode==3) cmd=0x14;	// move cursor right by 1 position

	kc_SendCmd(cmd);
	return 0;
}


int kc_SetDDRAM(int addr)
{
	int cmd;
	//xil_printf("set DDRAM addr\r\n");
       
	cmd = 0x80;	// set DDRAM command (line1 starts at 0x80, line2 starts at 0xc0)
	cmd |= addr;

	kc_SendCmd(cmd);
	return 0;
}

int kc_initLCD(void)
{
	xil_printf("reset LCD\r\n");

	XGpio_mSetDataReg(XPAR_LCD_GPIO_BASEADDR, 4, 0);

	//// RESET, needed for 4-bit mode only
	XGpio_mSetDataReg(XPAR_LCD_GPIO_BASEADDR, 0, 0xff);
	msleep(20);
	//xil_printf("1\r\n");

	//send cmd 0x30
	XGpio_mSetDataReg(XPAR_LCD_GPIO_BASEADDR, 0, 0x61);
	XGpio_mSetDataReg(XPAR_LCD_GPIO_BASEADDR, 0, 0x60);
	msleep(15);
	//xil_printf("2\r\n");

	//send cmd 0x30
	XGpio_mSetDataReg(XPAR_LCD_GPIO_BASEADDR, 0, 0x61);
	XGpio_mSetDataReg(XPAR_LCD_GPIO_BASEADDR, 0, 0x60);
	msleep(5);
	//xil_printf("3\r\n");

	//send cmd 0x30
	XGpio_mSetDataReg(XPAR_LCD_GPIO_BASEADDR, 0, 0x61);
	XGpio_mSetDataReg(XPAR_LCD_GPIO_BASEADDR, 0, 0x60);
	msleep(5);
	//xil_printf("4\r\n");

	//send cmd 0x20		// set 4-bit mode
	XGpio_mSetDataReg(XPAR_LCD_GPIO_BASEADDR, 0, 0x21);
	XGpio_mSetDataReg(XPAR_LCD_GPIO_BASEADDR, 0, 0x20);
	msleep(5);
	// note: BUSY flag will be valid only after above sequence

	//xil_printf("initializing LCD\r\n");
	//// INITIALIZATION, common to 4bit and 8bit modes
	kc_FunctionSet(4, 2);	// 0x28
	kc_CursorMode(2);	// 0x0f
	kc_EntryMode(0);	// 0x06
	kc_SetDDRAM(0);	// 0x80


	#if 0	// TEST PURPOSE ONLY
	kc_SendData('A');
	kc_SendData('B');
	kc_SendData('C');
	kc_SendData('D');
	kc_SendData('E');
	kc_SendData('F');
	kc_SendData('G');
	kc_SendData('H');
	kc_SendData('I');
	kc_SendData('J');
	kc_SendData('K');
	kc_SendData('L');
	kc_SendData('M');
	kc_SendData('N');
	kc_SendData('O');
	kc_SendData('P');

	kc_SetDDRAM(0x40);
	kc_SendData('Q');
	kc_SendData('R');
	kc_SendData('S');
	kc_SendData('T');
	kc_SendData('U');
	kc_SendData('V');
	kc_SendData('W');
	kc_SendData('X');
	kc_SendData('Y');
	kc_SendData('Z');
	#endif

	return 0;
}

int kc_LCDPrintString (char* str1, char* str2)
{
	int i;
	kc_SetDDRAM(0x0);
	xil_printf("Watch below lines on LCD\r\n");

	for(i=0; i<16; i++)
	{
		kc_SendData(*str1);
		xil_printf("%c", *str1);
		str1++;
	}

	kc_SetDDRAM(0x40);
	xil_printf("\r\n");
	for(i=0; i<16; i++)
	{
		kc_SendData(*str2);
		xil_printf("%c", *str2);
		str2++;
	}
	xil_printf("\r\n");
	return 0;
}

void msleep(int delay)
{
	int i; //, j;

	for(;delay>0;delay--)
	{
		for(i=0; i<2500;i++)
		{
			//for(j=0; j<1;j++);
		}
	}
	return;
}



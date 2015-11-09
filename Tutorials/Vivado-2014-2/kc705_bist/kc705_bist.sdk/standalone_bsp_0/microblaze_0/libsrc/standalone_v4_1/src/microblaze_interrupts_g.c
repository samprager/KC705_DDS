
/*******************************************************************
*
* CAUTION: This file is automatically generated by HSM.
* Version: 
* DO NOT EDIT.
*
*  v (64-bit)
SW Build (by ) on 
Copyright 1986-2014 Xilinx, Inc. All Rights Reserved.
* 
* Description: Interrupt Handler Table for MicroBlaze Processor
*
*******************************************************************/

#include "microblaze_interrupts_i.h"
#include "xparameters.h"


extern void XIntc_DeviceInterruptHandler (void *);

/*
* The interrupt handler table for microblaze processor
*/

MB_InterruptVectorTableEntry MB_InterruptVectorTable[] =
{
{	XIntc_DeviceInterruptHandler,
	(void*) XPAR_MICROBLAZE_0_AXI_INTC_DEVICE_ID}
};

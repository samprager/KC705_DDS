//------------------------------------------------------------------------------
// Title      : Demo testbench
// Project    : Tri-Mode Ethernet MAC
//------------------------------------------------------------------------------
// File       : demo_tb.v
// -----------------------------------------------------------------------------
// (c) Copyright 2004-2013 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES. 
// -----------------------------------------------------------------------------
// Description: This testbench will exercise the ports of the MAC core
//              to demonstrate the functionality.
//------------------------------------------------------------------------------
//
// This testbench performs the following operations on the MAC core
// and its design example:

//  - The MDIO interface will respond to a read request with data to prevent the
//    example design thinking it is real hardware

//  - Four frames are then pushed into the receiver from the PHY
//    interface (GMII/MII or RGMII):
//    The first is of minimum length (Length/Type = Length = 46 bytes).
//    The second frame sets Length/Type to Type = 0x8000.
//    The third frame has an error inserted.
//    The fourth frame only sends 4 bytes of data: the remainder of the
//    data field is padded up to the minimum frame length i.e. 46 bytes.

//  - These frames are then parsed from the MAC into the MAC's design
//    example.  The design example provides a MAC user loopback
//    function so that frames which are received without error will be
//    looped back to the MAC transmitter and transmitted back to the
//    testbench.  The testbench verifies that this data matches that
//    previously injected into the receiver.

//  - The four frames are then re-sent at 100Mb/s, 10Mb/s and finally 1Gb/s again.

//----------------------------------------------------------------------
//                         DEMONSTRATION TESTBENCH                     |
//                                                                     |
//                                                                     |
//     ----------------------------------------------                  |
//     |           TOP LEVEL WRAPPER (DUT)          |                  |
//     |  -------------------    ----------------   |                  |
//     |  | USER LOOPBACK   |    | TRI-MODE     |   |                  |
//     |  | DESIGN EXAMPLE  |    | ETHERNET MAC |   |                  |
//     |  |                 |    | CORE         |   |                  |
//     |  |                 |    |              |   |       Monitor    |
//     |  |         ------->|--->|          Tx  |-------->  Frames     |
//     |  |         |       |    |          PHY |   |                  |
//     |  |         |       |    |          I/F |   |                  |
//     |  |         |       |    |              |   |                  |
//     |  |         |       |    |              |   |                  |
//     |  |         |       |    |              |   |                  |
//     |  |         |       |    |          Rx  |   |                  |
//     |  |         |       |    |          PHY |   |                  |
//     |  |         --------|<---|          I/F |<-------- Generate    |
//     |  |                 |    |              |   |      Frames      |
//     |  -------------------    ----------------   |                  |
//     --------------------------------^-------------                  |
//                                     |                               |
//                                     |                               |
//                                 Stimulate                           |
//                               Management I/F                        |
//                               (if present)                          |
//                                                                     |
//----------------------------------------------------------------------


`timescale 1ps / 1ps

//------------------------------------------------------------------------------
// This module is the demonstration testbench
//------------------------------------------------------------------------------

module demo_tb;

  
  
  
  parameter TB_MODE = "DEMO";

  `define FRAME_TYP [8*62+62+62+8*4+4+4+8*4+4+4+1:1]

  //----------------------------------------------------------------------------
  // types to support frame data
  //----------------------------------------------------------------------------

   kc705_ethernet_rgmii_frame_typ frame0();
   kc705_ethernet_rgmii_frame_typ frame1();
   kc705_ethernet_rgmii_frame_typ frame2();
   kc705_ethernet_rgmii_frame_typ frame3();
   kc705_ethernet_rgmii_frame_typ rx_stimulus_working_frame();
   kc705_ethernet_rgmii_frame_typ tx_monitor_working_frame();


  //----------------------------------------------------------------------------
  // Stimulus - Frame data
  //----------------------------------------------------------------------------
  // The following constant holds the stimulus for the testbench. It is
  // an ordered array of frames, with frame 0 the first to be injected
  // into the core transmit interface by the testbench.
  //----------------------------------------------------------------------------
  initial
  begin
    //-----------
    // Frame 0
    //-----------
    frame0.data[0]  = 8'hDA;  frame0.valid[0]  = 1'b1;  frame0.error[0]  = 1'b0; // Destination Address (DA)
    frame0.data[1]  = 8'h02;  frame0.valid[1]  = 1'b1;  frame0.error[1]  = 1'b0;
    frame0.data[2]  = 8'h03;  frame0.valid[2]  = 1'b1;  frame0.error[2]  = 1'b0;
    frame0.data[3]  = 8'h04;  frame0.valid[3]  = 1'b1;  frame0.error[3]  = 1'b0;
    frame0.data[4]  = 8'h05;  frame0.valid[4]  = 1'b1;  frame0.error[4]  = 1'b0;
    frame0.data[5]  = 8'h06;  frame0.valid[5]  = 1'b1;  frame0.error[5]  = 1'b0;
    frame0.data[6]  = 8'h5A;  frame0.valid[6]  = 1'b1;  frame0.error[6]  = 1'b0; // Source Address  (5A)
    frame0.data[7]  = 8'h02;  frame0.valid[7]  = 1'b1;  frame0.error[7]  = 1'b0;
    frame0.data[8]  = 8'h03;  frame0.valid[8]  = 1'b1;  frame0.error[8]  = 1'b0;
    frame0.data[9]  = 8'h04;  frame0.valid[9]  = 1'b1;  frame0.error[9]  = 1'b0;
    frame0.data[10] = 8'h05;  frame0.valid[10] = 1'b1;  frame0.error[10] = 1'b0;
    frame0.data[11] = 8'h06;  frame0.valid[11] = 1'b1;  frame0.error[11] = 1'b0;
    frame0.data[12] = 8'h00;  frame0.valid[12] = 1'b1;  frame0.error[12] = 1'b0;
    frame0.data[13] = 8'h2E;  frame0.valid[13] = 1'b1;  frame0.error[13] = 1'b0; // Length/Type = Length = 46
    frame0.data[14] = 8'h01;  frame0.valid[14] = 1'b1;  frame0.error[14] = 1'b0;
    frame0.data[15] = 8'h02;  frame0.valid[15] = 1'b1;  frame0.error[15] = 1'b0;
    frame0.data[16] = 8'h03;  frame0.valid[16] = 1'b1;  frame0.error[16] = 1'b0;
    frame0.data[17] = 8'h04;  frame0.valid[17] = 1'b1;  frame0.error[17] = 1'b0;
    frame0.data[18] = 8'h05;  frame0.valid[18] = 1'b1;  frame0.error[18] = 1'b0;
    frame0.data[19] = 8'h06;  frame0.valid[19] = 1'b1;  frame0.error[19] = 1'b0;
    frame0.data[20] = 8'h07;  frame0.valid[20] = 1'b1;  frame0.error[20] = 1'b0;
    frame0.data[21] = 8'h08;  frame0.valid[21] = 1'b1;  frame0.error[21] = 1'b0;
    frame0.data[22] = 8'h09;  frame0.valid[22] = 1'b1;  frame0.error[22] = 1'b0;
    frame0.data[23] = 8'h0A;  frame0.valid[23] = 1'b1;  frame0.error[23] = 1'b0;
    frame0.data[24] = 8'h0B;  frame0.valid[24] = 1'b1;  frame0.error[24] = 1'b0;
    frame0.data[25] = 8'h0C;  frame0.valid[25] = 1'b1;  frame0.error[25] = 1'b0;
    frame0.data[26] = 8'h0D;  frame0.valid[26] = 1'b1;  frame0.error[26] = 1'b0;
    frame0.data[27] = 8'h0E;  frame0.valid[27] = 1'b1;  frame0.error[27] = 1'b0;
    frame0.data[28] = 8'h0F;  frame0.valid[28] = 1'b1;  frame0.error[28] = 1'b0;
    frame0.data[29] = 8'h10;  frame0.valid[29] = 1'b1;  frame0.error[29] = 1'b0;
    frame0.data[30] = 8'h11;  frame0.valid[30] = 1'b1;  frame0.error[30] = 1'b0;
    frame0.data[31] = 8'h12;  frame0.valid[31] = 1'b1;  frame0.error[31] = 1'b0;
    frame0.data[32] = 8'h13;  frame0.valid[32] = 1'b1;  frame0.error[32] = 1'b0;
    frame0.data[33] = 8'h14;  frame0.valid[33] = 1'b1;  frame0.error[33] = 1'b0;
    frame0.data[34] = 8'h15;  frame0.valid[34] = 1'b1;  frame0.error[34] = 1'b0;
    frame0.data[35] = 8'h16;  frame0.valid[35] = 1'b1;  frame0.error[35] = 1'b0;
    frame0.data[36] = 8'h17;  frame0.valid[36] = 1'b1;  frame0.error[36] = 1'b0;
    frame0.data[37] = 8'h18;  frame0.valid[37] = 1'b1;  frame0.error[37] = 1'b0;
    frame0.data[38] = 8'h19;  frame0.valid[38] = 1'b1;  frame0.error[38] = 1'b0;
    frame0.data[39] = 8'h1A;  frame0.valid[39] = 1'b1;  frame0.error[39] = 1'b0;
    frame0.data[40] = 8'h1B;  frame0.valid[40] = 1'b1;  frame0.error[40] = 1'b0;
    frame0.data[41] = 8'h1C;  frame0.valid[41] = 1'b1;  frame0.error[41] = 1'b0;
    frame0.data[42] = 8'h1D;  frame0.valid[42] = 1'b1;  frame0.error[42] = 1'b0;
    frame0.data[43] = 8'h1E;  frame0.valid[43] = 1'b1;  frame0.error[43] = 1'b0;
    frame0.data[44] = 8'h1F;  frame0.valid[44] = 1'b1;  frame0.error[44] = 1'b0;
    frame0.data[45] = 8'h20;  frame0.valid[45] = 1'b1;  frame0.error[45] = 1'b0;
    frame0.data[46] = 8'h21;  frame0.valid[46] = 1'b1;  frame0.error[46] = 1'b0;
    frame0.data[47] = 8'h22;  frame0.valid[47] = 1'b1;  frame0.error[47] = 1'b0;
    frame0.data[48] = 8'h23;  frame0.valid[48] = 1'b1;  frame0.error[48] = 1'b0;
    frame0.data[49] = 8'h24;  frame0.valid[49] = 1'b1;  frame0.error[49] = 1'b0;
    frame0.data[50] = 8'h25;  frame0.valid[50] = 1'b1;  frame0.error[50] = 1'b0;
    frame0.data[51] = 8'h26;  frame0.valid[51] = 1'b1;  frame0.error[51] = 1'b0;
    frame0.data[52] = 8'h27;  frame0.valid[52] = 1'b1;  frame0.error[52] = 1'b0;
    frame0.data[53] = 8'h28;  frame0.valid[53] = 1'b1;  frame0.error[53] = 1'b0;
    frame0.data[54] = 8'h29;  frame0.valid[54] = 1'b1;  frame0.error[54] = 1'b0;
    frame0.data[55] = 8'h2A;  frame0.valid[55] = 1'b1;  frame0.error[55] = 1'b0;
    frame0.data[56] = 8'h2B;  frame0.valid[56] = 1'b1;  frame0.error[56] = 1'b0;
    frame0.data[57] = 8'h2C;  frame0.valid[57] = 1'b1;  frame0.error[57] = 1'b0;
    frame0.data[58] = 8'h2D;  frame0.valid[58] = 1'b1;  frame0.error[58] = 1'b0;
    frame0.data[59] = 8'h2E;  frame0.valid[59] = 1'b1;  frame0.error[59] = 1'b0;  // 46th Byte of Data
    // unused
    frame0.data[60] = 8'h00;  frame0.valid[60] = 1'b0;  frame0.error[60] = 1'b0;
    frame0.data[61] = 8'h00;  frame0.valid[61] = 1'b0;  frame0.error[61] = 1'b0;

    // No error in this frame
    frame0.bad_frame  = 1'b0;


    //-----------
    // Frame 1
    //-----------
    frame1.data[0]  = 8'hDA;  frame1.valid[0]  = 1'b1;  frame1.error[0]  = 1'b0; // Destination Address (DA)
    frame1.data[1]  = 8'h02;  frame1.valid[1]  = 1'b1;  frame1.error[1]  = 1'b0;
    frame1.data[2]  = 8'h03;  frame1.valid[2]  = 1'b1;  frame1.error[2]  = 1'b0;
    frame1.data[3]  = 8'h04;  frame1.valid[3]  = 1'b1;  frame1.error[3]  = 1'b0;
    frame1.data[4]  = 8'h05;  frame1.valid[4]  = 1'b1;  frame1.error[4]  = 1'b0;
    frame1.data[5]  = 8'h06;  frame1.valid[5]  = 1'b1;  frame1.error[5]  = 1'b0;
    frame1.data[6]  = 8'h5A;  frame1.valid[6]  = 1'b1;  frame1.error[6]  = 1'b0; // Source Address  (5A)
    frame1.data[7]  = 8'h02;  frame1.valid[7]  = 1'b1;  frame1.error[7]  = 1'b0;
    frame1.data[8]  = 8'h03;  frame1.valid[8]  = 1'b1;  frame1.error[8]  = 1'b0;
    frame1.data[9]  = 8'h04;  frame1.valid[9]  = 1'b1;  frame1.error[9]  = 1'b0;
    frame1.data[10] = 8'h05;  frame1.valid[10] = 1'b1;  frame1.error[10] = 1'b0;
    frame1.data[11] = 8'h06;  frame1.valid[11] = 1'b1;  frame1.error[11] = 1'b0;
    frame1.data[12] = 8'h80;  frame1.valid[12] = 1'b1;  frame1.error[12] = 1'b0; // Length/Type = Type = 8000
    frame1.data[13] = 8'h00;  frame1.valid[13] = 1'b1;  frame1.error[13] = 1'b0;
    frame1.data[14] = 8'h01;  frame1.valid[14] = 1'b1;  frame1.error[14] = 1'b0;
    frame1.data[15] = 8'h02;  frame1.valid[15] = 1'b1;  frame1.error[15] = 1'b0;
    frame1.data[16] = 8'h03;  frame1.valid[16] = 1'b1;  frame1.error[16] = 1'b0;
    frame1.data[17] = 8'h04;  frame1.valid[17] = 1'b1;  frame1.error[17] = 1'b0;
    frame1.data[18] = 8'h05;  frame1.valid[18] = 1'b1;  frame1.error[18] = 1'b0;
    frame1.data[19] = 8'h06;  frame1.valid[19] = 1'b1;  frame1.error[19] = 1'b0;
    frame1.data[20] = 8'h07;  frame1.valid[20] = 1'b1;  frame1.error[20] = 1'b0;
    frame1.data[21] = 8'h08;  frame1.valid[21] = 1'b1;  frame1.error[21] = 1'b0;
    frame1.data[22] = 8'h09;  frame1.valid[22] = 1'b1;  frame1.error[22] = 1'b0;
    frame1.data[23] = 8'h0A;  frame1.valid[23] = 1'b1;  frame1.error[23] = 1'b0;
    frame1.data[24] = 8'h0B;  frame1.valid[24] = 1'b1;  frame1.error[24] = 1'b0;
    frame1.data[25] = 8'h0C;  frame1.valid[25] = 1'b1;  frame1.error[25] = 1'b0;
    frame1.data[26] = 8'h0D;  frame1.valid[26] = 1'b1;  frame1.error[26] = 1'b0;
    frame1.data[27] = 8'h0E;  frame1.valid[27] = 1'b1;  frame1.error[27] = 1'b0;
    frame1.data[28] = 8'h0F;  frame1.valid[28] = 1'b1;  frame1.error[28] = 1'b0;
    frame1.data[29] = 8'h10;  frame1.valid[29] = 1'b1;  frame1.error[29] = 1'b0;
    frame1.data[30] = 8'h11;  frame1.valid[30] = 1'b1;  frame1.error[30] = 1'b0;
    frame1.data[31] = 8'h12;  frame1.valid[31] = 1'b1;  frame1.error[31] = 1'b0;
    frame1.data[32] = 8'h13;  frame1.valid[32] = 1'b1;  frame1.error[32] = 1'b0;
    frame1.data[33] = 8'h14;  frame1.valid[33] = 1'b1;  frame1.error[33] = 1'b0;
    frame1.data[34] = 8'h15;  frame1.valid[34] = 1'b1;  frame1.error[34] = 1'b0;
    frame1.data[35] = 8'h16;  frame1.valid[35] = 1'b1;  frame1.error[35] = 1'b0;
    frame1.data[36] = 8'h17;  frame1.valid[36] = 1'b1;  frame1.error[36] = 1'b0;
    frame1.data[37] = 8'h18;  frame1.valid[37] = 1'b1;  frame1.error[37] = 1'b0;
    frame1.data[38] = 8'h19;  frame1.valid[38] = 1'b1;  frame1.error[38] = 1'b0;
    frame1.data[39] = 8'h1A;  frame1.valid[39] = 1'b1;  frame1.error[39] = 1'b0;
    frame1.data[40] = 8'h1B;  frame1.valid[40] = 1'b1;  frame1.error[40] = 1'b0;
    frame1.data[41] = 8'h1C;  frame1.valid[41] = 1'b1;  frame1.error[41] = 1'b0;
    frame1.data[42] = 8'h1D;  frame1.valid[42] = 1'b1;  frame1.error[42] = 1'b0;
    frame1.data[43] = 8'h1E;  frame1.valid[43] = 1'b1;  frame1.error[43] = 1'b0;
    frame1.data[44] = 8'h1F;  frame1.valid[44] = 1'b1;  frame1.error[44] = 1'b0;
    frame1.data[45] = 8'h20;  frame1.valid[45] = 1'b1;  frame1.error[45] = 1'b0;
    frame1.data[46] = 8'h21;  frame1.valid[46] = 1'b1;  frame1.error[46] = 1'b0;
    frame1.data[47] = 8'h22;  frame1.valid[47] = 1'b1;  frame1.error[47] = 1'b0;
    frame1.data[48] = 8'h23;  frame1.valid[48] = 1'b1;  frame1.error[48] = 1'b0;
    frame1.data[49] = 8'h24;  frame1.valid[49] = 1'b1;  frame1.error[49] = 1'b0;
    frame1.data[50] = 8'h25;  frame1.valid[50] = 1'b1;  frame1.error[50] = 1'b0;
    frame1.data[51] = 8'h26;  frame1.valid[51] = 1'b1;  frame1.error[51] = 1'b0;
    frame1.data[52] = 8'h27;  frame1.valid[52] = 1'b1;  frame1.error[52] = 1'b0;
    frame1.data[53] = 8'h28;  frame1.valid[53] = 1'b1;  frame1.error[53] = 1'b0;
    frame1.data[54] = 8'h29;  frame1.valid[54] = 1'b1;  frame1.error[54] = 1'b0;
    frame1.data[55] = 8'h2A;  frame1.valid[55] = 1'b1;  frame1.error[55] = 1'b0;
    frame1.data[56] = 8'h2B;  frame1.valid[56] = 1'b1;  frame1.error[56] = 1'b0;
    frame1.data[57] = 8'h2C;  frame1.valid[57] = 1'b1;  frame1.error[57] = 1'b0;
    frame1.data[58] = 8'h2D;  frame1.valid[58] = 1'b1;  frame1.error[58] = 1'b0;
    frame1.data[59] = 8'h2E;  frame1.valid[59] = 1'b1;  frame1.error[59] = 1'b0;
    frame1.data[60] = 8'h2F;  frame1.valid[60] = 1'b1;  frame1.error[60] = 1'b0; // 47th Data byte
    // unused
    frame1.data[61] = 8'h00;  frame1.valid[61] = 1'b0;  frame1.error[61] = 1'b0;

    // No error in this frame
    frame1.bad_frame  = 1'b0;


    //-----------
    // Frame 2
    //-----------
    frame2.data[0]  = 8'hDA;  frame2.valid[0]  = 1'b1;  frame2.error[0]  = 1'b0; // Destination Address (DA)
    frame2.data[1]  = 8'h02;  frame2.valid[1]  = 1'b1;  frame2.error[1]  = 1'b0;
    frame2.data[2]  = 8'h03;  frame2.valid[2]  = 1'b1;  frame2.error[2]  = 1'b0;
    frame2.data[3]  = 8'h04;  frame2.valid[3]  = 1'b1;  frame2.error[3]  = 1'b0;
    frame2.data[4]  = 8'h05;  frame2.valid[4]  = 1'b1;  frame2.error[4]  = 1'b0;
    frame2.data[5]  = 8'h06;  frame2.valid[5]  = 1'b1;  frame2.error[5]  = 1'b0;
    frame2.data[6]  = 8'h5A;  frame2.valid[6]  = 1'b1;  frame2.error[6]  = 1'b0; // Source Address  (5A)
    frame2.data[7]  = 8'h02;  frame2.valid[7]  = 1'b1;  frame2.error[7]  = 1'b0;
    frame2.data[8]  = 8'h03;  frame2.valid[8]  = 1'b1;  frame2.error[8]  = 1'b0;
    frame2.data[9]  = 8'h04;  frame2.valid[9]  = 1'b1;  frame2.error[9]  = 1'b0;
    frame2.data[10] = 8'h05;  frame2.valid[10] = 1'b1;  frame2.error[10] = 1'b0;
    frame2.data[11] = 8'h06;  frame2.valid[11] = 1'b1;  frame2.error[11] = 1'b0;
    frame2.data[12] = 8'h00;  frame2.valid[12] = 1'b1;  frame2.error[12] = 1'b0;
    frame2.data[13] = 8'h2E;  frame2.valid[13] = 1'b1;  frame2.error[13] = 1'b0; // Length/Type = Length = 46
    frame2.data[14] = 8'h01;  frame2.valid[14] = 1'b1;  frame2.error[14] = 1'b0;
    frame2.data[15] = 8'h02;  frame2.valid[15] = 1'b1;  frame2.error[15] = 1'b0;
    frame2.data[16] = 8'h03;  frame2.valid[16] = 1'b1;  frame2.error[16] = 1'b0;
    frame2.data[17] = 8'h00;  frame2.valid[17] = 1'b1;  frame2.error[17] = 1'b0; // Underrun this frame
    frame2.data[18] = 8'h00;  frame2.valid[18] = 1'b1;  frame2.error[18] = 1'b0;
    frame2.data[19] = 8'h00;  frame2.valid[19] = 1'b1;  frame2.error[19] = 1'b0;
    frame2.data[20] = 8'h00;  frame2.valid[20] = 1'b1;  frame2.error[20] = 1'b0;
    frame2.data[21] = 8'h00;  frame2.valid[21] = 1'b1;  frame2.error[21] = 1'b0;
    frame2.data[22] = 8'h00;  frame2.valid[22] = 1'b1;  frame2.error[22] = 1'b0;
    frame2.data[23] = 8'h00;  frame2.valid[23] = 1'b1;  frame2.error[23] = 1'b1; // Error asserted
    frame2.data[24] = 8'h00;  frame2.valid[24] = 1'b1;  frame2.error[24] = 1'b0;
    frame2.data[25] = 8'h00;  frame2.valid[25] = 1'b1;  frame2.error[25] = 1'b0;
    frame2.data[26] = 8'h00;  frame2.valid[26] = 1'b1;  frame2.error[26] = 1'b0;
    frame2.data[27] = 8'h00;  frame2.valid[27] = 1'b1;  frame2.error[27] = 1'b0;
    frame2.data[28] = 8'h00;  frame2.valid[28] = 1'b1;  frame2.error[28] = 1'b0;
    frame2.data[29] = 8'h00;  frame2.valid[29] = 1'b1;  frame2.error[29] = 1'b0;
    frame2.data[30] = 8'h00;  frame2.valid[30] = 1'b1;  frame2.error[30] = 1'b0;
    frame2.data[31] = 8'h00;  frame2.valid[31] = 1'b1;  frame2.error[31] = 1'b0;
    frame2.data[32] = 8'h00;  frame2.valid[32] = 1'b1;  frame2.error[32] = 1'b0;
    frame2.data[33] = 8'h00;  frame2.valid[33] = 1'b1;  frame2.error[33] = 1'b0;
    frame2.data[34] = 8'h00;  frame2.valid[34] = 1'b1;  frame2.error[34] = 1'b0;
    frame2.data[35] = 8'h00;  frame2.valid[35] = 1'b1;  frame2.error[35] = 1'b0;
    frame2.data[36] = 8'h00;  frame2.valid[36] = 1'b1;  frame2.error[36] = 1'b0;
    frame2.data[37] = 8'h00;  frame2.valid[37] = 1'b1;  frame2.error[37] = 1'b0;
    frame2.data[38] = 8'h00;  frame2.valid[38] = 1'b1;  frame2.error[38] = 1'b0;
    frame2.data[39] = 8'h00;  frame2.valid[39] = 1'b1;  frame2.error[39] = 1'b0;
    frame2.data[40] = 8'h00;  frame2.valid[40] = 1'b1;  frame2.error[40] = 1'b0;
    frame2.data[41] = 8'h00;  frame2.valid[41] = 1'b1;  frame2.error[41] = 1'b0;
    frame2.data[42] = 8'h00;  frame2.valid[42] = 1'b1;  frame2.error[42] = 1'b0;
    frame2.data[43] = 8'h00;  frame2.valid[43] = 1'b1;  frame2.error[43] = 1'b0;
    frame2.data[44] = 8'h00;  frame2.valid[44] = 1'b1;  frame2.error[44] = 1'b0;
    frame2.data[45] = 8'h00;  frame2.valid[45] = 1'b1;  frame2.error[45] = 1'b0;
    frame2.data[46] = 8'h00;  frame2.valid[46] = 1'b1;  frame2.error[46] = 1'b0;
    frame2.data[47] = 8'h00;  frame2.valid[47] = 1'b1;  frame2.error[47] = 1'b0;
    frame2.data[48] = 8'h00;  frame2.valid[48] = 1'b1;  frame2.error[48] = 1'b0;
    frame2.data[49] = 8'h00;  frame2.valid[49] = 1'b1;  frame2.error[49] = 1'b0;
    frame2.data[50] = 8'h00;  frame2.valid[50] = 1'b1;  frame2.error[50] = 1'b0;
    frame2.data[51] = 8'h00;  frame2.valid[51] = 1'b1;  frame2.error[51] = 1'b0;
    frame2.data[52] = 8'h00;  frame2.valid[52] = 1'b1;  frame2.error[52] = 1'b0;
    frame2.data[53] = 8'h00;  frame2.valid[53] = 1'b1;  frame2.error[53] = 1'b0;
    frame2.data[54] = 8'h00;  frame2.valid[54] = 1'b1;  frame2.error[54] = 1'b0;
    frame2.data[55] = 8'h00;  frame2.valid[55] = 1'b1;  frame2.error[55] = 1'b0;
    frame2.data[56] = 8'h00;  frame2.valid[56] = 1'b1;  frame2.error[56] = 1'b0;
    frame2.data[57] = 8'h00;  frame2.valid[57] = 1'b1;  frame2.error[57] = 1'b0;
    frame2.data[58] = 8'h00;  frame2.valid[58] = 1'b1;  frame2.error[58] = 1'b0;
    frame2.data[59] = 8'h00;  frame2.valid[59] = 1'b1;  frame2.error[59] = 1'b0;
    // unused
    frame2.data[60] = 8'h00;  frame2.valid[60] = 1'b0;  frame2.error[60] = 1'b0;
    frame2.data[61] = 8'h00;  frame2.valid[61] = 1'b0;  frame2.error[61] = 1'b0;

    // Error this frame
    frame2.bad_frame  = 1'b1;


    //-----------
    // Frame 3
    //-----------
    frame3.data[0]  = 8'hDA;  frame3.valid[0]  = 1'b1;  frame3.error[0]  = 1'b0; // Destination Address (DA)
    frame3.data[1]  = 8'h02;  frame3.valid[1]  = 1'b1;  frame3.error[1]  = 1'b0;
    frame3.data[2]  = 8'h03;  frame3.valid[2]  = 1'b1;  frame3.error[2]  = 1'b0;
    frame3.data[3]  = 8'h04;  frame3.valid[3]  = 1'b1;  frame3.error[3]  = 1'b0;
    frame3.data[4]  = 8'h05;  frame3.valid[4]  = 1'b1;  frame3.error[4]  = 1'b0;
    frame3.data[5]  = 8'h06;  frame3.valid[5]  = 1'b1;  frame3.error[5]  = 1'b0;
    frame3.data[6]  = 8'h5A;  frame3.valid[6]  = 1'b1;  frame3.error[6]  = 1'b0; // Source Address  (5A)
    frame3.data[7]  = 8'h02;  frame3.valid[7]  = 1'b1;  frame3.error[7]  = 1'b0;
    frame3.data[8]  = 8'h03;  frame3.valid[8]  = 1'b1;  frame3.error[8]  = 1'b0;
    frame3.data[9]  = 8'h04;  frame3.valid[9]  = 1'b1;  frame3.error[9]  = 1'b0;
    frame3.data[10] = 8'h05;  frame3.valid[10] = 1'b1;  frame3.error[10] = 1'b0;
    frame3.data[11] = 8'h06;  frame3.valid[11] = 1'b1;  frame3.error[11] = 1'b0;
    frame3.data[12] = 8'h00;  frame3.valid[12] = 1'b1;  frame3.error[12] = 1'b0;
    frame3.data[13] = 8'h03;  frame3.valid[13] = 1'b1;  frame3.error[13] = 1'b0; // Length/Type = Length = 03
    frame3.data[14] = 8'h01;  frame3.valid[14] = 1'b1;  frame3.error[14] = 1'b0; // Therefore padding is required
    frame3.data[15] = 8'h02;  frame3.valid[15] = 1'b1;  frame3.error[15] = 1'b0;
    frame3.data[16] = 8'h03;  frame3.valid[16] = 1'b1;  frame3.error[16] = 1'b0;
    frame3.data[17] = 8'h00;  frame3.valid[17] = 1'b1;  frame3.error[17] = 1'b0; // Padding starts here
    frame3.data[18] = 8'h00;  frame3.valid[18] = 1'b1;  frame3.error[18] = 1'b0;
    frame3.data[19] = 8'h00;  frame3.valid[19] = 1'b1;  frame3.error[19] = 1'b0;
    frame3.data[20] = 8'h00;  frame3.valid[20] = 1'b1;  frame3.error[20] = 1'b0;
    frame3.data[21] = 8'h00;  frame3.valid[21] = 1'b1;  frame3.error[21] = 1'b0;
    frame3.data[22] = 8'h00;  frame3.valid[22] = 1'b1;  frame3.error[22] = 1'b0;
    frame3.data[23] = 8'h00;  frame3.valid[23] = 1'b1;  frame3.error[23] = 1'b0;
    frame3.data[24] = 8'h00;  frame3.valid[24] = 1'b1;  frame3.error[24] = 1'b0;
    frame3.data[25] = 8'h00;  frame3.valid[25] = 1'b1;  frame3.error[25] = 1'b0;
    frame3.data[26] = 8'h00;  frame3.valid[26] = 1'b1;  frame3.error[26] = 1'b0;
    frame3.data[27] = 8'h00;  frame3.valid[27] = 1'b1;  frame3.error[27] = 1'b0;
    frame3.data[28] = 8'h00;  frame3.valid[28] = 1'b1;  frame3.error[28] = 1'b0;
    frame3.data[29] = 8'h00;  frame3.valid[29] = 1'b1;  frame3.error[29] = 1'b0;
    frame3.data[30] = 8'h00;  frame3.valid[30] = 1'b1;  frame3.error[30] = 1'b0;
    frame3.data[31] = 8'h00;  frame3.valid[31] = 1'b1;  frame3.error[31] = 1'b0;
    frame3.data[32] = 8'h00;  frame3.valid[32] = 1'b1;  frame3.error[32] = 1'b0;
    frame3.data[33] = 8'h00;  frame3.valid[33] = 1'b1;  frame3.error[33] = 1'b0;
    frame3.data[34] = 8'h00;  frame3.valid[34] = 1'b1;  frame3.error[34] = 1'b0;
    frame3.data[35] = 8'h00;  frame3.valid[35] = 1'b1;  frame3.error[35] = 1'b0;
    frame3.data[36] = 8'h00;  frame3.valid[36] = 1'b1;  frame3.error[36] = 1'b0;
    frame3.data[37] = 8'h00;  frame3.valid[37] = 1'b1;  frame3.error[37] = 1'b0;
    frame3.data[38] = 8'h00;  frame3.valid[38] = 1'b1;  frame3.error[38] = 1'b0;
    frame3.data[39] = 8'h00;  frame3.valid[39] = 1'b1;  frame3.error[39] = 1'b0;
    frame3.data[40] = 8'h00;  frame3.valid[40] = 1'b1;  frame3.error[40] = 1'b0;
    frame3.data[41] = 8'h00;  frame3.valid[41] = 1'b1;  frame3.error[41] = 1'b0;
    frame3.data[42] = 8'h00;  frame3.valid[42] = 1'b1;  frame3.error[42] = 1'b0;
    frame3.data[43] = 8'h00;  frame3.valid[43] = 1'b1;  frame3.error[43] = 1'b0;
    frame3.data[44] = 8'h00;  frame3.valid[44] = 1'b1;  frame3.error[44] = 1'b0;
    frame3.data[45] = 8'h00;  frame3.valid[45] = 1'b1;  frame3.error[45] = 1'b0;
    frame3.data[46] = 8'h00;  frame3.valid[46] = 1'b1;  frame3.error[46] = 1'b0;
    frame3.data[47] = 8'h00;  frame3.valid[47] = 1'b1;  frame3.error[47] = 1'b0;
    frame3.data[48] = 8'h00;  frame3.valid[48] = 1'b1;  frame3.error[48] = 1'b0;
    frame3.data[49] = 8'h00;  frame3.valid[49] = 1'b1;  frame3.error[49] = 1'b0;
    frame3.data[50] = 8'h00;  frame3.valid[50] = 1'b1;  frame3.error[50] = 1'b0;
    frame3.data[51] = 8'h00;  frame3.valid[51] = 1'b1;  frame3.error[51] = 1'b0;
    frame3.data[52] = 8'h00;  frame3.valid[52] = 1'b1;  frame3.error[52] = 1'b0;
    frame3.data[53] = 8'h00;  frame3.valid[53] = 1'b1;  frame3.error[53] = 1'b0;
    frame3.data[54] = 8'h00;  frame3.valid[54] = 1'b1;  frame3.error[54] = 1'b0;
    frame3.data[55] = 8'h00;  frame3.valid[55] = 1'b1;  frame3.error[55] = 1'b0;
    frame3.data[56] = 8'h00;  frame3.valid[56] = 1'b1;  frame3.error[56] = 1'b0;
    frame3.data[57] = 8'h00;  frame3.valid[57] = 1'b1;  frame3.error[57] = 1'b0;
    frame3.data[58] = 8'h00;  frame3.valid[58] = 1'b1;  frame3.error[58] = 1'b0;
    frame3.data[59] = 8'h00;  frame3.valid[59] = 1'b1;  frame3.error[59] = 1'b0;
    // unused
    frame3.data[60] = 8'h00;  frame3.valid[60] = 1'b0;  frame3.error[60] = 1'b0;
    frame3.data[61] = 8'h00;  frame3.valid[61] = 1'b0;  frame3.error[61] = 1'b0;

    // No error in this frame
    frame3.bad_frame  = 1'b0;


  end


  //--------------------------------------------------------------------
  // CRC engine
  //--------------------------------------------------------------------
  task calc_crc;
    input  [7:0]  data;
    inout  [31:0] fcs;

    reg [31:0] crc;
    reg        crc_feedback;
    integer    I;
  begin

    crc = ~ fcs;

    for (I = 0; I < 8; I = I + 1)
    begin
      crc_feedback = crc[0] ^ data[I];

      crc[0]       = crc[1];
      crc[1]       = crc[2];
      crc[2]       = crc[3];
      crc[3]       = crc[4];
      crc[4]       = crc[5];
      crc[5]       = crc[6]  ^ crc_feedback;
      crc[6]       = crc[7];
      crc[7]       = crc[8];
      crc[8]       = crc[9]  ^ crc_feedback;
      crc[9]       = crc[10] ^ crc_feedback;
      crc[10]      = crc[11];
      crc[11]      = crc[12];
      crc[12]      = crc[13];
      crc[13]      = crc[14];
      crc[14]      = crc[15];
      crc[15]      = crc[16] ^ crc_feedback;
      crc[16]      = crc[17];
      crc[17]      = crc[18];
      crc[18]      = crc[19];
      crc[19]      = crc[20] ^ crc_feedback;
      crc[20]      = crc[21] ^ crc_feedback;
      crc[21]      = crc[22] ^ crc_feedback;
      crc[22]      = crc[23];
      crc[23]      = crc[24] ^ crc_feedback;
      crc[24]      = crc[25] ^ crc_feedback;
      crc[25]      = crc[26];
      crc[26]      = crc[27] ^ crc_feedback;
      crc[27]      = crc[28] ^ crc_feedback;
      crc[28]      = crc[29];
      crc[29]      = crc[30] ^ crc_feedback;
      crc[30]      = crc[31] ^ crc_feedback;
      crc[31]      =           crc_feedback;
    end

    // return the CRC result
    fcs = ~ crc;

    end
  endtask // calc_crc




  //----------------------------------------------------------------------------
  // Test Bench signals and constants
  //----------------------------------------------------------------------------

// ############### DRAM SIM PARAMS - From MIG Exampl Design // ############### 

   //***************************************************************************
   // Traffic Gen related parameters
   //***************************************************************************
   parameter SIMULATION            = "TRUE";
//   parameter BL_WIDTH              = 10;
//   parameter ADDR_MODE             = 4'b0011;
   parameter BEGIN_ADDRESS         = 32'h00000000;
   parameter END_ADDRESS           = 32'h00000fff;
   parameter PRBS_EADDR_MASK_POS   = 32'hff000000;

   //***************************************************************************
   // The following parameters refer to width of various ports
   //***************************************************************************
//   parameter BANK_WIDTH            = 3;
                                     // # of memory Bank Address bits.
//   parameter CK_WIDTH              = 1;
                                     // # of CK/CK# outputs to memory.
   parameter COL_WIDTH             = 10;
                                     // # of memory Column Address bits.
   parameter CS_WIDTH              = 1;
                                     // # of unique CS outputs to memory.
//   parameter nCS_PER_RANK          = 1;
                                     // # of unique CS outputs per rank for phy
//   parameter CKE_WIDTH             = 1;
                                     // # of CKE outputs to memory.
//   parameter DATA_BUF_ADDR_WIDTH   = 5;
//   parameter DQ_CNT_WIDTH          = 6;
                                     // = ceil(log2(DQ_WIDTH))
//   parameter DQ_PER_DM             = 8;
   parameter DM_WIDTH              = 8;
                                     // # of DM (data mask)
   parameter DQ_WIDTH              = 64;
                                     // # of DQ (data)
   parameter DQS_WIDTH             = 8;
   parameter DQS_CNT_WIDTH         = 3;
                                     // = ceil(log2(DQS_WIDTH))
   parameter DRAM_WIDTH            = 8;
                                     // # of DQ per DQS
   parameter ECC                   = "OFF";
//   parameter nBANK_MACHS           = 4;
   parameter RANKS                 = 1;
                                     // # of Ranks.
   parameter ODT_WIDTH             = 1;
                                     // # of ODT outputs to memory.
   parameter ROW_WIDTH             = 14;
                                     // # of memory Row Address bits.
   parameter ADDR_WIDTH            = 28;
                                     // # = RANK_WIDTH + BANK_WIDTH
                                     //     + ROW_WIDTH + COL_WIDTH;
                                     // Chip Select is always tied to low for
                                     // single rank devices
//   parameter USE_CS_PORT          = 1;
                                     // # = 1, When CS output is enabled
                                     //   = 0, When CS output is disabled
                                     // If CS_N disabled, user must connect
                                     // DRAM CS_N input(s) to ground
//   parameter USE_DM_PORT           = 1;
                                     // # = 1, When Data Mask option is enabled
                                     //   = 0, When Data Mask option is disbaled
                                     // When Data Mask option is disabled in
                                     // MIG Controller Options page, the logic
                                     // related to Data Mask should not get
                                     // synthesized
//   parameter USE_ODT_PORT          = 1;
                                     // # = 1, When ODT output is enabled
                                     //   = 0, When ODT output is disabled
                                     // Parameter configuration for Dynamic ODT support:
                                     // USE_ODT_PORT = 0, RTT_NOM = "DISABLED", RTT_WR = "60/120".
                                     // This configuration allows to save ODT pin mapping from FPGA.
                                     // The user can tie the ODT input of DRAM to HIGH.

   //***************************************************************************
   // The following parameters are mode register settings
   //***************************************************************************
//   parameter AL                    = "0";
                                     // DDR3 SDRAM:
                                     // Additive Latency (Mode Register 1).
                                     // # = "0", "CL-1", "CL-2".
                                     // DDR2 SDRAM:
                                     // Additive Latency (Extended Mode Register).
//   parameter nAL                   = 0;
                                     // # Additive Latency in number of clock
                                     // cycles.
   parameter BURST_MODE            = "8";
                                     // DDR3 SDRAM:
                                     // Burst Length (Mode Register 0).
                                     // # = "8", "4", "OTF".
                                     // DDR2 SDRAM:
                                     // Burst Length (Mode Register).
                                     // # = "8", "4".
//   parameter BURST_TYPE            = "SEQ";
                                     // DDR3 SDRAM: Burst Type (Mode Register 0).
                                     // DDR2 SDRAM: Burst Type (Mode Register).
                                     // # = "SEQ" - (Sequential),
                                     //   = "INT" - (Interleaved).
//   parameter CL                    = 6;
                                     // in number of clock cycles
                                     // DDR3 SDRAM: CAS Latency (Mode Register 0).
                                     // DDR2 SDRAM: CAS Latency (Mode Register).
//   parameter CWL                   = 5;
                                     // in number of clock cycles
                                     // DDR3 SDRAM: CAS Write Latency (Mode Register 2).
                                     // DDR2 SDRAM: Can be ignored
//   parameter OUTPUT_DRV            = "HIGH";
                                     // Output Driver Impedance Control (Mode Register 1).
                                     // # = "HIGH" - RZQ/7,
                                     //   = "LOW" - RZQ/6.
//   parameter RTT_NOM               = "60";
                                     // RTT_NOM (ODT) (Mode Register 1).
                                     // # = "DISABLED" - RTT_NOM disabled,
                                     //   = "120" - RZQ/2,
                                     //   = "60"  - RZQ/4,
                                     //   = "40"  - RZQ/6.
//   parameter RTT_WR                = "OFF";
                                     // RTT_WR (ODT) (Mode Register 2).
                                     // # = "OFF" - Dynamic ODT off,
                                     //   = "120" - RZQ/2,
                                     //   = "60"  - RZQ/4,
//   parameter ADDR_CMD_MODE         = "1T" ;
                                     // # = "1T", "2T".
//   parameter REG_CTRL              = "OFF";
                                     // # = "ON" - RDIMMs,
                                     //   = "OFF" - Components, SODIMMs, UDIMMs.
   parameter CA_MIRROR             = "OFF";
                                     // C/A mirror opt for DDR3 dual rank
   
   //***************************************************************************
   // The following parameters are multiplier and divisor factors for PLLE2.
   // Based on the selected design frequency these parameters vary.
   //***************************************************************************
   parameter CLKIN_PERIOD          = 5000;
                                     // Input Clock Period
//   parameter CLKFBOUT_MULT         = 4;
                                     // write PLL VCO multiplier
//   parameter DIVCLK_DIVIDE         = 1;
                                     // write PLL VCO divisor
//   parameter CLKOUT0_DIVIDE        = 2;
                                     // VCO output divisor for PLL output clock (CLKOUT0)
//   parameter CLKOUT1_DIVIDE        = 2;
                                     // VCO output divisor for PLL output clock (CLKOUT1)
//   parameter CLKOUT2_DIVIDE        = 32;
                                     // VCO output divisor for PLL output clock (CLKOUT2)
//   parameter CLKOUT3_DIVIDE        = 8;
                                     // VCO output divisor for PLL output clock (CLKOUT3)

   //***************************************************************************
   // Memory Timing Parameters. These parameters varies based on the selected
   // memory part.
   //***************************************************************************
//   parameter tCKE                  = 5000;
                                     // memory tCKE paramter in pS
//   parameter tFAW                  = 30000;
                                     // memory tRAW paramter in pS.
//   parameter tRAS                  = 35000;
                                     // memory tRAS paramter in pS.
//   parameter tRCD                  = 13125;
                                     // memory tRCD paramter in pS.
//   parameter tREFI                 = 7800000;
                                     // memory tREFI paramter in pS.
//   parameter tRFC                  = 110000;
                                     // memory tRFC paramter in pS.
//   parameter tRP                   = 13125;
                                     // memory tRP paramter in pS.
//   parameter tRRD                  = 6000;
                                     // memory tRRD paramter in pS.
//   parameter tRTP                  = 7500;
                                     // memory tRTP paramter in pS.
//   parameter tWTR                  = 7500;
                                     // memory tWTR paramter in pS.
//   parameter tZQI                  = 128_000_000;
                                     // memory tZQI paramter in nS.
//   parameter tZQCS                 = 64;
                                     // memory tZQCS paramter in clock cycles.

   //***************************************************************************
   // Simulation parameters
   //***************************************************************************
   parameter SIM_BYPASS_INIT_CAL   = "FAST";
                                     // # = "SIM_INIT_CAL_FULL" -  Complete
                                     //              memory init &
                                     //              calibration sequence
                                     // # = "SKIP" - Not supported
                                     // # = "FAST" - Complete memory init & use
                                     //              abbreviated calib sequence

   //***************************************************************************
   // The following parameters varies based on the pin out entered in MIG GUI.
   // Do not change any of these parameters directly by editing the RTL.
   // Any changes required should be done through GUI and the design regenerated.
   //***************************************************************************
//   parameter BYTE_LANES_B0         = 4'b1111;
                                     // Byte lanes used in an IO column.
//   parameter BYTE_LANES_B1         = 4'b0111;
                                     // Byte lanes used in an IO column.
//   parameter BYTE_LANES_B2         = 4'b1111;
                                     // Byte lanes used in an IO column.
//   parameter BYTE_LANES_B3         = 4'b0000;
                                     // Byte lanes used in an IO column.
//   parameter BYTE_LANES_B4         = 4'b0000;
                                     // Byte lanes used in an IO column.
//   parameter DATA_CTL_B0           = 4'b1111;
                                     // Indicates Byte lane is data byte lane
                                     // or control Byte lane. '1' in a bit
                                     // position indicates a data byte lane and
                                     // a '0' indicates a control byte lane
//   parameter DATA_CTL_B1           = 4'b0000;
                                     // Indicates Byte lane is data byte lane
                                     // or control Byte lane. '1' in a bit
                                     // position indicates a data byte lane and
                                     // a '0' indicates a control byte lane
//   parameter DATA_CTL_B2           = 4'b1111;
                                     // Indicates Byte lane is data byte lane
                                     // or control Byte lane. '1' in a bit
                                     // position indicates a data byte lane and
                                     // a '0' indicates a control byte lane
//   parameter DATA_CTL_B3           = 4'b0000;
                                     // Indicates Byte lane is data byte lane
                                     // or control Byte lane. '1' in a bit
                                     // position indicates a data byte lane and
                                     // a '0' indicates a control byte lane
//   parameter DATA_CTL_B4           = 4'b0000;
                                     // Indicates Byte lane is data byte lane
                                     // or control Byte lane. '1' in a bit
                                     // position indicates a data byte lane and
                                     // a '0' indicates a control byte lane
//   parameter PHY_0_BITLANES        = 48'h3FE_3FE_3FE_2FF;
//   parameter PHY_1_BITLANES        = 48'h000_CB0_473_FFF;
//   parameter PHY_2_BITLANES        = 48'h3FE_3FE_3FE_2FF;

   // control/address/data pin mapping parameters
//   parameter CK_BYTE_MAP
//     = 144'h00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_00_11;
//   parameter ADDR_MAP
//     = 192'h000_000_111_110_109_108_107_106_10B_10A_105_104_103_102_101_100;
//   parameter BANK_MAP   = 36'h11A_115_114;
//   parameter CAS_MAP    = 12'h12A;
//   parameter CKE_ODT_BYTE_MAP = 8'h00;
//   parameter CKE_MAP    = 96'h000_000_000_000_000_000_000_116;
//   parameter ODT_MAP    = 96'h000_000_000_000_000_000_000_127;
//   parameter CS_MAP     = 120'h000_000_000_000_000_000_000_000_000_12B;
//   parameter PARITY_MAP = 12'h000;
//   parameter RAS_MAP    = 12'h125;
//   parameter WE_MAP     = 12'h124;
//   parameter DQS_BYTE_MAP
//     = 144'h00_00_00_00_00_00_00_00_00_00_03_02_01_00_23_22_21_20;
//   parameter DATA0_MAP  = 96'h200_209_206_203_204_205_202_207;
//   parameter DATA1_MAP  = 96'h219_218_214_215_217_212_216_213;
//   parameter DATA2_MAP  = 96'h225_224_229_226_223_222_228_227;
//   parameter DATA3_MAP  = 96'h238_236_234_233_235_237_232_239;
//   parameter DATA4_MAP  = 96'h005_003_000_009_007_006_004_002;
//   parameter DATA5_MAP  = 96'h013_012_018_019_015_014_017_016;
//   parameter DATA6_MAP  = 96'h023_027_022_029_024_025_028_026;
//   parameter DATA7_MAP  = 96'h039_037_033_032_035_034_038_036;
//   parameter DATA8_MAP  = 96'h000_000_000_000_000_000_000_000;
//   parameter DATA9_MAP  = 96'h000_000_000_000_000_000_000_000;
//   parameter DATA10_MAP = 96'h000_000_000_000_000_000_000_000;
//   parameter DATA11_MAP = 96'h000_000_000_000_000_000_000_000;
//   parameter DATA12_MAP = 96'h000_000_000_000_000_000_000_000;
//   parameter DATA13_MAP = 96'h000_000_000_000_000_000_000_000;
//   parameter DATA14_MAP = 96'h000_000_000_000_000_000_000_000;
//   parameter DATA15_MAP = 96'h000_000_000_000_000_000_000_000;
//   parameter DATA16_MAP = 96'h000_000_000_000_000_000_000_000;
//   parameter DATA17_MAP = 96'h000_000_000_000_000_000_000_000;
//   parameter MASK0_MAP  = 108'h000_031_021_011_001_231_221_211_201;
//   parameter MASK1_MAP  = 108'h000_000_000_000_000_000_000_000_000;

//   parameter SLOT_0_CONFIG         = 8'b0000_0001;
                                     // Mapping of Ranks.
//   parameter SLOT_1_CONFIG         = 8'b0000_0000;
                                     // Mapping of Ranks.
//   parameter MEM_ADDR_ORDER        = "BANK_ROW_COLUMN";
                                      //Possible Parameters
                                      //1.BANK_ROW_COLUMN : Address mapping is
                                      //                    in form of Bank Row Column.
                                      //2.ROW_BANK_COLUMN : Address mapping is
                                      //                    in the form of Row Bank Column.
                                      //3.TG_TEST : Scrambles Address bits
                                      //            for distributed Addressing.
   //***************************************************************************
   // IODELAY and PHY related parameters
   //***************************************************************************
//   parameter IBUF_LPWR_MODE        = "OFF";
                                     // to phy_top
//   parameter DATA_IO_IDLE_PWRDWN   = "ON";
                                     // # = "ON", "OFF"
//   parameter DATA_IO_PRIM_TYPE     = "HP_LP";
                                     // # = "HP_LP", "HR_LP", "DEFAULT"
//   parameter USER_REFRESH          = "OFF";
//   parameter WRLVL                 = "ON";
                                     // # = "ON" - DDR3 SDRAM
                                     //   = "OFF" - DDR2 SDRAM.
//   parameter ORDERING              = "NORM";
                                     // # = "NORM", "STRICT", "RELAXED".
//   parameter CALIB_ROW_ADD         = 16'h0000;
                                     // Calibration row address will be used for
                                     // calibration read and write operations
//   parameter CALIB_COL_ADD         = 12'h000;
                                     // Calibration column address will be used for
                                     // calibration read and write operations
//   parameter CALIB_BA_ADD          = 3'h0;
                                     // Calibration bank address will be used for
                                     // calibration read and write operations
   parameter TCQ                   = 100;
   //***************************************************************************
   // IODELAY and PHY related parameters
   //***************************************************************************
//   parameter IODELAY_GRP           = "MIG_7SERIES_0_IODELAY_MIG";
                                     // It is associated to a set of IODELAYs with
                                     // an IDELAYCTRL that have same IODELAY CONTROLLER
                                     // clock frequency.
//   parameter SYSCLK_TYPE           = "DIFFERENTIAL";
                                     // System clock type DIFFERENTIAL, SINGLE_ENDED,
                                     // NO_BUFFER
//   parameter REFCLK_TYPE           = "USE_SYSTEM_CLOCK";
                                     // Reference clock type DIFFERENTIAL, SINGLE_ENDED,
                                     // NO_BUFFER, USE_SYSTEM_CLOCK
   parameter RST_ACT_LOW           = 0;
                                     // =1 for active low reset,
                                     // =0 for active high.
//   parameter CAL_WIDTH             = "HALF";
//   parameter STARVE_LIMIT          = 2;
                                     // # = 2,3,4.

   //***************************************************************************
   // Referece clock frequency parameters
   //***************************************************************************
   parameter REFCLK_FREQ           = 200.0;
                                     // IODELAYCTRL reference clock frequency
   //***************************************************************************
   // System clock frequency parameters
   //***************************************************************************
   parameter tCK                   = 2500;
                                     // memory tCK paramter.
                     // # = Clock Period in pS.
   parameter nCK_PER_CLK           = 4;
                                     // # of memory CKs per fabric CLK

   
   //***************************************************************************
   // AXI4 Shim parameters
   //***************************************************************************
   parameter C_S_AXI_ID_WIDTH              = 4;
                                             // Width of all master and slave ID signals.
                                             // # = >= 1.
   parameter C_S_AXI_ADDR_WIDTH            = 30;
                                             // Width of S_AXI_AWADDR, S_AXI_ARADDR, M_AXI_AWADDR and
                                             // M_AXI_ARADDR for all SI/MI slots.
                                             // # = 32.
   parameter C_S_AXI_DATA_WIDTH            = 512;
                                             // Width of WDATA and RDATA on SI slot.
                                             // Must be <= APP_DATA_WIDTH.
                                             // # = 32, 64, 128, 256.
//   parameter C_MC_nCK_PER_CLK              = 4;
                                             // Indicates whether to instatiate upsizer
                                             // Range: 0, 1
   parameter C_S_AXI_SUPPORTS_NARROW_BURST = 0;
                                             // Indicates whether to instatiate upsizer
                                             // Range: 0, 1
//   parameter C_RD_WR_ARB_ALGORITHM          = "RD_PRI_REG";
                                             // Indicates the Arbitration
                                             // Allowed values - "TDM", "ROUND_ROBIN",
                                             // "RD_PRI_REG", "RD_PRI_REG_STARVE_LIMIT"
//   parameter C_S_AXI_REG_EN0               = 20'h00000;
                                             // C_S_AXI_REG_EN0[00] = Reserved
                                             // C_S_AXI_REG_EN0[04] = AW CHANNEL REGISTER SLICE
                                             // C_S_AXI_REG_EN0[05] =  W CHANNEL REGISTER SLICE
                                             // C_S_AXI_REG_EN0[06] =  B CHANNEL REGISTER SLICE
                                             // C_S_AXI_REG_EN0[07] =  R CHANNEL REGISTER SLICE
                                             // C_S_AXI_REG_EN0[08] = AW CHANNEL UPSIZER REGISTER SLICE
                                             // C_S_AXI_REG_EN0[09] =  W CHANNEL UPSIZER REGISTER SLICE
                                             // C_S_AXI_REG_EN0[10] = AR CHANNEL UPSIZER REGISTER SLICE
                                             // C_S_AXI_REG_EN0[11] =  R CHANNEL UPSIZER REGISTER SLICE
//   parameter C_S_AXI_REG_EN1                 = 20'h00000;
                                             // Instatiates register slices after the upsizer.
                                             // The type of register is specified for each channel
                                             // in a vector. 4 bits per channel are used.
                                             // C_S_AXI_REG_EN1[03:00] = AW CHANNEL REGISTER SLICE
                                             // C_S_AXI_REG_EN1[07:04] =  W CHANNEL REGISTER SLICE
                                             // C_S_AXI_REG_EN1[11:08] =  B CHANNEL REGISTER SLICE
                                             // C_S_AXI_REG_EN1[15:12] = AR CHANNEL REGISTER SLICE
                                             // C_S_AXI_REG_EN1[20:16] =  R CHANNEL REGISTER SLICE
                                             // Possible values for each channel are:
                                             //
                                             //   0 => BYPASS    = The channel is just wired through the
                                             //                    module.
                                             //   1 => FWD       = The master VALID and payload signals
                                             //                    are registrated.
                                             //   2 => REV       = The slave ready signal is registrated
                                             //   3 => FWD_REV   = Both FWD and REV
                                             //   4 => SLAVE_FWD = All slave side signals and master
                                             //                    VALID and payload are registrated.
                                             //   5 => SLAVE_RDY = All slave side signals and master
                                             //                    READY are registrated.
                                             //   6 => INPUTS    = Slave and Master side inputs are
                                             //                    registrated.
                                             //   7 => ADDRESS   = Optimized for address channel

   //***************************************************************************
   // Debug and Internal parameters
   //***************************************************************************
   parameter DEBUG_PORT            = "OFF";
                                     // # = "ON" Enable debug signals/controls.
                                     //   = "OFF" Disable debug signals/controls.
   //***************************************************************************
   // Debug and Internal parameters
   //***************************************************************************
   parameter DRAM_TYPE             = "DDR3";

    

  //**************************************************************************//
  // Local parameters Declarations
  //**************************************************************************//

  localparam real TPROP_DQS          = 0.00;
                                       // Delay for DQS signal during Write Operation
  localparam real TPROP_DQS_RD       = 0.00;
                       // Delay for DQS signal during Read Operation
  localparam real TPROP_PCB_CTRL     = 0.00;
                       // Delay for Address and Ctrl signals
  localparam real TPROP_PCB_DATA     = 0.00;
                       // Delay for data signal during Write operation
  localparam real TPROP_PCB_DATA_RD  = 0.00;
                       // Delay for data signal during Read operation

  localparam MEMORY_WIDTH            = 8;
  localparam NUM_COMP                = DQ_WIDTH/MEMORY_WIDTH;
  localparam ECC_TEST 		   	= "OFF" ;
  localparam ERR_INSERT = (ECC_TEST == "ON") ? "OFF" : ECC ;
  

  localparam real REFCLK_PERIOD = (1000000.0/(2*REFCLK_FREQ));
  localparam RESET_PERIOD = 200000; //in pSec  
  localparam real SYSCLK_PERIOD = tCK;
  
  // ############### END DRAM SIM PARAMS - From MIG Exampl Design // ############### 


  // Delay to provide setup and hold timing at the GMII/RGMII.
  parameter dly = 2000;  // 2000 ps
  parameter gtx_period = 2500;  // ps


  // testbench signals
  
  wire        gtx_clk;
  reg         mmcm_clk_in;
  reg         reset;
  reg         demo_mode_error = 1'b0;

  wire        mdc;
  wire        mdio;
  reg  [5:0]  mdio_count;
  reg         last_mdio;
  reg         mdio_read;
  reg         mdio_addr;
  reg         mdio_fail;
  wire        rgmii_txc;
  wire        rgmii_tx_ctl;
  wire [3:0]  rgmii_txd;
  reg         rgmii_rxc_1000;
  reg         rgmii_rxc_100;
  reg         rgmii_rxc_10;
  wire        rgmii_rxc;
  reg         rgmii_rx_ctl;
  reg  [3:0]  rgmii_rxd;
  wire        inband_link_status;
  wire [1:0]  inband_clock_speed;
  wire        inband_duplex_status;

  // testbench control semaphores
  reg  tx_monitor_finished_1G;
  reg  tx_monitor_finished_10M;
  reg  tx_monitor_finished_100M;
  reg  management_config_finished;

  reg [1:0] phy_speed;
  reg [1:0] mac_speed;
  reg       update_speed;

  wire         rgmii_rx_ctl_dut;
  wire [3:0]   rgmii_rxd_dut;

  reg          gen_tx_data;
  reg          check_tx_data;
  reg          config_bist;
  wire         frame_error;
  reg          bist_mode_error;
  wire         serial_response;


  // Generate a delayed rgmii_rxc to match the spec
  wire         delay_rxc;
  wire         delay_rxc_lcl;
  assign #2000 delay_rxc_lcl = rgmii_rxc;
  // only want the delay if the rgmii isn't looped back
  assign       delay_rxc = (TB_MODE == "BIST") ? rgmii_txc : delay_rxc_lcl;

  // select between loopback or local data
  assign rgmii_rxd_dut    = (TB_MODE == "BIST") ? rgmii_txd   : rgmii_rxd;
  assign rgmii_rx_ctl_dut = (TB_MODE == "BIST") ? rgmii_tx_ctl : rgmii_rx_ctl;
  
    // ############### DRAM SIM PARAMS - From MIG Exampl Design // ############### 
  
  //**************************************************************************//
  // Wire Declarations
  //**************************************************************************//
  reg                                sys_rst_n;
  wire                               sys_rst;


  reg                     sys_clk_i;
  wire                               sys_clk_p;
  wire                               sys_clk_n;
    

  reg clk_ref_i;

  
  wire                               ddr3_reset_n;
  wire [DQ_WIDTH-1:0]                ddr3_dq_fpga;
  wire [DQS_WIDTH-1:0]               ddr3_dqs_p_fpga;
  wire [DQS_WIDTH-1:0]               ddr3_dqs_n_fpga;
  wire [ROW_WIDTH-1:0]               ddr3_addr_fpga;
  wire [3-1:0]              ddr3_ba_fpga;
  wire                               ddr3_ras_n_fpga;
  wire                               ddr3_cas_n_fpga;
  wire                               ddr3_we_n_fpga;
  wire [1-1:0]               ddr3_cke_fpga;
  wire [1-1:0]                ddr3_ck_p_fpga;
  wire [1-1:0]                ddr3_ck_n_fpga;
    
  
  wire                               init_calib_complete;
  wire                               tg_compare_error;
  wire [(CS_WIDTH*1)-1:0] ddr3_cs_n_fpga;
    
  wire [DM_WIDTH-1:0]                ddr3_dm_fpga;
    
  wire [ODT_WIDTH-1:0]               ddr3_odt_fpga;
    
  
  reg [(CS_WIDTH*1)-1:0] ddr3_cs_n_sdram_tmp;
    
  reg [DM_WIDTH-1:0]                 ddr3_dm_sdram_tmp;
    
  reg [ODT_WIDTH-1:0]                ddr3_odt_sdram_tmp;
    

  
  wire [DQ_WIDTH-1:0]                ddr3_dq_sdram;
  reg [ROW_WIDTH-1:0]                ddr3_addr_sdram [0:1];
  reg [3-1:0]               ddr3_ba_sdram [0:1];
  reg                                ddr3_ras_n_sdram;
  reg                                ddr3_cas_n_sdram;
  reg                                ddr3_we_n_sdram;
  wire [(CS_WIDTH*1)-1:0] ddr3_cs_n_sdram;
  wire [ODT_WIDTH-1:0]               ddr3_odt_sdram;
  reg [1-1:0]                ddr3_cke_sdram;
  wire [DM_WIDTH-1:0]                ddr3_dm_sdram;
  wire [DQS_WIDTH-1:0]               ddr3_dqs_p_sdram;
  wire [DQS_WIDTH-1:0]               ddr3_dqs_n_sdram;
  reg [1-1:0]                 ddr3_ck_p_sdram;
  reg [1-1:0]                 ddr3_ck_n_sdram;

//**************************************************************************//
  // ############### END DRAM SIM PARAMS - From MIG Example Design // ############### 
  
   //**************************************************************************//
 
   // ############### DRAM SIM TASKS - From MIG Example Design // ###############  
     //**************************************************************************//
     // Reset Generation
     //**************************************************************************//
     initial begin
       sys_rst_n = 1'b0;
       #RESET_PERIOD
         sys_rst_n = 1'b1;
      end
   
      assign sys_rst = RST_ACT_LOW ? sys_rst_n : ~sys_rst_n;
   
     //**************************************************************************//
     // Clock Generation
     //**************************************************************************//
   
     initial
       sys_clk_i = 1'b0;
     always
       sys_clk_i = #(CLKIN_PERIOD/2.0) ~sys_clk_i;
   
     assign sys_clk_p = sys_clk_i;
     assign sys_clk_n = ~sys_clk_i;
   
     initial
       clk_ref_i = 1'b0;
     always
       clk_ref_i = #REFCLK_PERIOD ~clk_ref_i;
   
   
   
   
     always @( * ) begin
       ddr3_ck_p_sdram      <=  #(TPROP_PCB_CTRL) ddr3_ck_p_fpga;
       ddr3_ck_n_sdram      <=  #(TPROP_PCB_CTRL) ddr3_ck_n_fpga;
       ddr3_addr_sdram[0]   <=  #(TPROP_PCB_CTRL) ddr3_addr_fpga;
       ddr3_addr_sdram[1]   <=  #(TPROP_PCB_CTRL) (CA_MIRROR == "ON") ?
                                                    {ddr3_addr_fpga[ROW_WIDTH-1:9],
                                                     ddr3_addr_fpga[7], ddr3_addr_fpga[8],
                                                     ddr3_addr_fpga[5], ddr3_addr_fpga[6],
                                                     ddr3_addr_fpga[3], ddr3_addr_fpga[4],
                                                     ddr3_addr_fpga[2:0]} :
                                                    ddr3_addr_fpga;
       ddr3_ba_sdram[0]     <=  #(TPROP_PCB_CTRL) ddr3_ba_fpga;
       ddr3_ba_sdram[1]     <=  #(TPROP_PCB_CTRL) (CA_MIRROR == "ON") ?
                                                    {ddr3_ba_fpga[3-1:2],
                                                     ddr3_ba_fpga[0],
                                                     ddr3_ba_fpga[1]} :
                                                    ddr3_ba_fpga;
       ddr3_ras_n_sdram     <=  #(TPROP_PCB_CTRL) ddr3_ras_n_fpga;
       ddr3_cas_n_sdram     <=  #(TPROP_PCB_CTRL) ddr3_cas_n_fpga;
       ddr3_we_n_sdram      <=  #(TPROP_PCB_CTRL) ddr3_we_n_fpga;
       ddr3_cke_sdram       <=  #(TPROP_PCB_CTRL) ddr3_cke_fpga;
     end
       
   
     always @( * )
       ddr3_cs_n_sdram_tmp   <=  #(TPROP_PCB_CTRL) ddr3_cs_n_fpga;
     assign ddr3_cs_n_sdram =  ddr3_cs_n_sdram_tmp;
       
   
     always @( * )
       ddr3_dm_sdram_tmp <=  #(TPROP_PCB_DATA) ddr3_dm_fpga;//DM signal generation
     assign ddr3_dm_sdram = ddr3_dm_sdram_tmp;
       
   
     always @( * )
       ddr3_odt_sdram_tmp  <=  #(TPROP_PCB_CTRL) ddr3_odt_fpga;
     assign ddr3_odt_sdram =  ddr3_odt_sdram_tmp;
       
   
   // Controlling the bi-directional BUS
   
     genvar dqwd;
     generate
       for (dqwd = 1;dqwd < DQ_WIDTH;dqwd = dqwd+1) begin : dq_delay
         WireDelay #
          (
           .Delay_g    (TPROP_PCB_DATA),
           .Delay_rd   (TPROP_PCB_DATA_RD),
           .ERR_INSERT ("OFF")
          )
         u_delay_dq
          (
           .A             (ddr3_dq_fpga[dqwd]),
           .B             (ddr3_dq_sdram[dqwd]),
           //.reset         (sys_rst_n),
           .reset         (reset),
           .phy_init_done (init_calib_complete)
          );
       end
       // For ECC ON case error is inserted on LSB bit from DRAM to FPGA
             WireDelay #
          (
           .Delay_g    (TPROP_PCB_DATA),
           .Delay_rd   (TPROP_PCB_DATA_RD),
           .ERR_INSERT (ERR_INSERT)
          )
         u_delay_dq_0
          (
           .A             (ddr3_dq_fpga[0]),
           .B             (ddr3_dq_sdram[0]),
           //.reset         (sys_rst_n),
           .reset         (reset),
           .phy_init_done (init_calib_complete)
          );
     endgenerate
   
     genvar dqswd;
     generate
       for (dqswd = 0;dqswd < DQS_WIDTH;dqswd = dqswd+1) begin : dqs_delay
         WireDelay #
          (
           .Delay_g    (TPROP_DQS),
           .Delay_rd   (TPROP_DQS_RD),
           .ERR_INSERT ("OFF")
          )
         u_delay_dqs_p
          (
           .A             (ddr3_dqs_p_fpga[dqswd]),
           .B             (ddr3_dqs_p_sdram[dqswd]),
           //.reset         (sys_rst_n),
           .reset         (reset),
           .phy_init_done (init_calib_complete)
          );
   
         WireDelay #
          (
           .Delay_g    (TPROP_DQS),
           .Delay_rd   (TPROP_DQS_RD),
           .ERR_INSERT ("OFF")
          )
         u_delay_dqs_n
          (
           .A             (ddr3_dqs_n_fpga[dqswd]),
           .B             (ddr3_dqs_n_sdram[dqswd]),
           //.reset         (sys_rst_n),
           .reset         (reset),
           .phy_init_done (init_calib_complete)
          );
       end
     endgenerate
       
    // ############### DRAM SIM TASKS - From MIG Example Design // ###############  

  //----------------------------------------------------------------------------
  // Wire up Device Under Test
  //----------------------------------------------------------------------------

  kc705_ethernet_rgmii_example_design #
    (
    
         .SIMULATION                (SIMULATION),
    //     .BL_WIDTH                  (BL_WIDTH),
    //     .ADDR_MODE                 (ADDR_MODE),
         .BEGIN_ADDRESS             (BEGIN_ADDRESS),
         .END_ADDRESS               (END_ADDRESS),
         .PRBS_EADDR_MASK_POS       (PRBS_EADDR_MASK_POS),
    
    //     .BANK_WIDTH                (BANK_WIDTH),
    //     .CK_WIDTH                  (CK_WIDTH),
         .COL_WIDTH                 (COL_WIDTH),
         .CS_WIDTH                  (CS_WIDTH),
    //     .nCS_PER_RANK              (nCS_PER_RANK),
    //     .CKE_WIDTH                 (CKE_WIDTH),
    //     .DATA_BUF_ADDR_WIDTH       (DATA_BUF_ADDR_WIDTH),
    //     .DQ_CNT_WIDTH              (DQ_CNT_WIDTH),
    //     .DQ_PER_DM                 (DQ_PER_DM),
         .DM_WIDTH                  (DM_WIDTH),
        
         .DQ_WIDTH                  (DQ_WIDTH),
    //     .DQS_WIDTH                 (DQS_WIDTH),
         .DQS_CNT_WIDTH             (DQS_CNT_WIDTH),
         .DRAM_WIDTH                (DRAM_WIDTH),
    //     .ECC                       (ECC),
         .ECC_TEST                  (ECC_TEST),
    //     .nBANK_MACHS               (nBANK_MACHS),
         .RANKS                     (RANKS),
    //     .ODT_WIDTH                 (ODT_WIDTH),
         .ROW_WIDTH                 (ROW_WIDTH),
         .ADDR_WIDTH                (ADDR_WIDTH),
    //     .USE_CS_PORT               (USE_CS_PORT),
    //     .USE_DM_PORT               (USE_DM_PORT),
    //     .USE_ODT_PORT              (USE_ODT_PORT),
    
    //     .AL                        (AL),
    //     .nAL                       (nAL),
         .BURST_MODE                (BURST_MODE),
    //     .BURST_TYPE                (BURST_TYPE),
    //     .CL                        (CL),
    //     .CWL                       (CWL),
    //     .OUTPUT_DRV                (OUTPUT_DRV),
    //     .RTT_NOM                   (RTT_NOM),
    //     .RTT_WR                    (RTT_WR),
    //     .ADDR_CMD_MODE             (ADDR_CMD_MODE),
    //     .REG_CTRL                  (REG_CTRL),
    //     .CA_MIRROR                 (CA_MIRROR),
    
    
    //     .CLKIN_PERIOD              (CLKIN_PERIOD),
    //     .CLKFBOUT_MULT             (CLKFBOUT_MULT),
    //     .DIVCLK_DIVIDE             (DIVCLK_DIVIDE),
    //     .CLKOUT0_DIVIDE            (CLKOUT0_DIVIDE),
    //     .CLKOUT1_DIVIDE            (CLKOUT1_DIVIDE),
    //     .CLKOUT2_DIVIDE            (CLKOUT2_DIVIDE),
    //     .CLKOUT3_DIVIDE            (CLKOUT3_DIVIDE),
        
    
    //     .tCKE                      (tCKE),
    //     .tFAW                      (tFAW),
    //     .tRAS                      (tRAS),
    //     .tRCD                      (tRCD),
    //     .tREFI                     (tREFI),
    //     .tRFC                      (tRFC),
    //     .tRP                       (tRP),
    //     .tRRD                      (tRRD),
    //     .tRTP                      (tRTP),
    //     .tWTR                      (tWTR),
    //     .tZQI                      (tZQI),
    //     .tZQCS                     (tZQCS),
    
    //     .SIM_BYPASS_INIT_CAL       (SIM_BYPASS_INIT_CAL),
    
    //     .BYTE_LANES_B0             (BYTE_LANES_B0),
    //     .BYTE_LANES_B1             (BYTE_LANES_B1),
    //     .BYTE_LANES_B2             (BYTE_LANES_B2),
    //     .BYTE_LANES_B3             (BYTE_LANES_B3),
    //     .BYTE_LANES_B4             (BYTE_LANES_B4),
    //     .DATA_CTL_B0               (DATA_CTL_B0),
    //     .DATA_CTL_B1               (DATA_CTL_B1),
    //     .DATA_CTL_B2               (DATA_CTL_B2),
    //     .DATA_CTL_B3               (DATA_CTL_B3),
    //     .DATA_CTL_B4               (DATA_CTL_B4),
    //     .PHY_0_BITLANES            (PHY_0_BITLANES),
    //     .PHY_1_BITLANES            (PHY_1_BITLANES),
    //     .PHY_2_BITLANES            (PHY_2_BITLANES),
    //     .CK_BYTE_MAP               (CK_BYTE_MAP),
    //     .ADDR_MAP                  (ADDR_MAP),
    //     .BANK_MAP                  (BANK_MAP),
    //     .CAS_MAP                   (CAS_MAP),
    //     .CKE_ODT_BYTE_MAP          (CKE_ODT_BYTE_MAP),
    //     .CKE_MAP                   (CKE_MAP),
    //     .ODT_MAP                   (ODT_MAP),
    //     .CS_MAP                    (CS_MAP),
    //     .PARITY_MAP                (PARITY_MAP),
    //     .RAS_MAP                   (RAS_MAP),
    //     .WE_MAP                    (WE_MAP),
    //     .DQS_BYTE_MAP              (DQS_BYTE_MAP),
    //     .DATA0_MAP                 (DATA0_MAP),
    //     .DATA1_MAP                 (DATA1_MAP),
    //     .DATA2_MAP                 (DATA2_MAP),
    //     .DATA3_MAP                 (DATA3_MAP),
    //     .DATA4_MAP                 (DATA4_MAP),
    //     .DATA5_MAP                 (DATA5_MAP),
    //     .DATA6_MAP                 (DATA6_MAP),
    //     .DATA7_MAP                 (DATA7_MAP),
    //     .DATA8_MAP                 (DATA8_MAP),
    //     .DATA9_MAP                 (DATA9_MAP),
    //     .DATA10_MAP                (DATA10_MAP),
    //     .DATA11_MAP                (DATA11_MAP),
    //     .DATA12_MAP                (DATA12_MAP),
    //     .DATA13_MAP                (DATA13_MAP),
    //     .DATA14_MAP                (DATA14_MAP),
    //     .DATA15_MAP                (DATA15_MAP),
    //     .DATA16_MAP                (DATA16_MAP),
    //     .DATA17_MAP                (DATA17_MAP),
    //     .MASK0_MAP                 (MASK0_MAP),
    //     .MASK1_MAP                 (MASK1_MAP),
    //     .SLOT_0_CONFIG             (SLOT_0_CONFIG),
    //     .SLOT_1_CONFIG             (SLOT_1_CONFIG),
    //     .MEM_ADDR_ORDER            (MEM_ADDR_ORDER),
    
    //     .IBUF_LPWR_MODE            (IBUF_LPWR_MODE),
    //     .DATA_IO_IDLE_PWRDWN       (DATA_IO_IDLE_PWRDWN),
    //     .DATA_IO_PRIM_TYPE         (DATA_IO_PRIM_TYPE),
    //     .USER_REFRESH              (USER_REFRESH),
    //     .WRLVL                     (WRLVL),
    //     .ORDERING                  (ORDERING),
    //     .CALIB_ROW_ADD             (CALIB_ROW_ADD),
    //     .CALIB_COL_ADD             (CALIB_COL_ADD),
    //     .CALIB_BA_ADD              (CALIB_BA_ADD),
         .TCQ                       (TCQ),
    
         
    //    .IODELAY_GRP               (IODELAY_GRP),
    //    .SYSCLK_TYPE               (SYSCLK_TYPE),
    //    .REFCLK_TYPE               (REFCLK_TYPE),
        .DRAM_TYPE                 (DRAM_TYPE),
    //    .CAL_WIDTH                 (CAL_WIDTH),
    //    .STARVE_LIMIT              (STARVE_LIMIT),
        
         
    //    .REFCLK_FREQ               (REFCLK_FREQ),
        
         
    //    .tCK                       (tCK),
        .nCK_PER_CLK               (nCK_PER_CLK),
        
         
         .C_S_AXI_ID_WIDTH          (C_S_AXI_ID_WIDTH),
         .C_S_AXI_ADDR_WIDTH        (C_S_AXI_ADDR_WIDTH),
         .C_S_AXI_DATA_WIDTH        (C_S_AXI_DATA_WIDTH),
    //     .C_MC_nCK_PER_CLK          (C_MC_nCK_PER_CLK),
         .C_S_AXI_SUPPORTS_NARROW_BURST (C_S_AXI_SUPPORTS_NARROW_BURST),
    //     .C_RD_WR_ARB_ALGORITHM      (C_RD_WR_ARB_ALGORITHM),
    //     .C_S_AXI_REG_EN0           (C_S_AXI_REG_EN0),
    //     .C_S_AXI_REG_EN1           (C_S_AXI_REG_EN1),
        
         .DEBUG_PORT                (DEBUG_PORT),
        
         .RST_ACT_LOW               (RST_ACT_LOW)
        )
  dut
    (
      // asynchronous reset
      .glbl_rst                   (reset),

      // 200MHz clock input from board
      .clk_in_p                   (mmcm_clk_in),
      .clk_in_n                   (!mmcm_clk_in),
      // 125 MHz clock output from MMCM
      .gtx_clk_bufg_out           (gtx_clk),

      .phy_resetn                 (),


      // RGMII Interface
      //----------------
      .rgmii_txd                  (rgmii_txd),
      .rgmii_tx_ctl               (rgmii_tx_ctl),
      .rgmii_txc                  (rgmii_txc),
      .rgmii_rxd                  (rgmii_rxd_dut),
      .rgmii_rx_ctl               (rgmii_rx_ctl_dut),
      .rgmii_rxc                  (delay_rxc),

      // MDIO Interface
      //---------------
      .mdio                       (mdio),
      .mdc                        (mdc),

      // Serialised statistics vectors
      //------------------------------
      .tx_statistics_s            (),
      .rx_statistics_s            (),

      // Serialised Pause interface controls
      //------------------------------------
      .pause_req_s                (1'b0),

      // Main example design controls
      //-----------------------------
      .mac_speed                  (mac_speed),
      .update_speed               (update_speed),
      .config_board               (config_bist),
      .serial_response            (serial_response),
      .gen_tx_data                (gen_tx_data),
      .chk_tx_data                (check_tx_data),
      .reset_error                (1'b0),
      .frame_error                (frame_error),
      .frame_errorn               (),
      .activity_flash             (),
      .activity_flashn            (),
      
      
         // ############### DRAM SIM TASKS - From MIG Example Design // ############### 
              .ddr3_dq              (ddr3_dq_fpga),
              .ddr3_dqs_n           (ddr3_dqs_n_fpga),
              .ddr3_dqs_p           (ddr3_dqs_p_fpga),
         
              .ddr3_addr            (ddr3_addr_fpga),
              .ddr3_ba              (ddr3_ba_fpga),
              .ddr3_ras_n           (ddr3_ras_n_fpga),
              .ddr3_cas_n           (ddr3_cas_n_fpga),
              .ddr3_we_n            (ddr3_we_n_fpga),
              .ddr3_reset_n         (ddr3_reset_n),
              .ddr3_ck_p            (ddr3_ck_p_fpga),
              .ddr3_ck_n            (ddr3_ck_n_fpga),
              .ddr3_cke             (ddr3_cke_fpga),
              .ddr3_cs_n            (ddr3_cs_n_fpga),
             
              .ddr3_dm              (ddr3_dm_fpga),
             
              .ddr3_odt             (ddr3_odt_fpga),
             
              
              //.sys_clk_p            (sys_clk_p),
              //.sys_clk_n            (sys_clk_n),
             
               .init_calib_complete (init_calib_complete),
               .tg_compare_error    (tg_compare_error)
               //.sys_rst             (sys_rst)
        // ############### DRAM SIM TASKS - From MIG Example Design // ###############           

    );

  //---------------------------------------------------------------------------
  //-- If the simulation is still going then
  //-- something has gone wrong
  //---------------------------------------------------------------------------
  initial
  begin
    #620000000;
    $display("** ERROR: Simulation Running Forever");
    $stop;
  end


  //----------------------------------------------------------------------------
  // Simulate the MDIO -
  // respond with sensible data to mdio reads and accept writes
  //----------------------------------------------------------------------------
  // expect mdio to try and read from reg addr 1 - return all 1's if we don't
  // want any other mdio accesses
  // if any other response then mdio will write to reg_addr 9 then 4 then 0
  // (may check for expected write data?)
  // finally mdio read from reg addr 1 until bit 5 is seen high
  // NOTE - do not check any other bits so could drive all high again..


  // count through the mdio transfer
  always @(posedge mdc or posedge reset)
  begin
     if (reset) begin
        mdio_count <= 0;
        last_mdio <= 1'b0;
     end
     else begin
        last_mdio <= mdio;
        if (mdio_count >= 32) begin
           mdio_count <= 0;
        end
        else if (mdio_count != 0) begin
           mdio_count <= mdio_count + 1;
        end
        else begin // only get here if mdio state is 0 - now look for a start
           if ((mdio === 1'b1) && (last_mdio === 1'b0))
              mdio_count <= 1;
        end
     end
  end

  assign mdio = (mdio_read & (mdio_count >= 14) & (mdio_count <= 31)) ? 1'b1 : 1'bz;

  // only respond to phy addr 7 and reg address == 1 (PHY_STATUS)
  always @(posedge mdc or posedge reset)
  begin
     if (reset) begin
        mdio_read <= 1'b0;
        mdio_addr <= 1'b1; // this will go low if the address doesn't match required
        mdio_fail <= 1'b0;
     end
     else
     begin
        if (mdio_count == 2) begin
           mdio_addr <= 1'b1;    // new access so address needs to be revalidated
           if ({last_mdio,mdio} === 2'b10)
              mdio_read <= 1'b1;
           else // take a write as a default as won't drive at the wrong time
              mdio_read <= 1'b0;
        end
        else if ((mdio_count <= 12)) begin
           // check address is phy addr/reg addr are correct
           if (mdio_count <= 7 & mdio_count >= 5) begin
              if (mdio !== 1'b1)
                 mdio_addr <= 1'b0;
           end
           else begin
              if (mdio !== 1'b0)
                 mdio_addr <= 1'b0;
           end
        end
        else if ((mdio_count == 14)) begin
           if (!mdio_read & (mdio | !last_mdio)) begin
              $display("FAIL : Write TA phase is incorrect at %t ps", $time);
           end
        end
        else if ((mdio_count >= 15) & (mdio_count <= 30) & mdio_addr) begin
           if (!mdio_read) begin
              if (mdio_count == 20) begin
                 if (mdio) begin
                    mdio_fail <= 1;
                    $display("FAIL : Expected bit 10 of mdio write data to be 0 at %t ps", $time);
                 end
              end
              else begin
                 if (!mdio) begin
                    mdio_fail <= 1;
                    $display("FAIL : Expected all except bit 10 of mdio write data to be 1 at %t ps", $time);
                 end
              end
           end
        end
     end
  end

  //----------------------------------------------------------------------------
  // Clock drivers
  //----------------------------------------------------------------------------

  //drives input to an MMCM at 200MHz which creates gtx_clk at 125 MHz
  initial
  begin
    
    mmcm_clk_in <= 1'b0;
    
  #80000;
    forever
    begin
      mmcm_clk_in <= 1'b0;
      
      #gtx_period;
      mmcm_clk_in <= 1'b1;
      
      #gtx_period;
    end
  end

  // drives rgmii_rxc_1000 at 125 MHz
  initial
  begin
    rgmii_rxc_1000 <= 1'b0;
    #10000;
    forever
    begin
      rgmii_rxc_1000 <= 1'b0;
      #4000;
      rgmii_rxc_1000 <= 1'b1;
      #4000;
    end
  end


  // drives rgmii_rxc_100 at 25 MHz
  initial
  begin
    rgmii_rxc_100 <= 1'b0;
    #10000;
    forever
    begin
      rgmii_rxc_100 <= 1'b0;
      #20000;
      rgmii_rxc_100 <= 1'b1;
      #20000;
    end
  end


  // drives rgmii_rxc_10 at 2.5 MHz
  initial
  begin
    rgmii_rxc_10 <= 1'b0;
    #10000;
    forever
    begin
      rgmii_rxc_10 <= 1'b0;
      #200000;
      rgmii_rxc_10 <= 1'b1;
      #200000;
    end
  end

  // want a clean swicth between the clocks - provide a low setting
  // Select between 10Mb/s, 100Mb/s and 1Gb/s RGMII Rx clock frequencies
  assign rgmii_rxc = (phy_speed == 2'b11 ? 1'b0 :
                      phy_speed == 2'b10 ? rgmii_rxc_1000 :
                     (phy_speed == 2'b01 ? rgmii_rxc_100 : rgmii_rxc_10));




  //----------------------------------------------------------------------------
  // A Task to reset the MAC
  //----------------------------------------------------------------------------
  task mac_reset;
    begin
      $display("** Note: Resetting core...");

      reset <= 1'b1;
      #400000

      reset <= 1'b0;

      $display("** Note: Timing checks are valid");
    end
  endtask // mac_reset;

  // monitor frame error and output error when asserted (with timestamp)
  always @(posedge gtx_clk or posedge reset)
  begin
     if (reset) begin
        bist_mode_error <= 0;
     end
     else if (frame_error & !bist_mode_error) begin
        bist_mode_error <= 1;
        $display("ERROR: frame mismatch at time %t ps", $time);
     end
  end

  //----------------------------------------------------------------------------
  // Management process. This process waits for setup to complete by monitoring the mdio
  // (the host always runs at gtx_clk so the setup after mdio accesses are complete
  // doesn't take long) and then allows packets to be sent
  //----------------------------------------------------------------------------
  initial
  begin : p_management

    mac_speed <= 2'b10;
    phy_speed <= 2'b10;
    update_speed <= 1'b0;
    gen_tx_data <= 1'b0;
    check_tx_data <= 1'b0;
    config_bist <= 0;
    management_config_finished <= 0;

    // reset the core
    mac_reset;


    // check mdio
    // wait for the mdio access and remainder of setup accesses (internal)
    wait (mdio_count == 32);
    wait (mdio_count == 0);

    if (TB_MODE == "BIST") begin
       gen_tx_data <= 1'b1;
       check_tx_data <= 1'b1;
       // run for a set time and then stop
       repeat (15000) @(posedge gtx_clk);
       // Our work here is done

       if (frame_error) begin
          $display("ERROR: Frame mismatch seen");
       end
       else if (serial_response) begin
          $display("ERROR: AXI4 Lite state Machine error.  Incorrect or non-existant PTP frame.");
       end
       else begin
          $display("Test completed successfully");
       end
       $display("Simulation Stopped");
       $stop;
    end
    else begin

       // Signal that configuration is complete.  Other processes will now
       // be allowed to run.
       management_config_finished = 1;

       // The stimulus process will now send 4 frames at 1Gb/s.
       //------------------------------------------------------------------

       // Wait for 1G monitor process to complete.
       wait (tx_monitor_finished_1G == 1);
       management_config_finished = 0;

       // Change the speed to 100Mb/s and send the 4 frames
       //------------------------------------------------------------------

       @(posedge gtx_clk);
       mac_speed <= 2'b01;
       update_speed <= 1'b1;
       @(posedge gtx_clk);
       @(posedge gtx_clk);
       @(posedge gtx_clk);
       update_speed <= 1'b0;

       // wait for the mdio access and remainder of setup accesses (internal)
       wait (mdio_count == 8);
       phy_speed <= 2'b01;
       wait (mdio_count == 32);
       wait (mdio_count == 0);
       // Signal that configuration is complete.  Other processes will now
       // be allowed to run.
       management_config_finished = 1;

       // Wait for 100M monitor process to complete.
       wait (tx_monitor_finished_100M == 1);
       management_config_finished = 0;

       // Change the speed to 10Mb/s and send the 4 frames
       //------------------------------------------------------------------

       @(posedge gtx_clk);
       mac_speed <= 2'b00;
       update_speed <= 1'b1;
       @(posedge gtx_clk);
       @(posedge gtx_clk);
       @(posedge gtx_clk);
       update_speed <= 1'b0;

       // wait for the mdio access and remainder of setup accesses (internal)
       wait (mdio_count == 8);
       phy_speed <= 2'b00;
       wait (mdio_count == 32);
       wait (mdio_count == 0);

       management_config_finished = 1;

       // Wait for 10M monitor process to complete.
       wait (tx_monitor_finished_10M == 1);
       management_config_finished = 0;

       // Change the speed back to 1Gb/s and send the 4 frames
       //------------------------------------------------------------------

       @(posedge gtx_clk);
       mac_speed <= 2'b10;
       phy_speed <= 2'b10;
       update_speed <= 1'b1;
       @(posedge gtx_clk);
       @(posedge gtx_clk);
       @(posedge gtx_clk);
       update_speed <= 1'b0;

       // wait for the mdio access and remainder of setup accesses (internal)
       wait (mdio_count == 8);
       wait (mdio_count == 32);
       wait (mdio_count == 0);

       management_config_finished = 1;
       wait (tx_monitor_finished_1G == 1);

       // Our work here is done
       if (demo_mode_error == 1'b0 && bist_mode_error == 1'b0) begin
         $display("Test completed successfully");
       end
       $display("Simulation Stopped");
       $stop;
     end
  end // p_management



  //----------------------------------------------------------------------------
  // Procedure to inject a frame into the receiver at 1Gb/s
  //----------------------------------------------------------------------------
  task send_frame_1g;
    input   `FRAME_TYP frame;
    integer column_index;
    integer I;
    reg [31:0] fcs;
    begin
      // import the frame into scratch space
      rx_stimulus_working_frame.frombits(frame);

      // Reset the FCS calculation
      fcs = 32'b0;
      @(posedge rgmii_rxc);

      column_index = 0;

      // Adding the preamble field
      for (I = 0; I <= 13; I = I + 1)
      begin
        rgmii_rxd   <= 4'h5;
        rgmii_rx_ctl <= 1'b1;
        @(rgmii_rxc);
      end

      // Adding the Start of Frame Delimiter (SFD)
      rgmii_rxd   <= 4'h5;
      rgmii_rx_ctl <= 1'b1;
      @(rgmii_rxc)
      rgmii_rxd   <= 4'hD;
      rgmii_rx_ctl <= 1'b1;
      @(rgmii_rxc)

      // loop over columns in frame.
      while (rx_stimulus_working_frame.valid[column_index] !== 1'b0)
      begin
        // send one column of data
        rgmii_rxd    <= rx_stimulus_working_frame.data[column_index][3:0];
        rgmii_rx_ctl <= rx_stimulus_working_frame.valid[column_index];
        @(rgmii_rxc)
        rgmii_rxd    <= rx_stimulus_working_frame.data[column_index][7:4];
        rgmii_rx_ctl <= rx_stimulus_working_frame.valid[column_index] ^ rx_stimulus_working_frame.error[column_index];
        calc_crc(rx_stimulus_working_frame.data[column_index], fcs);

        column_index = column_index + 1;
        @(rgmii_rxc);  // wait for next clock tick

      end

      // Send the CRC.
      for (I = 0; I < 4; I = I + 1)
      begin
        case(I)
           0 : rgmii_rxd    <= fcs[3:0];
           1 : rgmii_rxd    <= fcs[11:8];
           2 : rgmii_rxd    <= fcs[19:16];
           3 : rgmii_rxd    <= fcs[27:24];
        endcase
        rgmii_rx_ctl <= 1'b1;
        @(rgmii_rxc)
        case(I)
           0 : rgmii_rxd    <= fcs[7:4];
           1 : rgmii_rxd    <= fcs[15:12];
           2 : rgmii_rxd    <= fcs[23:20];
           3 : rgmii_rxd    <= fcs[31:28];
        endcase
        rgmii_rx_ctl <= 1'b1;

        @(rgmii_rxc);  // wait for next clock tick
      end

      // Clear the data lines.
      rgmii_rxd       <= 4'h0;
      rgmii_rx_ctl    <= 1'b0;

      // Adding the minimum Interframe gap for a receiver (8 idles)
      for (I = 0; I < 16; I = I + 1)
        @(rgmii_rxc);

    end
  endtask // send_frame_1g;


  //----------------------------------------------------------------------------
  // Procedure to inject a frame into the receiver at 10/100Mb/s
  //----------------------------------------------------------------------------
  task send_frame_10_100m;
    input   `FRAME_TYP frame;
    integer column_index;
    integer I;
    reg [31:0] fcs;
    begin
      // import the frame into scratch space
      rx_stimulus_working_frame.frombits(frame);

      // Reset the FCS calculation
      fcs = 32'b0;

      @(posedge rgmii_rxc);

      column_index = 0;

      // Adding the preamble field
      for (I = 0; I <= 13; I = I + 1)
      begin
        rgmii_rxd   <= 4'h5;
        rgmii_rx_ctl <= 1'b1;
        @(posedge rgmii_rxc);
      end

      // Adding the Start of Frame Delimiter (SFD)
      rgmii_rxd   <= 4'h5;
      rgmii_rx_ctl <= 1'b1;
      @(posedge rgmii_rxc);
      rgmii_rxd   <= 4'hD;
      rgmii_rx_ctl <= 1'b1;
      @(posedge rgmii_rxc);
      // loop over columns in frame.
      while (rx_stimulus_working_frame.valid[column_index] !== 1'b0)
      begin
        // send one column of data
        rgmii_rxd    <= rx_stimulus_working_frame.data[column_index][3:0];
        rgmii_rx_ctl <= rx_stimulus_working_frame.valid[column_index];
        @(posedge rgmii_rxc);
        rgmii_rxd    <= rx_stimulus_working_frame.data[column_index][7:4];
        rgmii_rx_ctl <= rx_stimulus_working_frame.valid[column_index] ^ rx_stimulus_working_frame.error[column_index];
        calc_crc(rx_stimulus_working_frame.data[column_index], fcs);
        @(posedge rgmii_rxc);
      column_index = column_index + 1;
      end

      // Send the CRC.
      for (I = 0; I < 4; I = I + 1)
      begin
        case(I)
           0 : rgmii_rxd    <= fcs[3:0];
           1 : rgmii_rxd    <= fcs[11:8];
           2 : rgmii_rxd    <= fcs[19:16];
           3 : rgmii_rxd    <= fcs[27:24];
        endcase
        rgmii_rx_ctl <= 1'b1;
        @(posedge rgmii_rxc);
        case(I)
           0 : rgmii_rxd    <= fcs[7:4];
           1 : rgmii_rxd    <= fcs[15:12];
           2 : rgmii_rxd    <= fcs[23:20];
           3 : rgmii_rxd    <= fcs[31:28];
        endcase
        rgmii_rx_ctl <= 1'b1;
        @(posedge rgmii_rxc);
      end

      // Clear the data lines.
      rgmii_rxd       <= 4'h0;
      rgmii_rx_ctl    <= 1'b0;

      // Adding the minimum Interframe gap for a receiver (8 idles)
      for (I = 0; I < 32; I = I + 1)
        @(rgmii_rxc);

    end
  endtask // send_frame_10_100m;


  //----------------------------------------------------------------------------
  // Stimulus process. This process will inject frames of data into the
  // PHY side of the receiver.
  //----------------------------------------------------------------------------
  initial
  begin : p_rx_stimulus

    // Initialise stimulus
    rgmii_rxd      = 4'h0;
    rgmii_rx_ctl   = 1'b0;

    // Send four frames through the MAC and Design Exampled
    // at each state Ethernet speed
    //      -- frame 0 = standard frame
    //      -- frame 1 = type frame
    //      -- frame 2 = frame containing an error
    //      -- frame 3 = standard frame with padding
    //-----------------------------------------------------



    // 1 Gb/s speed
    //-----------------------------------------------------
    // Wait for the Management MDIO transaction to finish.
    while (management_config_finished !== 1)
    // wait for the internal resets to settle before staring to send traffic
    #800000;
    $display("Rx Stimulus: sending 4 frames at 1G ... ");

    send_frame_1g(frame0.tobits(0));
    send_frame_1g(frame1.tobits(1));
    send_frame_1g(frame2.tobits(2));
    send_frame_1g(frame3.tobits(3));

    wait (tx_monitor_finished_1G == 1);
    #10000;

    // 100 Mb/s speed
    //-----------------------------------------------------
    while (management_config_finished !== 1) @(posedge management_config_finished);
    $display("Rx Stimulus: sending 4 frames at 100M ... ");

    send_frame_10_100m(frame0.tobits(0));
    send_frame_10_100m(frame1.tobits(1));
    send_frame_10_100m(frame2.tobits(2));
    send_frame_10_100m(frame3.tobits(3));

    wait (tx_monitor_finished_100M == 1);
    #10000;

    // 10 Mb/s speed
    //-----------------------------------------------------
    while (management_config_finished !== 1) @(posedge management_config_finished);
    $display("Rx Stimulus: sending 4 frames at 10M ... ");

    send_frame_10_100m(frame0.tobits(0));
    send_frame_10_100m(frame1.tobits(1));
    send_frame_10_100m(frame2.tobits(2));
    send_frame_10_100m(frame3.tobits(3));

    wait (tx_monitor_finished_10M == 1);
    #10000;

    // 1 Gb/s speed
    //-----------------------------------------------------
    while (management_config_finished !== 1) @(posedge management_config_finished);
    $display("Rx Stimulus: sending 4 frames at 1G ... ");

    send_frame_1g(frame0.tobits(0));
    send_frame_1g(frame1.tobits(1));
    send_frame_1g(frame2.tobits(2));
    send_frame_1g(frame3.tobits(3));


  end // p_rx_stimulus



  //----------------------------------------------------------------------------
  // A Task to check a transmitted frame at 1Gb/s
  //----------------------------------------------------------------------------
  task check_frame_1g;
    input `FRAME_TYP frame;
    integer column_index;
    integer I;
    reg [8*4:0] frame_type;
    reg [31:0] fcs;
    reg [7:0]  rgmii_column;
    reg [1:0]  rgmii_valid;

  begin
    // import the frame into scratch space
    tx_monitor_working_frame.frombits(frame);

    column_index = 0;
    // If the current frame had an error inserted then it would have
    // been dropped by the FIFO in the design example.  Therefore
    // exit this task and move immediately on to the next frame.
    if (tx_monitor_working_frame.bad_frame !== 1'b1)
    begin

      // reset the fcs calculation
      fcs = 32'b0;

      // wait until the first real column of data to come out of RX client
      while (rgmii_tx_ctl !== 1'b1)
        @(rgmii_txc);

      // check tx_ctl has gone high at the correct edge (should be rising)
      if (!rgmii_txc) begin
         $display("** ERROR: tx_ctl started on incorrect phase at %t", $realtime, "ps");
        demo_mode_error <= 1;
      end

      // Parse over the preamble field
      while (rgmii_txd === 4'h5)
        @(negedge rgmii_txc);

      // Parse over the SFD
      if (rgmii_txd !== 4'hd) begin
         $display("** ERROR: SFD not present at %t", $realtime, "ps");
        demo_mode_error <= 1;
      end
      @(posedge rgmii_txc);

      if (TB_MODE == "DEMO") begin
         // Start comparing transmitted data to received data
         $display("** Note: Comparing Transmitted Frame with Injected Frame");

         // frame has started, loop over columns of frame
         while (tx_monitor_working_frame.valid[column_index] !== 1'b0)
         begin

           rgmii_column[3:0] = rgmii_txd[3:0];
           rgmii_valid[0]    = rgmii_tx_ctl;
           @(rgmii_txc);
           rgmii_column[7:4]= rgmii_txd[3:0];
           rgmii_valid[1]    = rgmii_tx_ctl;

           // The transmitted Destination Address was the Source Address
           // of the injected frame
           if (column_index < 6)
           begin

             if (rgmii_valid[0] !== tx_monitor_working_frame.valid[column_index+6]) begin
               $display("** ERROR: rgmii_tx_ctl incorrect during Destination Address at %t", $realtime, "ps");
               demo_mode_error <= 1;
             end
             if (rgmii_valid[1] !== tx_monitor_working_frame.valid[column_index+6]) begin
               $display("** ERROR: rgmii_tx_ctl incorrect during Destination Address at %t", $realtime, "ps");
               demo_mode_error <= 1;
             end

             if (rgmii_column !== tx_monitor_working_frame.data[(column_index+6)]) begin
               $display("** ERROR: rgmii_txd incorrect during Destination Address at %t", $realtime, "ps");
               demo_mode_error <= 1;
             end
           end

           // The transmitted Source Address was the Destination Address
           // of the injected frame
           else if (column_index < 12)
           begin

             if (rgmii_valid[0] !== tx_monitor_working_frame.valid[column_index-6]) begin
               $display("** ERROR: rgmii_tx_ctl incorrect during Source Address at %t", $realtime, "ps");
               demo_mode_error <= 1;
             end
             if (rgmii_valid[1] !== tx_monitor_working_frame.valid[column_index-6]) begin
               $display("** ERROR: rgmii_tx_ctl incorrect during Source Address at %t", $realtime, "ps");
               demo_mode_error <= 1;
             end

             if (rgmii_column !== tx_monitor_working_frame.data[(column_index-6)]) begin
               $display("** ERROR: rgmii_txd incorrect during Source Address at %t", $realtime, "ps");
               demo_mode_error <= 1;
             end
           end

           // check all other data in the frame
           else
           begin

             if (rgmii_valid[0] !== tx_monitor_working_frame.valid[column_index]) begin
               $display("** ERROR: rgmii_tx_ctl incorrect at %t", $realtime, "ps");
               demo_mode_error <= 1;
             end
             if (rgmii_valid[1] !== tx_monitor_working_frame.valid[column_index]) begin
               $display("** ERROR: rgmii_tx_ctl incorrect at %t", $realtime, "ps");
               demo_mode_error <= 1;
             end

             if (rgmii_column !== tx_monitor_working_frame.data[(column_index)]) begin
               $display("** ERROR: rgmii_txd incorrect at %t", $realtime, "ps");
               demo_mode_error <= 1;
             end
           end

           // calculate expected crc for the frame
           calc_crc(rgmii_column, fcs);

           // wait for next column of data
           column_index = column_index + 1;
           @(rgmii_txc);
         end

         // Check the FCS
         // Having checked all data columns, txd must contain FCS.
         for (I = 0; I < 4; I = I + 1)
         begin
           rgmii_column[3:0] = rgmii_txd[3:0];
           rgmii_valid[0]    = rgmii_tx_ctl;
           @(rgmii_txc);
           rgmii_column[7:4] = rgmii_txd[3:0];
           rgmii_valid[1]    = rgmii_tx_ctl;

           if (rgmii_valid !== 2'b11) begin
             $display("** ERROR: rgmii_tx_ctl incorrect during FCS field at %t", $realtime, "ps");
             demo_mode_error <= 1;
           end

           case(I)
              0 : if (rgmii_column !== fcs[7:0]) begin
                     $display("** ERROR: rgmii_txd incorrect during FCS field at %t", $realtime, "ps");
                     demo_mode_error <= 1;
                   end
              1 :  if (rgmii_column !== fcs[15:8]) begin
                     $display("** ERROR: rgmii_txd incorrect during FCS field at %t", $realtime, "ps");
                     demo_mode_error <= 1;
                   end
              2 :  if (rgmii_column !== fcs[23:16]) begin
                     $display("** ERROR: rgmii_txd incorrect during FCS field at %t", $realtime, "ps");
                     demo_mode_error <= 1;
                   end
              3 :  if (rgmii_column !== fcs[31:24]) begin
                     $display("** ERROR: rgmii_txd incorrect during FCS field at %t", $realtime, "ps");
                     demo_mode_error <= 1;
                   end
           endcase

           @(rgmii_txc);
         end
      end
      else begin
         // this is the BIST tb mode - want to idnetify the frame type  - VLAN or not to help with the bandwidth calc
         // check the type field and if equal to 81 then classify as vlan (could do more but that should be adequate)
         frame_type = "";
         while (rgmii_tx_ctl) begin
            rgmii_column[3:0] = rgmii_txd[3:0];
            @(rgmii_txc);
            rgmii_column[7:4]= rgmii_txd[3:0];
            if (column_index == 12 & rgmii_column == 8'h81) begin
               frame_type = "VLAN";
            end

            // wait for next column of data
            column_index = column_index + 1;
            @(rgmii_txc);
         end
         $display("%s Frame transmitted : Size %d", frame_type, column_index);
      end
    end
   end
  endtask // check_frame_1g


  //----------------------------------------------------------------------------
  // Procedure to check a transmitted frame at 10/100Mb/s
  //----------------------------------------------------------------------------
  task check_frame_10_100m;
    input `FRAME_TYP frame;
    integer column_index;
    integer I;
    reg [31:0] fcs;
    reg [7:0]  rgmii_column;
    reg [1:0]  rgmii_valid;

  begin
    // import the frame into scratch space
    tx_monitor_working_frame.frombits(frame);

    column_index = 0;

    // If the current frame had an error inserted then it would have
    // been dropped by the FIFO in the design example.  Therefore
    // exit this task and move immediately on to the next frame.
    if (tx_monitor_working_frame.bad_frame !== 1'b1)
    begin

      // reset the fcs calculation
      fcs = 32'b0;

      // wait until the first real column of data to come out of RX client
      while (rgmii_tx_ctl !== 1'b1)
        @(rgmii_txc);

      // check tx_ctl has gone high at the correct edge (should be rising)
      if (!rgmii_txc) begin
         $display("** ERROR: tx_ctl started on incorrect phase at %t", $realtime, "ps");
        demo_mode_error <= 1;
      end

      // Parse over the preamble field
      while (rgmii_txd === 4'h5)
        @(posedge rgmii_txc);

      // Start comparing transmitted data to received data
      $display("** Note: Comparing Transmitted Frame with Injected Frame");

      // Parse over the SFD
      if (rgmii_txd !== 4'hd) begin
         $display("** ERROR: SFD not present at %t", $realtime, "ps");
         demo_mode_error <= 1;
      end
      @(posedge rgmii_txc);

      // frame has started, loop over columns of frame
      while (tx_monitor_working_frame.valid[column_index] !== 1'b0)
      begin

        rgmii_column[3:0] = rgmii_txd[3:0];
        rgmii_valid[0]    = rgmii_tx_ctl;
        @(posedge rgmii_txc);
        rgmii_column[7:4]= rgmii_txd[3:0];
        rgmii_valid[1]    = rgmii_tx_ctl;

        // The transmitted Destination Address was the Source Address
        // of the injected frame
        if (column_index < 6)
        begin

           if (rgmii_valid[0] !== tx_monitor_working_frame.valid[column_index+6]) begin
            $display("** ERROR: rgmii_tx_ctl incorrect during Destination Address at %t", $realtime, "ps");
            demo_mode_error <= 1;
          end
           if (rgmii_valid[1] !== tx_monitor_working_frame.valid[column_index+6]) begin
            $display("** ERROR: rgmii_tx_ctl incorrect during Destination Address at %t", $realtime, "ps");
            demo_mode_error <= 1;
          end

          if (rgmii_column !== tx_monitor_working_frame.data[(column_index+6)]) begin
            $display("** ERROR: rgmii_txd incorrect during Destination Address at %t", $realtime, "ps");
            demo_mode_error <= 1;
          end
        end

        // The transmitted Source Address was the Destination Address
        // of the injected frame
        else if (column_index < 12)
        begin
          if (rgmii_valid[0] !== tx_monitor_working_frame.valid[column_index-6]) begin
            $display("** ERROR: rgmii_tx_ctl incorrect during Source Address at %t", $realtime, "ps");
            demo_mode_error <= 1;
          end

          if (rgmii_valid[1] !== tx_monitor_working_frame.valid[column_index-6]) begin
            $display("** ERROR: rgmii_tx_ctl incorrect during Source Address at %t", $realtime, "ps");
            demo_mode_error <= 1;
          end

          if (rgmii_column !== tx_monitor_working_frame.data[(column_index-6)]) begin
            $display("** ERROR: rgmii_txd incorrect during Source Address at %t", $realtime, "ps");
            demo_mode_error <= 1;
          end
        end

        // check all other data in the frame
        else
        begin
          if (rgmii_valid[0] !== tx_monitor_working_frame.valid[column_index]) begin
            $display("** ERROR: rgmii_tx_ctl incorrect at %t", $realtime, "ps");
            demo_mode_error <= 1;
          end
          if (rgmii_valid[1] !== tx_monitor_working_frame.valid[column_index]) begin
            $display("** ERROR: rgmii_tx_ctl incorrect at %t", $realtime, "ps");
            demo_mode_error <= 1;
          end

          if (rgmii_column !== tx_monitor_working_frame.data[(column_index)]) begin
            $display("** ERROR: rgmii_txd incorrect at %t", $realtime, "ps");
            demo_mode_error <= 1;
          end
          if (rgmii_tx_ctl !== tx_monitor_working_frame.valid[column_index]) begin
            $display("** ERROR: rgmii_tx_ctl incorrect");
            demo_mode_error <= 1;
          end
        end

        // calculate expected crc for the frame
        calc_crc(rgmii_column, fcs);

        // wait for next column of data
        column_index = column_index + 1;
        @(posedge rgmii_txc);
      end

      // Check the FCS
      // Having checked all data columns, txd must contain FCS.
      for (I = 0; I < 4; I = I + 1)
      begin
        rgmii_column[3:0] = rgmii_txd[3:0];
        rgmii_valid[0]    = rgmii_tx_ctl;
        @(posedge rgmii_txc);
        rgmii_column[7:4] = rgmii_txd[3:0];
        rgmii_valid[1]    = rgmii_tx_ctl;

        if (rgmii_valid !== 2'b11) begin
          $display("** ERROR: rgmii_tx_ctl incorrect during FCS field at %t", $realtime, "ps");
          demo_mode_error <= 1;
        end

        case(I)
           0 : if (rgmii_column !== fcs[7:0]) begin
                 $display("** ERROR: rgmii_txd incorrect during FCS field at %t", $realtime, "ps");
                 demo_mode_error <= 1;
               end
           1 : if (rgmii_column !== fcs[15:8]) begin
                 $display("** ERROR: rgmii_txd incorrect during FCS field at %t", $realtime, "ps");
                 demo_mode_error <= 1;
               end
           2 : if (rgmii_column !== fcs[23:16]) begin
                 $display("** ERROR: rgmii_txd incorrect during FCS field at %t", $realtime, "ps");
                 demo_mode_error <= 1;
               end
           3 : if (rgmii_column !== fcs[31:24]) begin
                 $display("** ERROR: rgmii_txd incorrect during FCS field at %t", $realtime, "ps");
                 demo_mode_error <= 1;
               end
        endcase

        @(negedge rgmii_txc);
         // check tx_ctl has gone low at the correct edge (should be rising)
         if (!rgmii_tx_ctl) begin
            $display("** ERROR: tx_ctl stopped on incorrect phase at %t", $realtime, "ps");
            demo_mode_error <= 1;
         end

        @(posedge rgmii_txc);
      end

    end
   end
  endtask // check_frame_10_100m


  //----------------------------------------------------------------------------
  // Monitor process. This process checks the data coming out of the
  // transmitter to make sure that it matches that inserted into the
  // receiver.
  //----------------------------------------------------------------------------

  initial
  begin : p_tx_monitor
    tx_monitor_finished_1G    <= 0;
    tx_monitor_finished_100M  <= 0;
    tx_monitor_finished_10M   <= 0;

    if (TB_MODE == "DEMO") begin
       // Compare the transmitted frame to the received frames
       //      -- frame 0 = minimum length frame
       //      -- frame 1 = type frame
       //      -- frame 2 = errored frame
       //      -- frame 3 = padded frame
       // Repeated for all stated speeds.
       //-----------------------------------------------------

       // wait for the reset to complete before starting monitor
       @(negedge reset);

       // 1 Gb/s speed
       //-----------------------------------------------------

       // Check the frames
       check_frame_1g(frame0.tobits(0));
       check_frame_1g(frame1.tobits(0));
       check_frame_1g(frame2.tobits(0));
       check_frame_1g(frame3.tobits(0));

       #200000
       tx_monitor_finished_1G  <= 1;

       // 100 Mb/s speed
       //-----------------------------------------------------

       // Check the frames
       check_frame_10_100m(frame0.tobits(0));
       check_frame_10_100m(frame1.tobits(0));
       check_frame_10_100m(frame2.tobits(0));
       check_frame_10_100m(frame3.tobits(0));

       #200000
       tx_monitor_finished_100M  <= 1;
       tx_monitor_finished_1G    <= 0;

       // 10 Mb/s speed
       //-----------------------------------------------------

       // Check the frames
       check_frame_10_100m(frame0.tobits(0));
       check_frame_10_100m(frame1.tobits(0));
       check_frame_10_100m(frame2.tobits(0));
       check_frame_10_100m(frame3.tobits(0));

       #200000
       tx_monitor_finished_10M  <= 1;

       // 1 Gb/s speed
       //-----------------------------------------------------

       // Check the frames
       check_frame_1g(frame0.tobits(0));
       check_frame_1g(frame1.tobits(0));
       check_frame_1g(frame2.tobits(0));
       check_frame_1g(frame3.tobits(0));

       #200000
       tx_monitor_finished_1G  <= 1;

     end
     else begin
       forever check_frame_1g(frame0.tobits(0));
     end

  end // p_tx_monitor


  
// ############### DRAM SIM TASKS - From MIG Example Design // ###############   
    //**************************************************************************//
    // Memory Models instantiations
    //**************************************************************************//
  
    genvar r,i;
    generate
      for (r = 0; r < CS_WIDTH; r = r + 1) begin: mem_rnk
        for (i = 0; i < NUM_COMP; i = i + 1) begin: gen_mem
          ddr3_model u_comp_ddr3
            (
             .rst_n   (ddr3_reset_n),
             .ck      (ddr3_ck_p_sdram[(i*MEMORY_WIDTH)/72]),
             .ck_n    (ddr3_ck_n_sdram[(i*MEMORY_WIDTH)/72]),
             .cke     (ddr3_cke_sdram[((i*MEMORY_WIDTH)/72)+(1*r)]),
             .cs_n    (ddr3_cs_n_sdram[((i*MEMORY_WIDTH)/72)+(1*r)]),
             .ras_n   (ddr3_ras_n_sdram),
             .cas_n   (ddr3_cas_n_sdram),
             .we_n    (ddr3_we_n_sdram),
             .dm_tdqs (ddr3_dm_sdram[i]),
             .ba      (ddr3_ba_sdram[r]),
             .addr    (ddr3_addr_sdram[r]),
             .dq      (ddr3_dq_sdram[MEMORY_WIDTH*(i+1)-1:MEMORY_WIDTH*(i)]),
             .dqs     (ddr3_dqs_p_sdram[i]),
             .dqs_n   (ddr3_dqs_n_sdram[i]),
             .tdqs_n  (),
             .odt     (ddr3_odt_sdram[((i*MEMORY_WIDTH)/72)+(1*r)])
             );
        end
      end
    endgenerate
      
      
  
  
    //***************************************************************************
    // Reporting the test case status
    // Status reporting logic exists both in simulation test bench (sim_tb_top)
    // and sim.do file for ModelSim. Any update in simulation run time or time out
    // in this file need to be updated in sim.do file as well.
    //***************************************************************************
    initial
    begin : Logging
       fork
          begin : calibration_done
             wait (init_calib_complete);
             $display("Calibration Done");
             #50000000.0;
             if (!tg_compare_error) begin
                $display("TEST PASSED");
             end
             else begin
                $display("TEST FAILED: DATA ERROR");
             end
             disable calib_not_done;
              $finish;
          end
  
          begin : calib_not_done
             if (SIM_BYPASS_INIT_CAL == "SIM_INIT_CAL_FULL")
               #2500000000.0;
             else
               #1000000000.0;
             if (!init_calib_complete) begin
                $display("TEST FAILED: INITIALIZATION DID NOT COMPLETE");
             end
             disable calibration_done;
              $finish;
          end
       join
    end
  // ############### END DRAM SIM SIM TB - From MIG Example Design // ############### 

endmodule


// Copyright 1986-2014 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2014.2 (win64) Build 928826 Thu Jun  5 18:17:50 MDT 2014
// Date        : Sat Jun 07 13:26:49 2014
// Host        : XCOJAMESM22 running 64-bit Service Pack 1  (build 7601)
// Command     : write_verilog -force -mode synth_stub
//               C:/kc705_mig/mig_7series_0_example/mig_7series_0_example.srcs/sources_1/ip/ila_ddrx_native/ila_ddrx_native_stub.v
// Design      : ila_ddrx_native
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7k325tffg900-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "ila,Vivado 2014.2" *)
module ila_ddrx_native(clk, trig_out, trig_out_ack, probe0, probe1, probe2, probe3, probe4, probe5, probe6, probe7, probe8, probe9, probe10, probe11, probe12, probe13, probe14, probe15, probe16, probe17, probe18, probe19, probe20, probe21, probe22, probe23, probe24, probe25, probe26, probe27, probe28, probe29, probe30, probe31, probe32, probe33, probe34, probe35, probe36, probe37, probe38, probe39, probe40, probe41, probe42, probe43, probe44, probe45, probe46, probe47, probe48, probe49, probe50, probe51, probe52, probe53, probe54, probe55, probe56, probe57, probe58, probe59, probe60, probe61, probe62, probe63, probe64, probe65, probe66, probe67, probe68, probe69, probe70, probe71, probe72, probe73, probe74, probe75, probe76, probe77, probe78, probe79, probe80, probe81, probe82, probe83, probe84, probe85, probe86, probe87, probe88, probe89, probe90, probe91, probe92, probe93, probe94, probe95, probe96, probe97, probe98, probe99, probe100, probe101, probe102, probe103)
/* synthesis syn_black_box black_box_pad_pin="clk,trig_out,trig_out_ack,probe0[0:0],probe1[0:0],probe2[0:0],probe3[0:0],probe4[0:0],probe5[0:0],probe6[0:0],probe7[0:0],probe8[0:0],probe9[0:0],probe10[1:0],probe11[1:0],probe12[1:0],probe13[0:0],probe14[0:0],probe15[0:0],probe16[0:0],probe17[0:0],probe18[5:0],probe19[0:0],probe20[63:0],probe21[0:0],probe22[0:0],probe23[0:0],probe24[0:0],probe25[0:0],probe26[0:0],probe27[0:0],probe28[63:0],probe29[7:0],probe30[7:0],probe31[31:0],probe32[5:0],probe33[0:0],probe34[0:0],probe35[0:0],probe36[1:0],probe37[4:0],probe38[3:0],probe39[0:0],probe40[0:0],probe41[5:0],probe42[2:0],probe43[5:0],probe44[0:0],probe45[0:0],probe46[5:0],probe47[5:0],probe48[4:0],probe49[5:0],probe50[0:0],probe51[0:0],probe52[3:0],probe53[4:0],probe54[4:0],probe55[0:0],probe56[0:0],probe57[3:0],probe58[53:0],probe59[26:0],probe60[11:0],probe61[11:0],probe62[11:0],probe63[5:0],probe64[3:0],probe65[7:0],probe66[7:0],probe67[7:0],probe68[7:0],probe69[7:0],probe70[7:0],probe71[7:0],probe72[7:0],probe73[0:0],probe74[0:0],probe75[5:0],probe76[5:0],probe77[5:0],probe78[4:0],probe79[11:0],probe80[11:0],probe81[5:0],probe82[5:0],probe83[5:0],probe84[107:0],probe85[107:0],probe86[107:0],probe87[89:0],probe88[254:0],probe89[0:0],probe90[0:0],probe91[5:0],probe92[5:0],probe93[7:0],probe94[7:0],probe95[7:0],probe96[7:0],probe97[7:0],probe98[7:0],probe99[7:0],probe100[7:0],probe101[0:0],probe102[0:0],probe103[0:0]" */;
  input clk;
  output trig_out;
  input trig_out_ack;
  input [0:0]probe0;
  input [0:0]probe1;
  input [0:0]probe2;
  input [0:0]probe3;
  input [0:0]probe4;
  input [0:0]probe5;
  input [0:0]probe6;
  input [0:0]probe7;
  input [0:0]probe8;
  input [0:0]probe9;
  input [1:0]probe10;
  input [1:0]probe11;
  input [1:0]probe12;
  input [0:0]probe13;
  input [0:0]probe14;
  input [0:0]probe15;
  input [0:0]probe16;
  input [0:0]probe17;
  input [5:0]probe18;
  input [0:0]probe19;
  input [63:0]probe20;
  input [0:0]probe21;
  input [0:0]probe22;
  input [0:0]probe23;
  input [0:0]probe24;
  input [0:0]probe25;
  input [0:0]probe26;
  input [0:0]probe27;
  input [63:0]probe28;
  input [7:0]probe29;
  input [7:0]probe30;
  input [31:0]probe31;
  input [5:0]probe32;
  input [0:0]probe33;
  input [0:0]probe34;
  input [0:0]probe35;
  input [1:0]probe36;
  input [4:0]probe37;
  input [3:0]probe38;
  input [0:0]probe39;
  input [0:0]probe40;
  input [5:0]probe41;
  input [2:0]probe42;
  input [5:0]probe43;
  input [0:0]probe44;
  input [0:0]probe45;
  input [5:0]probe46;
  input [5:0]probe47;
  input [4:0]probe48;
  input [5:0]probe49;
  input [0:0]probe50;
  input [0:0]probe51;
  input [3:0]probe52;
  input [4:0]probe53;
  input [4:0]probe54;
  input [0:0]probe55;
  input [0:0]probe56;
  input [3:0]probe57;
  input [53:0]probe58;
  input [26:0]probe59;
  input [11:0]probe60;
  input [11:0]probe61;
  input [11:0]probe62;
  input [5:0]probe63;
  input [3:0]probe64;
  input [7:0]probe65;
  input [7:0]probe66;
  input [7:0]probe67;
  input [7:0]probe68;
  input [7:0]probe69;
  input [7:0]probe70;
  input [7:0]probe71;
  input [7:0]probe72;
  input [0:0]probe73;
  input [0:0]probe74;
  input [5:0]probe75;
  input [5:0]probe76;
  input [5:0]probe77;
  input [4:0]probe78;
  input [11:0]probe79;
  input [11:0]probe80;
  input [5:0]probe81;
  input [5:0]probe82;
  input [5:0]probe83;
  input [107:0]probe84;
  input [107:0]probe85;
  input [107:0]probe86;
  input [89:0]probe87;
  input [254:0]probe88;
  input [0:0]probe89;
  input [0:0]probe90;
  input [5:0]probe91;
  input [5:0]probe92;
  input [7:0]probe93;
  input [7:0]probe94;
  input [7:0]probe95;
  input [7:0]probe96;
  input [7:0]probe97;
  input [7:0]probe98;
  input [7:0]probe99;
  input [7:0]probe100;
  input [0:0]probe101;
  input [0:0]probe102;
  input [0:0]probe103;
endmodule

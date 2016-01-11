// Copyright 1986-2014 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2014.2 (win64) Build 932637 Wed Jun 11 13:33:10 MDT 2014
// Date        : Fri Jun 26 18:20:08 2015
// Host        : radar-PC running 64-bit Service Pack 1  (build 7601)
// Command     : write_verilog -force -mode synth_stub
//               C:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.srcs/sources_1/ip/dds_compiler_v5_0_1/dds_ddc_stub.v
// Design      : dds_ddc
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7k325tffg900-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "dds_compiler_v6_0,Vivado 2014.2" *)
module dds_ddc(aclk, aresetn, m_axis_data_tvalid, m_axis_data_tdata, event_pinc_invalid, event_poff_invalid)
/* synthesis syn_black_box black_box_pad_pin="aclk,aresetn,m_axis_data_tvalid,m_axis_data_tdata[47:0],event_pinc_invalid,event_poff_invalid" */;
  input aclk;
  input aresetn;
  output m_axis_data_tvalid;
  output [47:0]m_axis_data_tdata;
  output event_pinc_invalid;
  output event_poff_invalid;
endmodule

// Copyright 1986-2014 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2014.2 (win64) Build 928826 Thu Jun  5 18:17:50 MDT 2014
// Date        : Sat Jun 07 13:03:25 2014
// Host        : XCOJAMESM22 running 64-bit Service Pack 1  (build 7601)
// Command     : write_verilog -force -mode synth_stub
//               c:/kc705_mig/kc705_mig.srcs/sources_1/ip/mig_7series_0/mig_7series_0_stub.v
// Design      : mig_7series_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7k325tffg900-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module mig_7series_0(ddr3_dq, ddr3_dqs_n, ddr3_dqs_p, ddr3_addr, ddr3_ba, ddr3_ras_n, ddr3_cas_n, ddr3_we_n, ddr3_reset_n, ddr3_ck_p, ddr3_ck_n, ddr3_cke, ddr3_cs_n, ddr3_dm, ddr3_odt, sys_clk_p, sys_clk_n, app_addr, app_cmd, app_en, app_wdf_data, app_wdf_end, app_wdf_mask, app_wdf_wren, app_rd_data, app_rd_data_end, app_rd_data_valid, app_rdy, app_wdf_rdy, app_sr_req, app_ref_req, app_zq_req, app_sr_active, app_ref_ack, app_zq_ack, ui_clk, ui_clk_sync_rst, ddr3_ila_wrpath, ddr3_ila_rdpath, ddr3_ila_basic, ddr3_vio_sync_out, dbg_byte_sel, dbg_sel_pi_incdec, dbg_pi_f_inc, dbg_pi_f_dec, dbg_sel_po_incdec, dbg_po_f_inc, dbg_po_f_dec, dbg_po_f_stg23_sel, dbg_pi_counter_read_val, dbg_po_counter_read_val, init_calib_complete, sys_rst)
/* synthesis syn_black_box black_box_pad_pin="ddr3_dq[63:0],ddr3_dqs_n[7:0],ddr3_dqs_p[7:0],ddr3_addr[13:0],ddr3_ba[2:0],ddr3_ras_n,ddr3_cas_n,ddr3_we_n,ddr3_reset_n,ddr3_ck_p[0:0],ddr3_ck_n[0:0],ddr3_cke[0:0],ddr3_cs_n[0:0],ddr3_dm[7:0],ddr3_odt[0:0],sys_clk_p,sys_clk_n,app_addr[27:0],app_cmd[2:0],app_en,app_wdf_data[511:0],app_wdf_end,app_wdf_mask[63:0],app_wdf_wren,app_rd_data[511:0],app_rd_data_end,app_rd_data_valid,app_rdy,app_wdf_rdy,app_sr_req,app_ref_req,app_zq_req,app_sr_active,app_ref_ack,app_zq_ack,ui_clk,ui_clk_sync_rst,ddr3_ila_wrpath[390:0],ddr3_ila_rdpath[1023:0],ddr3_ila_basic[119:0],ddr3_vio_sync_out[13:0],dbg_byte_sel[3:0],dbg_sel_pi_incdec,dbg_pi_f_inc,dbg_pi_f_dec,dbg_sel_po_incdec,dbg_po_f_inc,dbg_po_f_dec,dbg_po_f_stg23_sel,dbg_pi_counter_read_val[5:0],dbg_po_counter_read_val[8:0],init_calib_complete,sys_rst" */;
  inout [63:0]ddr3_dq;
  inout [7:0]ddr3_dqs_n;
  inout [7:0]ddr3_dqs_p;
  output [13:0]ddr3_addr;
  output [2:0]ddr3_ba;
  output ddr3_ras_n;
  output ddr3_cas_n;
  output ddr3_we_n;
  output ddr3_reset_n;
  output [0:0]ddr3_ck_p;
  output [0:0]ddr3_ck_n;
  output [0:0]ddr3_cke;
  output [0:0]ddr3_cs_n;
  output [7:0]ddr3_dm;
  output [0:0]ddr3_odt;
  input sys_clk_p;
  input sys_clk_n;
  input [27:0]app_addr;
  input [2:0]app_cmd;
  input app_en;
  input [511:0]app_wdf_data;
  input app_wdf_end;
  input [63:0]app_wdf_mask;
  input app_wdf_wren;
  output [511:0]app_rd_data;
  output app_rd_data_end;
  output app_rd_data_valid;
  output app_rdy;
  output app_wdf_rdy;
  input app_sr_req;
  input app_ref_req;
  input app_zq_req;
  output app_sr_active;
  output app_ref_ack;
  output app_zq_ack;
  output ui_clk;
  output ui_clk_sync_rst;
  output [390:0]ddr3_ila_wrpath;
  output [1023:0]ddr3_ila_rdpath;
  output [119:0]ddr3_ila_basic;
  input [13:0]ddr3_vio_sync_out;
  input [3:0]dbg_byte_sel;
  input dbg_sel_pi_incdec;
  input dbg_pi_f_inc;
  input dbg_pi_f_dec;
  input dbg_sel_po_incdec;
  input dbg_po_f_inc;
  input dbg_po_f_dec;
  input dbg_po_f_stg23_sel;
  output [5:0]dbg_pi_counter_read_val;
  output [8:0]dbg_po_counter_read_val;
  output init_calib_complete;
  input sys_rst;
endmodule

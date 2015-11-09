// -- (c) Copyright 2010 - 2013 Xilinx, Inc. All rights reserved.
// --
// -- This file contains confidential and proprietary information
// -- of Xilinx, Inc. and is protected under U.S. and 
// -- international copyright and other intellectual property
// -- laws.
// --
// -- DISCLAIMER
// -- This disclaimer is not a license and does not grant any
// -- rights to the materials distributed herewith. Except as
// -- otherwise provided in a valid license issued to you by
// -- Xilinx, and to the maximum extent permitted by applicable
// -- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// -- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// -- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// -- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// -- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// -- (2) Xilinx shall not be liable (whether in contract or tort,
// -- including negligence, or under any other theory of
// -- liability) for any loss or damage of any kind or nature
// -- related to, arising under or in connection with these
// -- materials, including for any direct, or any indirect,
// -- special, incidental, or consequential loss or damage
// -- (including loss of data, profits, goodwill, or any type of
// -- loss or damage suffered as a result of any action brought
// -- by a third party) even if such damage or loss was
// -- reasonably foreseeable or Xilinx had been advised of the
// -- possibility of the same.
// --
// -- CRITICAL APPLICATIONS
// -- Xilinx products are not designed or intended to be fail-
// -- safe, or for use in any application requiring fail-safe
// -- performance, such as life-support or safety devices or
// -- systems, Class III medical devices, nuclear facilities,
// -- applications related to the deployment of airbags, or any
// -- other applications that could lead to death, personal
// -- injury, or severe property or environmental damage
// -- (individually and collectively, "Critical
// -- Applications"). Customer assumes the sole risk and
// -- liability of any use of Xilinx products in Critical
// -- Applications, subject only to applicable laws and
// -- regulations governing limitations on product liability.
// --
// -- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// -- PART OF THIS FILE AT ALL TIMES.
//-----------------------------------------------------------------------------
//
// Clock converter module
//   Asynchronous clock converter when asynchronous M:N conversion
//   Bypass when synchronous and ratio between S and M clock is 1:1
//   Synchronous clock converter (S:M or M:S must be integer ratio)  
//
// Verilog-standard:  Verilog 2001
//--------------------------------------------------------------------------
//
// Structure:
//   axi_clock_conv
//     fifo_generator
//     axic_sync_clock_converter
//       axic_sample_cycle_ratio
//
// PROTECTED NAMES:
//   Instance names "asyncfifo_*" are pattern-matched in core-level UCF.
//   Signal names "*_resync" are pattern-matched in core-level UCF.
//
//--------------------------------------------------------------------------

`timescale 1ps/1ps

(* DowngradeIPIdentifiedWarnings="yes" *) 
module axi_interconnect_v1_7_axi_clock_converter #
  (parameter         C_FAMILY = "rtl",                      // FPGA Family. Current version: virtex6 or spartan6.
   parameter integer C_AXI_ID_WIDTH = 5,                    // Width of all ID signals on SI and MI side.
                                                            // Range: >= 1.
   parameter integer C_AXI_ADDR_WIDTH = 32,                 // Width of S_AXI_AWADDR, S_AXI_ARADDR, M_AXI_AWADDR and 
                                                            // M_AXI_ARADDR.
                                                            // Range: 32.
   parameter integer C_AXI_DATA_WIDTH = 32,       // Width of WDATA and RDATA (either side).
                                                            // Format: Bit32; 
                                                            // Range: 'h00000020, 'h00000040, 'h00000080, 'h00000100.
   parameter         C_S_AXI_ACLK_RATIO = 1,     // Clock frequency ratio of SI w.r.t. MI.
   parameter         C_M_AXI_ACLK_RATIO = 1,     // (Slowest of all clock inputs should have ratio=1.)
                                                            // S:M or M:S must be integer ratio.
                                                            // Format: Bit32; Range: >='h00000001.
   parameter integer C_AXI_IS_ACLK_ASYNC = 1,            // Indicates whether S and M clocks are asynchronous.
                                                            // FUTURE FEATURE
                                                            // Format: Bit1. Range = 1'b0.
   parameter integer C_AXI_PROTOCOL = 0,         // Protocol of this SI/MI slot.
   parameter integer C_AXI_SUPPORTS_USER_SIGNALS  = 0,      // 1 = Propagate all USER signals, 0 = Do not propagate.
   parameter integer C_AXI_AWUSER_WIDTH = 1,                // Width of AWUSER signals. 
                                                            // Range: >= 1.
   parameter integer C_AXI_ARUSER_WIDTH = 1,                // Width of ARUSER signals. 
                                                            // Range: >= 1.
   parameter integer C_AXI_WUSER_WIDTH = 1,                 // Width of WUSER signals. 
                                                            // Range: >= 1.
   parameter integer C_AXI_RUSER_WIDTH = 1,                 // Width of RUSER signals. 
                                                            // Range: >= 1.
   parameter integer C_AXI_BUSER_WIDTH = 1,                 // Width of BUSER signals. 
                                                            // Range: >= 1.
   parameter integer C_AXI_SUPPORTS_WRITE = 1,              // Implement AXI write channels
   parameter integer C_AXI_SUPPORTS_READ = 1,               // Implement AXI read channels
   parameter integer C_SYNCHRONIZER_STAGE = 3
  )

  (
   // Global Signals
   input  wire                            INTERCONNECT_ACLK,
   input  wire                            INTERCONNECT_ARESETN,
   input  wire                            LOCAL_ARESETN,
   output wire                            INTERCONNECT_RESET_OUT_N,
   output wire                            S_AXI_RESET_OUT_N,
   output wire                            M_AXI_RESET_OUT_N,

   // Slave Interface System Signals
   (* KEEP = "TRUE" *) input  wire        S_AXI_ACLK,

   // Slave Interface Write Address Ports
   input  wire [C_AXI_ID_WIDTH-1:0]       S_AXI_AWID,
   input  wire [C_AXI_ADDR_WIDTH-1:0]     S_AXI_AWADDR,
   input  wire [8-1:0]                    S_AXI_AWLEN,
   input  wire [3-1:0]                    S_AXI_AWSIZE,
   input  wire [2-1:0]                    S_AXI_AWBURST,
   input  wire [2-1:0]                    S_AXI_AWLOCK,
   input  wire [4-1:0]                    S_AXI_AWCACHE,
   input  wire [3-1:0]                    S_AXI_AWPROT,
   input  wire [4-1:0]                    S_AXI_AWREGION,
   input  wire [4-1:0]                    S_AXI_AWQOS,
   input  wire [C_AXI_AWUSER_WIDTH-1:0]   S_AXI_AWUSER,
   input  wire                            S_AXI_AWVALID,
   output wire                            S_AXI_AWREADY,

   // Slave Interface Write Data Ports
   input  wire [C_AXI_DATA_WIDTH-1:0]     S_AXI_WDATA,
   input  wire [C_AXI_DATA_WIDTH/8-1:0]   S_AXI_WSTRB,
   input  wire                            S_AXI_WLAST,
   input  wire [C_AXI_WUSER_WIDTH-1:0]    S_AXI_WUSER,
   input  wire                            S_AXI_WVALID,
   output wire                            S_AXI_WREADY,

   // Slave Interface Write Response Ports
   output wire [C_AXI_ID_WIDTH-1:0]       S_AXI_BID,
   output wire [2-1:0]                    S_AXI_BRESP,
   output wire [C_AXI_BUSER_WIDTH-1:0]    S_AXI_BUSER,
   output wire                            S_AXI_BVALID,
   input  wire                            S_AXI_BREADY,

   // Slave Interface Read Address Ports
   input  wire [C_AXI_ID_WIDTH-1:0]       S_AXI_ARID,
   input  wire [C_AXI_ADDR_WIDTH-1:0]     S_AXI_ARADDR,
   input  wire [8-1:0]                    S_AXI_ARLEN,
   input  wire [3-1:0]                    S_AXI_ARSIZE,
   input  wire [2-1:0]                    S_AXI_ARBURST,
   input  wire [2-1:0]                    S_AXI_ARLOCK,
   input  wire [4-1:0]                    S_AXI_ARCACHE,
   input  wire [3-1:0]                    S_AXI_ARPROT,
   input  wire [4-1:0]                    S_AXI_ARREGION,
   input  wire [4-1:0]                    S_AXI_ARQOS,
   input  wire [C_AXI_ARUSER_WIDTH-1:0]   S_AXI_ARUSER,
   input  wire                            S_AXI_ARVALID,
   output wire                            S_AXI_ARREADY,

   // Slave Interface Read Data Ports
   output wire [C_AXI_ID_WIDTH-1:0]       S_AXI_RID,
   output wire [C_AXI_DATA_WIDTH-1:0]     S_AXI_RDATA,
   output wire [2-1:0]                    S_AXI_RRESP,
   output wire                            S_AXI_RLAST,
   output wire [C_AXI_RUSER_WIDTH-1:0]    S_AXI_RUSER,
   output wire                            S_AXI_RVALID,
   input  wire                            S_AXI_RREADY,
   
   // Master Interface System Signals
   (* KEEP = "TRUE" *) input  wire        M_AXI_ACLK,

   // Master Interface Write Address Port
   output wire [C_AXI_ID_WIDTH-1:0]       M_AXI_AWID,
   output wire [C_AXI_ADDR_WIDTH-1:0]     M_AXI_AWADDR,
   output wire [8-1:0]                    M_AXI_AWLEN,
   output wire [3-1:0]                    M_AXI_AWSIZE,
   output wire [2-1:0]                    M_AXI_AWBURST,
   output wire [2-1:0]                    M_AXI_AWLOCK,
   output wire [4-1:0]                    M_AXI_AWCACHE,
   output wire [3-1:0]                    M_AXI_AWPROT,
   output wire [4-1:0]                    M_AXI_AWREGION,
   output wire [4-1:0]                    M_AXI_AWQOS,
   output wire [C_AXI_AWUSER_WIDTH-1:0]   M_AXI_AWUSER,
   output wire                            M_AXI_AWVALID,  
   input  wire                            M_AXI_AWREADY,

   // Master Interface Write Data Ports
   output wire [C_AXI_DATA_WIDTH-1:0]     M_AXI_WDATA,
   output wire [C_AXI_DATA_WIDTH/8-1:0]   M_AXI_WSTRB,
   output wire                            M_AXI_WLAST,
   output wire [C_AXI_WUSER_WIDTH-1:0]    M_AXI_WUSER,
   output wire                            M_AXI_WVALID,
   input  wire                            M_AXI_WREADY,

   // Master Interface Write Response Ports
   input  wire [C_AXI_ID_WIDTH-1:0]       M_AXI_BID,
   input  wire [2-1:0]                    M_AXI_BRESP,
   input  wire [C_AXI_BUSER_WIDTH-1:0]    M_AXI_BUSER,
   input  wire                            M_AXI_BVALID,
   output wire                            M_AXI_BREADY,

   // Master Interface Read Address Port
   output wire [C_AXI_ID_WIDTH-1:0]       M_AXI_ARID,
   output wire [C_AXI_ADDR_WIDTH-1:0]     M_AXI_ARADDR,
   output wire [8-1:0]                    M_AXI_ARLEN,
   output wire [3-1:0]                    M_AXI_ARSIZE,
   output wire [2-1:0]                    M_AXI_ARBURST,
   output wire [2-1:0]                    M_AXI_ARLOCK,
   output wire [4-1:0]                    M_AXI_ARCACHE,
   output wire [3-1:0]                    M_AXI_ARPROT,
   output wire [4-1:0]                    M_AXI_ARREGION,
   output wire [4-1:0]                    M_AXI_ARQOS,
   output wire [C_AXI_ARUSER_WIDTH-1:0]   M_AXI_ARUSER,
   output wire                            M_AXI_ARVALID,
   input  wire                            M_AXI_ARREADY,

   // Master Interface Read Data Ports
   input  wire [C_AXI_ID_WIDTH-1:0]       M_AXI_RID,
   input  wire [C_AXI_DATA_WIDTH-1:0]     M_AXI_RDATA,
   input  wire [2-1:0]                    M_AXI_RRESP,
   input  wire                            M_AXI_RLAST,
   input  wire [C_AXI_RUSER_WIDTH-1:0]    M_AXI_RUSER,
   input  wire                            M_AXI_RVALID,
   output wire                            M_AXI_RREADY);

  function integer f_ceil_log2
    (
     input integer x
     );
    integer acc;
    begin
      acc=0;
      while ((2**acc) < x)
        acc = acc + 1;
      f_ceil_log2 = acc;
    end
  endfunction

  localparam P_AXILITE = 32'h00000002;
  localparam integer P_LIGHT_WT = 0;
  localparam integer P_FULLY_REG = 1;
  localparam integer P_LUTRAM_ASYNC = 12;
  localparam P_PRIM_FIFO_TYPE = "512x72" ;
  
  // Sample cycle ratio
  localparam  P_SI_LT_MI = (C_S_AXI_ACLK_RATIO < C_M_AXI_ACLK_RATIO);
  localparam integer P_ROUNDING_OFFSET = P_SI_LT_MI ? (C_S_AXI_ACLK_RATIO/2) : (C_M_AXI_ACLK_RATIO/2);
  localparam integer P_ACLK_RATIO = P_SI_LT_MI ? ((C_M_AXI_ACLK_RATIO + P_ROUNDING_OFFSET) / C_S_AXI_ACLK_RATIO) : ((C_S_AXI_ACLK_RATIO + P_ROUNDING_OFFSET) / C_M_AXI_ACLK_RATIO);
  localparam integer P_LOAD_CNT = (P_ACLK_RATIO > 2) ? (P_ACLK_RATIO - 3) : 0;
  localparam integer P_ACLK_RATIO_LOG = f_ceil_log2(P_ACLK_RATIO);
  
  wire fast_aclk;
  wire slow_aclk;
  wire fast_areset;
  wire slow_areset;
  wire sample_cycle;
  wire sample_cycle_early;
  
  // Write Address Port bit positions
  localparam integer C_AWUSER_RIGHT   = 0;
  localparam integer C_AWUSER_LEN     = C_AXI_SUPPORTS_USER_SIGNALS*C_AXI_AWUSER_WIDTH;
  localparam integer C_AWQOS_RIGHT    = C_AWUSER_RIGHT + C_AWUSER_LEN;
  localparam integer C_AWQOS_LEN      = 4;
  localparam integer C_AWREGION_RIGHT = C_AWQOS_RIGHT + C_AWQOS_LEN;
  localparam integer C_AWREGION_LEN   = 4;
  localparam integer C_AWPROT_RIGHT   = C_AWREGION_RIGHT + C_AWREGION_LEN;
  localparam integer C_AWPROT_LEN     = 3;
  localparam integer C_AWCACHE_RIGHT  = C_AWPROT_RIGHT + C_AWPROT_LEN;
  localparam integer C_AWCACHE_LEN    = 4;
  localparam integer C_AWLOCK_RIGHT   = C_AWCACHE_RIGHT + C_AWCACHE_LEN;
  localparam integer C_AWLOCK_LEN     = 2;
  localparam integer C_AWBURST_RIGHT  = C_AWLOCK_RIGHT + C_AWLOCK_LEN;
  localparam integer C_AWBURST_LEN    = 2;
  localparam integer C_AWSIZE_RIGHT   = C_AWBURST_RIGHT + C_AWBURST_LEN;
  localparam integer C_AWSIZE_LEN     = 3;
  localparam integer C_AWLEN_RIGHT    = C_AWSIZE_RIGHT + C_AWSIZE_LEN;
  localparam integer C_AWLEN_LEN      = 8;
  localparam integer C_AWADDR_RIGHT   = C_AWLEN_RIGHT + C_AWLEN_LEN;
  localparam integer C_AWADDR_LEN     = C_AXI_ADDR_WIDTH;
  localparam integer C_AWID_RIGHT     = C_AWADDR_RIGHT + C_AWADDR_LEN;
  localparam integer C_AWID_LEN       = C_AXI_ID_WIDTH;
  localparam integer C_AW_SIZE        = C_AWID_RIGHT + C_AWID_LEN;

  // Write Address Port FIFO data read and write
  wire [C_AW_SIZE-1:0] s_aw_data ;
  wire [C_AW_SIZE-1:0] m_aw_data ;

  // Write Data Port bit positions
  localparam integer C_WUSER_RIGHT   = 0;
  localparam integer C_WUSER_LEN     = C_AXI_SUPPORTS_USER_SIGNALS*C_AXI_WUSER_WIDTH;
  localparam integer C_WLAST_RIGHT   = C_WUSER_RIGHT + C_WUSER_LEN;
  localparam integer C_WLAST_LEN     = 1;
  localparam integer C_WSTRB_RIGHT   = C_WLAST_RIGHT + C_WLAST_LEN;
  localparam integer C_WSTRB_LEN     = C_AXI_DATA_WIDTH/8;
  localparam integer C_WDATA_RIGHT   = C_WSTRB_RIGHT + C_WSTRB_LEN;
  localparam integer C_WDATA_LEN     = C_AXI_DATA_WIDTH;
  localparam integer C_W_SIZE        = C_WDATA_RIGHT + C_WDATA_LEN;
  localparam integer C_W_FIFOGEN_SIZE = C_W_SIZE + C_AXI_ID_WIDTH;

  // Write Data Port FIFO data read and write
  wire [C_W_SIZE-1:0] s_w_data;
  wire [C_W_SIZE-1:0] m_w_data;

  // Write Response Port bit positions
  localparam integer C_BUSER_RIGHT   = 0;
  localparam integer C_BUSER_LEN     = C_AXI_SUPPORTS_USER_SIGNALS*C_AXI_BUSER_WIDTH;
  localparam integer C_BRESP_RIGHT   = C_BUSER_RIGHT + C_BUSER_LEN;
  localparam integer C_BRESP_LEN     = 2;
  localparam integer C_BID_RIGHT     = C_BRESP_RIGHT + C_BRESP_LEN;
  localparam integer C_BID_LEN       = C_AXI_ID_WIDTH;
  localparam integer C_B_SIZE        = C_BID_RIGHT + C_BID_LEN;

  // Write Response Port FIFO data read and write
  wire [C_B_SIZE-1:0] s_b_data;
  wire [C_B_SIZE-1:0] m_b_data;

  // Read Address Port bit positions
  localparam integer C_ARUSER_RIGHT   = 0;
  localparam integer C_ARUSER_LEN     = C_AXI_SUPPORTS_USER_SIGNALS*C_AXI_ARUSER_WIDTH;
  localparam integer C_ARQOS_RIGHT    = C_ARUSER_RIGHT + C_ARUSER_LEN;
  localparam integer C_ARQOS_LEN      = 4;
  localparam integer C_ARREGION_RIGHT = C_ARQOS_RIGHT + C_ARQOS_LEN;
  localparam integer C_ARREGION_LEN   = 4;
  localparam integer C_ARPROT_RIGHT   = C_ARREGION_RIGHT + C_ARREGION_LEN;
  localparam integer C_ARPROT_LEN     = 3;
  localparam integer C_ARCACHE_RIGHT  = C_ARPROT_RIGHT + C_ARPROT_LEN;
  localparam integer C_ARCACHE_LEN    = 4;
  localparam integer C_ARLOCK_RIGHT   = C_ARCACHE_RIGHT + C_ARCACHE_LEN;
  localparam integer C_ARLOCK_LEN     = 2;
  localparam integer C_ARBURST_RIGHT  = C_ARLOCK_RIGHT + C_ARLOCK_LEN;
  localparam integer C_ARBURST_LEN    = 2;
  localparam integer C_ARSIZE_RIGHT   = C_ARBURST_RIGHT + C_ARBURST_LEN;
  localparam integer C_ARSIZE_LEN     = 3;
  localparam integer C_ARLEN_RIGHT    = C_ARSIZE_RIGHT + C_ARSIZE_LEN;
  localparam integer C_ARLEN_LEN      = 8;
  localparam integer C_ARADDR_RIGHT   = C_ARLEN_RIGHT + C_ARLEN_LEN;
  localparam integer C_ARADDR_LEN     = C_AXI_ADDR_WIDTH;
  localparam integer C_ARID_RIGHT     = C_ARADDR_RIGHT + C_ARADDR_LEN;
  localparam integer C_ARID_LEN       = C_AXI_ID_WIDTH;
  localparam integer C_AR_SIZE        = C_ARID_RIGHT + C_ARID_LEN;

  // Read Address Port FIFO data read and write
  wire [C_AR_SIZE-1:0] s_ar_data;
  wire [C_AR_SIZE-1:0] m_ar_data;

  // Read Data Ports bit positions
  localparam integer C_RUSER_RIGHT   = 0;
  localparam integer C_RUSER_LEN     = C_AXI_SUPPORTS_USER_SIGNALS*C_AXI_RUSER_WIDTH;
  localparam integer C_RLAST_RIGHT   = C_RUSER_RIGHT + C_RUSER_LEN;
  localparam integer C_RLAST_LEN     = 1;
  localparam integer C_RRESP_RIGHT   = C_RLAST_RIGHT + C_RLAST_LEN;
  localparam integer C_RRESP_LEN     = 2;
  localparam integer C_RDATA_RIGHT   = C_RRESP_RIGHT + C_RRESP_LEN;
  localparam integer C_RDATA_LEN     = C_AXI_DATA_WIDTH;
  localparam integer C_RID_RIGHT     = C_RDATA_RIGHT + C_RDATA_LEN;
  localparam integer C_RID_LEN       = C_AXI_ID_WIDTH;
  localparam integer C_R_SIZE        = C_RID_RIGHT + C_RID_LEN;

  // Read Data Ports FIFO data read and write
  wire [C_R_SIZE-1:0] s_r_data;
  wire [C_R_SIZE-1:0] m_r_data;

  // Reset resynchronization signals
  wire interconnect_areset_i;
  (* async_reg="yes", shreg_extract="no", iob="false", equivalent_register_removal = "no" *) reg [3:0] m_axi_aresetn_resync;
  (* async_reg="yes", shreg_extract="no", iob="false", equivalent_register_removal = "no" *) reg [3:0] s_axi_aresetn_resync;
  (* async_reg="yes", shreg_extract="no", iob="false", equivalent_register_removal = "no" *) reg [3:0] interconnect_aresetn_resync;
  (* async_reg="yes", shreg_extract="no" *) reg  [2:0] interconnect_aresetn_pipe;
  (* async_reg="yes", shreg_extract="no" *) reg  [2:0] m_axi_aresetn_pipe;
  (* async_reg="yes", shreg_extract="no" *) reg  [2:0] s_axi_aresetn_pipe;
  (* async_reg="yes", KEEP = "TRUE", shreg_extract="no", iob="false", equivalent_register_removal = "no" *) reg m_async_conv_reset /* synthesis syn_keep = 1 */;
  (* async_reg="yes", KEEP = "TRUE", shreg_extract="no", iob="false", equivalent_register_removal = "no" *) reg s_async_conv_reset /* synthesis syn_keep = 1 */;
  
  wire async_conv_reset_n;
  wire s_axi_reset_out_i; 
  wire m_axi_reset_out_i; 
  reg  s_axi_reset_out_n_i; 
  reg  m_axi_reset_out_n_i; 

  ////////////////////////////////////////////////////////////////////////////////
  // AXI Reset Signal Resynchronization
  ////////////////////////////////////////////////////////////////////////////////
  
  assign interconnect_areset_i = ~INTERCONNECT_ARESETN;
  
  assign INTERCONNECT_RESET_OUT_N = interconnect_aresetn_pipe[2];
  always @(posedge INTERCONNECT_ACLK or posedge interconnect_areset_i) begin
    if (interconnect_areset_i) begin
      interconnect_aresetn_resync <= 4'b0000;
    end else begin
      interconnect_aresetn_resync <= {interconnect_aresetn_resync[2:0], 1'b1};
    end
  end
  always @(posedge INTERCONNECT_ACLK) begin
    if (~interconnect_aresetn_resync[3]) begin
      interconnect_aresetn_pipe <= 3'b000;
    end else begin
      interconnect_aresetn_pipe <= {interconnect_aresetn_pipe[1:0], 1'b1};
    end
  end
  
  assign async_conv_reset_n = ~(m_async_conv_reset | s_async_conv_reset);
  always @(posedge S_AXI_ACLK) begin
    s_async_conv_reset <= s_axi_reset_out_i;
  end
  always @(posedge M_AXI_ACLK) begin
    m_async_conv_reset <= m_axi_reset_out_i;
  end
  
  
  generate
    if ((C_AXI_IS_ACLK_ASYNC == 1'b1) ||
        (P_ACLK_RATIO > 1)) begin : gen_aresetn_sync
      
      assign M_AXI_RESET_OUT_N = m_axi_aresetn_pipe[2];
      assign m_axi_reset_out_i = ~m_axi_aresetn_pipe[2];
      always @(posedge M_AXI_ACLK or posedge interconnect_areset_i) begin
        if (interconnect_areset_i) begin
          m_axi_aresetn_resync <= 4'b0000;
        end else begin
          m_axi_aresetn_resync <= {m_axi_aresetn_resync[2:0], 1'b1};
        end
      end
      always @(posedge M_AXI_ACLK) begin
        if (~m_axi_aresetn_resync[3]) begin
          m_axi_aresetn_pipe <= 3'b000;
        end else begin
          m_axi_aresetn_pipe <= {m_axi_aresetn_pipe[1:0], 1'b1};
        end
      end
      
      assign S_AXI_RESET_OUT_N = s_axi_aresetn_pipe[2];
      assign s_axi_reset_out_i = ~s_axi_aresetn_pipe[2];
      always @(posedge S_AXI_ACLK or posedge interconnect_areset_i) begin
        if (interconnect_areset_i) begin
          s_axi_aresetn_resync <= 4'b0000;
        end else begin
          s_axi_aresetn_resync <= {s_axi_aresetn_resync[2:0], 1'b1};
        end
      end
      always @(posedge S_AXI_ACLK) begin
        if (~s_axi_aresetn_resync[3]) begin
          s_axi_aresetn_pipe <= 3'b000;
        end else begin
          s_axi_aresetn_pipe <= {s_axi_aresetn_pipe[1:0], 1'b1};
        end
      end
      
    end else begin : gen_no_aresetn_sync
      always @(posedge M_AXI_ACLK) begin
        m_axi_reset_out_n_i <= LOCAL_ARESETN;
      end
      always @(posedge S_AXI_ACLK) begin
        s_axi_reset_out_n_i <= LOCAL_ARESETN;
      end
      assign M_AXI_RESET_OUT_N = m_axi_reset_out_n_i;
      assign S_AXI_RESET_OUT_N = s_axi_reset_out_n_i;
      assign m_axi_reset_out_i = 1'b0;
      assign s_axi_reset_out_i = 1'b0;
    end  
    
  if (C_AXI_IS_ACLK_ASYNC && (C_AXI_SUPPORTS_READ == 0)) begin : gen_async_writeonly
      // Read Address Port
      assign M_AXI_ARID     = 0;
      assign M_AXI_ARADDR   = 0;
      assign M_AXI_ARLEN    = 0;
      assign M_AXI_ARSIZE   = 0;
      assign M_AXI_ARBURST  = 0;
      assign M_AXI_ARLOCK   = 0;
      assign M_AXI_ARCACHE  = 0;
      assign M_AXI_ARPROT   = 0;
      assign M_AXI_ARREGION = 0;
      assign M_AXI_ARQOS    = 0;
      assign M_AXI_ARUSER   = 0;
      assign M_AXI_ARVALID  = 1'b0;
      assign S_AXI_ARREADY  = 1'b0;

      // Read Data Port
      assign S_AXI_RID      = 0;
      assign S_AXI_RDATA    = 0;
      assign S_AXI_RRESP    = 0;
      assign S_AXI_RLAST    = 0;
      assign S_AXI_RUSER    = 0;
      assign S_AXI_RVALID   = 1'b0;
      assign M_AXI_RREADY   = 1'b0;
      
  fifo_generator_v10_0 #(
          .C_ADD_NGC_CONSTRAINT(0),
          .C_APPLICATION_TYPE_AXIS(0),
          .C_APPLICATION_TYPE_RACH(0),
          .C_APPLICATION_TYPE_RDCH(0),
          .C_APPLICATION_TYPE_WACH(0),
          .C_APPLICATION_TYPE_WDCH(0),
          .C_APPLICATION_TYPE_WRCH(0),
          .C_AXI_ADDR_WIDTH(C_AXI_ADDR_WIDTH),
          .C_AXI_ARUSER_WIDTH(C_AXI_ARUSER_WIDTH),
          .C_AXI_AWUSER_WIDTH(C_AXI_AWUSER_WIDTH),
          .C_AXI_BUSER_WIDTH(C_AXI_BUSER_WIDTH),
          .C_AXI_DATA_WIDTH(C_AXI_DATA_WIDTH),
          .C_AXI_ID_WIDTH(C_AXI_ID_WIDTH),
          .C_AXI_RUSER_WIDTH(C_AXI_RUSER_WIDTH),
          .C_AXI_TYPE(1),
          .C_AXI_WUSER_WIDTH(C_AXI_WUSER_WIDTH),
          .C_AXIS_TDATA_WIDTH(64),
          .C_AXIS_TDEST_WIDTH(4),
          .C_AXIS_TID_WIDTH(4),
          .C_AXIS_TKEEP_WIDTH(4),
          .C_AXIS_TSTRB_WIDTH(4),
          .C_AXIS_TUSER_WIDTH(4),
          .C_AXIS_TYPE(0),
          .C_COMMON_CLOCK(0),
          .C_COUNT_TYPE(0),
          .C_DATA_COUNT_WIDTH(10),
          .C_DEFAULT_VALUE("BlankString"),
          .C_DIN_WIDTH(18),
          .C_DIN_WIDTH_AXIS(1),
          .C_DIN_WIDTH_RACH(C_AR_SIZE),
          .C_DIN_WIDTH_RDCH(C_R_SIZE),
          .C_DIN_WIDTH_WACH(C_AW_SIZE),
          .C_DIN_WIDTH_WDCH(C_W_FIFOGEN_SIZE),
          .C_DIN_WIDTH_WRCH(C_B_SIZE),
          .C_DOUT_RST_VAL("0"),
          .C_DOUT_WIDTH(18),
          .C_ENABLE_RLOCS(0),
          .C_ENABLE_RST_SYNC(1),
          .C_ERROR_INJECTION_TYPE(0),
          .C_ERROR_INJECTION_TYPE_AXIS(0),
          .C_ERROR_INJECTION_TYPE_RACH(0),
          .C_ERROR_INJECTION_TYPE_RDCH(0),
          .C_ERROR_INJECTION_TYPE_WACH(0),
          .C_ERROR_INJECTION_TYPE_WDCH(0),
          .C_ERROR_INJECTION_TYPE_WRCH(0),
          .C_FAMILY(C_FAMILY),
          .C_FULL_FLAGS_RST_VAL(1),
          .C_HAS_ALMOST_EMPTY(0),
          .C_HAS_ALMOST_FULL(0),
          .C_HAS_AXI_ARUSER(C_AXI_SUPPORTS_USER_SIGNALS),
          .C_HAS_AXI_AWUSER(C_AXI_SUPPORTS_USER_SIGNALS),
          .C_HAS_AXI_BUSER(C_AXI_SUPPORTS_USER_SIGNALS),
          .C_HAS_AXI_RD_CHANNEL(C_AXI_SUPPORTS_READ),
          .C_HAS_AXI_RUSER(C_AXI_SUPPORTS_USER_SIGNALS),
          .C_HAS_AXI_WR_CHANNEL(C_AXI_SUPPORTS_WRITE),
          .C_HAS_AXI_WUSER(C_AXI_SUPPORTS_USER_SIGNALS),
          .C_HAS_AXIS_TDATA(0),
          .C_HAS_AXIS_TDEST(0),
          .C_HAS_AXIS_TID(0),
          .C_HAS_AXIS_TKEEP(0),
          .C_HAS_AXIS_TLAST(0),
          .C_HAS_AXIS_TREADY(1),
          .C_HAS_AXIS_TSTRB(0),
          .C_HAS_AXIS_TUSER(0),
          .C_HAS_BACKUP(0),
          .C_HAS_DATA_COUNT(0),
          .C_HAS_DATA_COUNTS_AXIS(0),
          .C_HAS_DATA_COUNTS_RACH(0),
          .C_HAS_DATA_COUNTS_RDCH(0),
          .C_HAS_DATA_COUNTS_WACH(0),
          .C_HAS_DATA_COUNTS_WDCH(0),
          .C_HAS_DATA_COUNTS_WRCH(0),
          .C_HAS_INT_CLK(0),
          .C_HAS_MASTER_CE(0),
          .C_HAS_MEMINIT_FILE(0),
          .C_HAS_OVERFLOW(0),
          .C_HAS_PROG_FLAGS_AXIS(0),
          .C_HAS_PROG_FLAGS_RACH(0),
          .C_HAS_PROG_FLAGS_RDCH(0),
          .C_HAS_PROG_FLAGS_WACH(0),
          .C_HAS_PROG_FLAGS_WDCH(0),
          .C_HAS_PROG_FLAGS_WRCH(0),
          .C_HAS_RD_DATA_COUNT(0),
          .C_HAS_RD_RST(0),
          .C_HAS_RST(1),
          .C_HAS_SLAVE_CE(0),
          .C_HAS_SRST(0),
          .C_HAS_UNDERFLOW(0),
          .C_HAS_VALID(0),
          .C_HAS_WR_ACK(0),
          .C_HAS_WR_DATA_COUNT(0),
          .C_HAS_WR_RST(0),
          .C_IMPLEMENTATION_TYPE(0),
          .C_IMPLEMENTATION_TYPE_AXIS(P_LUTRAM_ASYNC),
          .C_IMPLEMENTATION_TYPE_RACH(P_LUTRAM_ASYNC),
          .C_IMPLEMENTATION_TYPE_RDCH(P_LUTRAM_ASYNC),
          .C_IMPLEMENTATION_TYPE_WACH(P_LUTRAM_ASYNC),
          .C_IMPLEMENTATION_TYPE_WDCH(P_LUTRAM_ASYNC),
          .C_IMPLEMENTATION_TYPE_WRCH(P_LUTRAM_ASYNC),
          .C_INIT_WR_PNTR_VAL(0),
          .C_INTERFACE_TYPE(1),
          .C_MEMORY_TYPE(1),
          .C_MIF_FILE_NAME("BlankString"),
          .C_MSGON_VAL(1),
          .C_OPTIMIZATION_MODE(0),
          .C_OVERFLOW_LOW(0),
          .C_PRELOAD_LATENCY(1),
          .C_PRELOAD_REGS(0),
          .C_PRIM_FIFO_TYPE("4kx4"),
          .C_PROG_EMPTY_THRESH_ASSERT_VAL(2),
          .C_PROG_EMPTY_THRESH_ASSERT_VAL_AXIS(1021),
          .C_PROG_EMPTY_THRESH_ASSERT_VAL_RACH(29),
          .C_PROG_EMPTY_THRESH_ASSERT_VAL_RDCH(29),
          .C_PROG_EMPTY_THRESH_ASSERT_VAL_WACH(29),
          .C_PROG_EMPTY_THRESH_ASSERT_VAL_WDCH(29),
          .C_PROG_EMPTY_THRESH_ASSERT_VAL_WRCH(29),
          .C_PROG_EMPTY_THRESH_NEGATE_VAL(3),
          .C_PROG_EMPTY_TYPE(0),
          .C_PROG_EMPTY_TYPE_AXIS(5),
          .C_PROG_EMPTY_TYPE_RACH(5),
          .C_PROG_EMPTY_TYPE_RDCH(5),
          .C_PROG_EMPTY_TYPE_WACH(5),
          .C_PROG_EMPTY_TYPE_WDCH(5),
          .C_PROG_EMPTY_TYPE_WRCH(5),
          .C_PROG_FULL_THRESH_ASSERT_VAL(1022),
          .C_PROG_FULL_THRESH_ASSERT_VAL_AXIS(1023),
          .C_PROG_FULL_THRESH_ASSERT_VAL_RACH(31),
          .C_PROG_FULL_THRESH_ASSERT_VAL_RDCH(31),
          .C_PROG_FULL_THRESH_ASSERT_VAL_WACH(31),
          .C_PROG_FULL_THRESH_ASSERT_VAL_WDCH(31),
          .C_PROG_FULL_THRESH_ASSERT_VAL_WRCH(31),
          .C_PROG_FULL_THRESH_NEGATE_VAL(1021),
          .C_PROG_FULL_TYPE(0),
          .C_PROG_FULL_TYPE_AXIS(5),
          .C_PROG_FULL_TYPE_RACH(5),
          .C_PROG_FULL_TYPE_RDCH(5),
          .C_PROG_FULL_TYPE_WACH(5),
          .C_PROG_FULL_TYPE_WDCH(5),
          .C_PROG_FULL_TYPE_WRCH(5),
          .C_RACH_TYPE(C_AXI_SUPPORTS_READ ? 0 : 2),
          .C_RD_DATA_COUNT_WIDTH(10),
          .C_RD_DEPTH(1024),
          .C_RD_FREQ(1),
          .C_RD_PNTR_WIDTH(10),
          .C_RDCH_TYPE(C_AXI_SUPPORTS_READ ? 0 : 2),
          .C_REG_SLICE_MODE_AXIS(0),
          .C_REG_SLICE_MODE_RACH(0),
          .C_REG_SLICE_MODE_RDCH(0),
          .C_REG_SLICE_MODE_WACH(0),
          .C_REG_SLICE_MODE_WDCH(0),
          .C_REG_SLICE_MODE_WRCH(0),
          .C_SYNCHRONIZER_STAGE(C_SYNCHRONIZER_STAGE),
          .C_UNDERFLOW_LOW(0),
          .C_USE_COMMON_OVERFLOW(0),
          .C_USE_COMMON_UNDERFLOW(0),
          .C_USE_DEFAULT_SETTINGS(0),
          .C_USE_DOUT_RST(1),
          .C_USE_ECC(0),
          .C_USE_ECC_AXIS(0),
          .C_USE_ECC_RACH(0),
          .C_USE_ECC_RDCH(0),
          .C_USE_ECC_WACH(0),
          .C_USE_ECC_WDCH(0),
          .C_USE_ECC_WRCH(0),
          .C_USE_EMBEDDED_REG(0),
          .C_USE_FIFO16_FLAGS(0),
          .C_USE_FWFT_DATA_COUNT(0),
          .C_VALID_LOW(0),
          .C_WACH_TYPE(C_AXI_SUPPORTS_WRITE ? 0 : 2),
          .C_WDCH_TYPE(C_AXI_SUPPORTS_WRITE ? 0 : 2),
          .C_WR_ACK_LOW(0),
          .C_WR_DATA_COUNT_WIDTH(10),
          .C_WR_DEPTH(1024),
          .C_WR_DEPTH_AXIS(32),
          .C_WR_DEPTH_RACH(32),
          .C_WR_DEPTH_RDCH(32),
          .C_WR_DEPTH_WACH(32),
          .C_WR_DEPTH_WDCH(32),
          .C_WR_DEPTH_WRCH(32),
          .C_WR_FREQ(1),
          .C_WR_PNTR_WIDTH(10),
          .C_WR_PNTR_WIDTH_AXIS(5),
          .C_WR_PNTR_WIDTH_RACH(5),
          .C_WR_PNTR_WIDTH_RDCH(5),
          .C_WR_PNTR_WIDTH_WACH(5),
          .C_WR_PNTR_WIDTH_WDCH(5),
          .C_WR_PNTR_WIDTH_WRCH(5),
          .C_WR_RESPONSE_LATENCY(1),
          .C_WRCH_TYPE(C_AXI_SUPPORTS_WRITE ? 0 : 2)
        )
        asyncfifo_wo (
          .s_aclk         (S_AXI_ACLK),
          .m_aclk         (M_AXI_ACLK),
          .s_aresetn      (async_conv_reset_n),
          .s_axi_awid     (S_AXI_AWID),
          .s_axi_awaddr   (S_AXI_AWADDR),
          .s_axi_awlen    (S_AXI_AWLEN),
          .s_axi_awsize   (S_AXI_AWSIZE),
          .s_axi_awburst  (S_AXI_AWBURST),
          .s_axi_awlock   (S_AXI_AWLOCK),
          .s_axi_awcache  (S_AXI_AWCACHE),
          .s_axi_awprot   (S_AXI_AWPROT),
          .s_axi_awqos    (S_AXI_AWQOS),
          .s_axi_awregion (S_AXI_AWREGION),
          .s_axi_awuser   (S_AXI_AWUSER),
          .s_axi_awvalid  (S_AXI_AWVALID),
          .s_axi_awready  (S_AXI_AWREADY),
          .s_axi_wid      ({C_AXI_ID_WIDTH{1'b0}}),
          .s_axi_wdata    (S_AXI_WDATA),
          .s_axi_wstrb    (S_AXI_WSTRB),
          .s_axi_wlast    (S_AXI_WLAST),
          .s_axi_wuser    (S_AXI_WUSER),
          .s_axi_wvalid   (S_AXI_WVALID),
          .s_axi_wready   (S_AXI_WREADY),
          .s_axi_bid      (S_AXI_BID),
          .s_axi_bresp    (S_AXI_BRESP),
          .s_axi_buser    (S_AXI_BUSER),
          .s_axi_bvalid   (S_AXI_BVALID),
          .s_axi_bready   (S_AXI_BREADY),
          .m_axi_awid     (M_AXI_AWID),
          .m_axi_awaddr   (M_AXI_AWADDR),
          .m_axi_awlen    (M_AXI_AWLEN),
          .m_axi_awsize   (M_AXI_AWSIZE),
          .m_axi_awburst  (M_AXI_AWBURST),
          .m_axi_awlock   (M_AXI_AWLOCK),
          .m_axi_awcache  (M_AXI_AWCACHE),
          .m_axi_awprot   (M_AXI_AWPROT),
          .m_axi_awqos    (M_AXI_AWQOS),
          .m_axi_awregion (M_AXI_AWREGION),
          .m_axi_awuser   (M_AXI_AWUSER),
          .m_axi_awvalid  (M_AXI_AWVALID),
          .m_axi_awready  (M_AXI_AWREADY),
          .m_axi_wid      (),
          .m_axi_wdata    (M_AXI_WDATA),
          .m_axi_wstrb    (M_AXI_WSTRB),
          .m_axi_wlast    (M_AXI_WLAST),
          .m_axi_wuser    (M_AXI_WUSER),
          .m_axi_wvalid   (M_AXI_WVALID),
          .m_axi_wready   (M_AXI_WREADY),
          .m_axi_bid      (M_AXI_BID),
          .m_axi_bresp    (M_AXI_BRESP),
          .m_axi_buser    (M_AXI_BUSER),
          .m_axi_bvalid   (M_AXI_BVALID),
          .m_axi_bready   (M_AXI_BREADY),
          .s_axi_arid     (S_AXI_ARID),
          .s_axi_araddr   (S_AXI_ARADDR),
          .s_axi_arlen    (S_AXI_ARLEN),
          .s_axi_arsize   (S_AXI_ARSIZE),
          .s_axi_arburst  (S_AXI_ARBURST),
          .s_axi_arlock   (S_AXI_ARLOCK),
          .s_axi_arcache  (S_AXI_ARCACHE),
          .s_axi_arprot   (S_AXI_ARPROT),
          .s_axi_arqos    (S_AXI_ARQOS),
          .s_axi_arregion (S_AXI_ARREGION),
          .s_axi_aruser   (S_AXI_ARUSER),
          .s_axi_arvalid  (S_AXI_ARVALID),
          .s_axi_arready  (),
          .s_axi_rid      (),
          .s_axi_rdata    (),
          .s_axi_rresp    (),
          .s_axi_rlast    (),
          .s_axi_ruser    (),
          .s_axi_rvalid   (),
          .s_axi_rready   (S_AXI_RREADY),
          .m_axi_arid     (),
          .m_axi_araddr   (),
          .m_axi_arlen    (),
          .m_axi_arsize   (),
          .m_axi_arburst  (),
          .m_axi_arlock   (),
          .m_axi_arcache  (),
          .m_axi_arprot   (),
          .m_axi_arqos    (),
          .m_axi_arregion (),
          .m_axi_aruser   (),
          .m_axi_arvalid  (),
          .m_axi_arready  (M_AXI_ARREADY),
          .m_axi_rid      (M_AXI_RID),
          .m_axi_rdata    (M_AXI_RDATA),
          .m_axi_rresp    (M_AXI_RRESP),
          .m_axi_rlast    (M_AXI_RLAST),
          .m_axi_ruser    (M_AXI_RUSER),
          .m_axi_rvalid   (M_AXI_RVALID),
          .m_axi_rready   (),
          .m_aclk_en      (1'b1),
          .s_aclk_en      (1'b1),
          .almost_empty(),
          .almost_full(),
          .axis_data_count(),
          .axis_dbiterr(),
          .axis_injectdbiterr(1'b0),
          .axis_injectsbiterr(1'b0),
          .axis_overflow(),
          .axis_prog_empty(),
          .axis_prog_empty_thresh(5'b0),
          .axis_prog_full(),
          .axis_prog_full_thresh(5'b0),
          .axis_rd_data_count(),
          .axis_sbiterr(),
          .axis_underflow(),
          .axis_wr_data_count(),
          .axi_ar_data_count(),
          .axi_ar_dbiterr(),
          .axi_ar_injectdbiterr(1'b0),
          .axi_ar_injectsbiterr(1'b0),
          .axi_ar_overflow(),
          .axi_ar_prog_empty(),
          .axi_ar_prog_empty_thresh(5'b0),
          .axi_ar_prog_full(),
          .axi_ar_prog_full_thresh(5'b0),
          .axi_ar_rd_data_count(),
          .axi_ar_sbiterr(),
          .axi_ar_underflow(),
          .axi_ar_wr_data_count(),
          .axi_aw_data_count(),
          .axi_aw_dbiterr(),
          .axi_aw_injectdbiterr(1'b0),
          .axi_aw_injectsbiterr(1'b0),
          .axi_aw_overflow(),
          .axi_aw_prog_empty(),
          .axi_aw_prog_empty_thresh(5'b0),
          .axi_aw_prog_full(),
          .axi_aw_prog_full_thresh(5'b0),
          .axi_aw_rd_data_count(),
          .axi_aw_sbiterr(),
          .axi_aw_underflow(),
          .axi_aw_wr_data_count(),
          .axi_b_data_count(),
          .axi_b_dbiterr(),
          .axi_b_injectdbiterr(1'b0),
          .axi_b_injectsbiterr(1'b0),
          .axi_b_overflow(),
          .axi_b_prog_empty(),
          .axi_b_prog_empty_thresh(5'b0),
          .axi_b_prog_full(),
          .axi_b_prog_full_thresh(5'b0),
          .axi_b_rd_data_count(),
          .axi_b_sbiterr(),
          .axi_b_underflow(),
          .axi_b_wr_data_count(),
          .axi_r_data_count(),
          .axi_r_dbiterr(),
          .axi_r_injectdbiterr(1'b0),
          .axi_r_injectsbiterr(1'b0),
          .axi_r_overflow(),
          .axi_r_prog_empty(),
          .axi_r_prog_empty_thresh(5'h00),
          .axi_r_prog_full(),
          .axi_r_prog_full_thresh(5'h00),
          .axi_r_rd_data_count(),
          .axi_r_sbiterr(),
          .axi_r_underflow(),
          .axi_r_wr_data_count(),
          .axi_w_data_count(),
          .axi_w_dbiterr(),
          .axi_w_injectdbiterr(1'b0),
          .axi_w_injectsbiterr(1'b0),
          .axi_w_overflow(),
          .axi_w_prog_empty(),
          .axi_w_prog_empty_thresh(5'h00),
          .axi_w_prog_full(),
          .axi_w_prog_full_thresh(5'h00),
          .axi_w_rd_data_count(),
          .axi_w_sbiterr(),
          .axi_w_underflow(),
          .axi_w_wr_data_count(),
          .backup(1'b0),
          .backup_marker(1'b0),
          .clk(1'b0),
          .data_count(),
          .dbiterr(),
          .din(18'b0),
          .dout(),
          .empty(),
          .full(),
          .injectdbiterr(1'b0),
          .injectsbiterr(1'b0),
          .int_clk(1'b0),
          .m_axis_tdata(),
          .m_axis_tdest(),
          .m_axis_tid(),
          .m_axis_tkeep(),
          .m_axis_tlast(),
          .m_axis_tready(1'b0),
          .m_axis_tstrb(),
          .m_axis_tuser(),
          .m_axis_tvalid(),
          .overflow(),
          .prog_empty(),
          .prog_empty_thresh(10'b0),
          .prog_empty_thresh_assert(10'b0),
          .prog_empty_thresh_negate(10'b0),
          .prog_full(),
          .prog_full_thresh(10'b0),
          .prog_full_thresh_assert(10'b0),
          .prog_full_thresh_negate(10'b0),
          .rd_clk(1'b0),
          .rd_data_count(),
          .rd_en(1'b0),
          .rd_rst(1'b0),
          .rst(1'b0),
          .sbiterr(),
          .srst(1'b0),
          .s_axis_tdata(64'b0),
          .s_axis_tdest(4'b0),
          .s_axis_tid(4'b0),
          .s_axis_tkeep(4'b0),
          .s_axis_tlast(1'b0),
          .s_axis_tready(),
          .s_axis_tstrb(4'b0),
          .s_axis_tuser(4'b0),
          .s_axis_tvalid(1'b0),
          .underflow(),
          .valid(),
          .wr_ack(),
          .wr_clk(1'b0),
          .wr_data_count(),
          .wr_en(1'b0),
          .wr_rst(1'b0)
      );
    end else if (C_AXI_IS_ACLK_ASYNC && (C_AXI_SUPPORTS_WRITE == 0)) begin : gen_async_readonly
      // Write address port
      assign M_AXI_AWID     = 0;
      assign M_AXI_AWADDR   = 0;
      assign M_AXI_AWLEN    = 0;
      assign M_AXI_AWSIZE   = 0;
      assign M_AXI_AWBURST  = 0;
      assign M_AXI_AWLOCK   = 0;
      assign M_AXI_AWCACHE  = 0;
      assign M_AXI_AWPROT   = 0;
      assign M_AXI_AWREGION = 0;
      assign M_AXI_AWQOS    = 0;
      assign M_AXI_AWUSER   = 0;
      assign M_AXI_AWVALID  = 1'b0;
      assign S_AXI_AWREADY  = 1'b0;

      // Write Data Port
      assign M_AXI_WDATA    = 0;
      assign M_AXI_WSTRB    = 0;
      assign M_AXI_WLAST    = 0;
      assign M_AXI_WUSER    = 0;
      assign M_AXI_WVALID   = 1'b0;
      assign S_AXI_WREADY   = 1'b0;

      // Write Response Port
      assign S_AXI_BID      = 0;
      assign S_AXI_BRESP    = 0;
      assign S_AXI_BUSER    = 0;
      assign S_AXI_BVALID   = 1'b0;
      assign M_AXI_BREADY   = 1'b0;

        fifo_generator_v10_0 #(
          .C_ADD_NGC_CONSTRAINT(0),
          .C_APPLICATION_TYPE_AXIS(0),
          .C_APPLICATION_TYPE_RACH(0),
          .C_APPLICATION_TYPE_RDCH(0),
          .C_APPLICATION_TYPE_WACH(0),
          .C_APPLICATION_TYPE_WDCH(0),
          .C_APPLICATION_TYPE_WRCH(0),
          .C_AXI_ADDR_WIDTH(C_AXI_ADDR_WIDTH),
          .C_AXI_ARUSER_WIDTH(C_AXI_ARUSER_WIDTH),
          .C_AXI_AWUSER_WIDTH(C_AXI_AWUSER_WIDTH),
          .C_AXI_BUSER_WIDTH(C_AXI_BUSER_WIDTH),
          .C_AXI_DATA_WIDTH(C_AXI_DATA_WIDTH),
          .C_AXI_ID_WIDTH(C_AXI_ID_WIDTH),
          .C_AXI_RUSER_WIDTH(C_AXI_RUSER_WIDTH),
          .C_AXI_TYPE(1),
          .C_AXI_WUSER_WIDTH(C_AXI_WUSER_WIDTH),
          .C_AXIS_TDATA_WIDTH(64),
          .C_AXIS_TDEST_WIDTH(4),
          .C_AXIS_TID_WIDTH(4),
          .C_AXIS_TKEEP_WIDTH(4),
          .C_AXIS_TSTRB_WIDTH(4),
          .C_AXIS_TUSER_WIDTH(4),
          .C_AXIS_TYPE(0),
          .C_COMMON_CLOCK(0),
          .C_COUNT_TYPE(0),
          .C_DATA_COUNT_WIDTH(10),
          .C_DEFAULT_VALUE("BlankString"),
          .C_DIN_WIDTH(18),
          .C_DIN_WIDTH_AXIS(1),
          .C_DIN_WIDTH_RACH(C_AR_SIZE),
          .C_DIN_WIDTH_RDCH(C_R_SIZE),
          .C_DIN_WIDTH_WACH(C_AW_SIZE),
          .C_DIN_WIDTH_WDCH(C_W_FIFOGEN_SIZE),
          .C_DIN_WIDTH_WRCH(C_B_SIZE),
          .C_DOUT_RST_VAL("0"),
          .C_DOUT_WIDTH(18),
          .C_ENABLE_RLOCS(0),
          .C_ENABLE_RST_SYNC(1),
          .C_ERROR_INJECTION_TYPE(0),
          .C_ERROR_INJECTION_TYPE_AXIS(0),
          .C_ERROR_INJECTION_TYPE_RACH(0),
          .C_ERROR_INJECTION_TYPE_RDCH(0),
          .C_ERROR_INJECTION_TYPE_WACH(0),
          .C_ERROR_INJECTION_TYPE_WDCH(0),
          .C_ERROR_INJECTION_TYPE_WRCH(0),
          .C_FAMILY(C_FAMILY),
          .C_FULL_FLAGS_RST_VAL(1),
          .C_HAS_ALMOST_EMPTY(0),
          .C_HAS_ALMOST_FULL(0),
          .C_HAS_AXI_ARUSER(C_AXI_SUPPORTS_USER_SIGNALS),
          .C_HAS_AXI_AWUSER(C_AXI_SUPPORTS_USER_SIGNALS),
          .C_HAS_AXI_BUSER(C_AXI_SUPPORTS_USER_SIGNALS),
          .C_HAS_AXI_RD_CHANNEL(C_AXI_SUPPORTS_READ),
          .C_HAS_AXI_RUSER(C_AXI_SUPPORTS_USER_SIGNALS),
          .C_HAS_AXI_WR_CHANNEL(C_AXI_SUPPORTS_WRITE),
          .C_HAS_AXI_WUSER(C_AXI_SUPPORTS_USER_SIGNALS),
          .C_HAS_AXIS_TDATA(0),
          .C_HAS_AXIS_TDEST(0),
          .C_HAS_AXIS_TID(0),
          .C_HAS_AXIS_TKEEP(0),
          .C_HAS_AXIS_TLAST(0),
          .C_HAS_AXIS_TREADY(1),
          .C_HAS_AXIS_TSTRB(0),
          .C_HAS_AXIS_TUSER(0),
          .C_HAS_BACKUP(0),
          .C_HAS_DATA_COUNT(0),
          .C_HAS_DATA_COUNTS_AXIS(0),
          .C_HAS_DATA_COUNTS_RACH(0),
          .C_HAS_DATA_COUNTS_RDCH(0),
          .C_HAS_DATA_COUNTS_WACH(0),
          .C_HAS_DATA_COUNTS_WDCH(0),
          .C_HAS_DATA_COUNTS_WRCH(0),
          .C_HAS_INT_CLK(0),
          .C_HAS_MASTER_CE(0),
          .C_HAS_MEMINIT_FILE(0),
          .C_HAS_OVERFLOW(0),
          .C_HAS_PROG_FLAGS_AXIS(0),
          .C_HAS_PROG_FLAGS_RACH(0),
          .C_HAS_PROG_FLAGS_RDCH(0),
          .C_HAS_PROG_FLAGS_WACH(0),
          .C_HAS_PROG_FLAGS_WDCH(0),
          .C_HAS_PROG_FLAGS_WRCH(0),
          .C_HAS_RD_DATA_COUNT(0),
          .C_HAS_RD_RST(0),
          .C_HAS_RST(1),
          .C_HAS_SLAVE_CE(0),
          .C_HAS_SRST(0),
          .C_HAS_UNDERFLOW(0),
          .C_HAS_VALID(0),
          .C_HAS_WR_ACK(0),
          .C_HAS_WR_DATA_COUNT(0),
          .C_HAS_WR_RST(0),
          .C_IMPLEMENTATION_TYPE(0),
          .C_IMPLEMENTATION_TYPE_AXIS(P_LUTRAM_ASYNC),
          .C_IMPLEMENTATION_TYPE_RACH(P_LUTRAM_ASYNC),
          .C_IMPLEMENTATION_TYPE_RDCH(P_LUTRAM_ASYNC),
          .C_IMPLEMENTATION_TYPE_WACH(P_LUTRAM_ASYNC),
          .C_IMPLEMENTATION_TYPE_WDCH(P_LUTRAM_ASYNC),
          .C_IMPLEMENTATION_TYPE_WRCH(P_LUTRAM_ASYNC),
          .C_INIT_WR_PNTR_VAL(0),
          .C_INTERFACE_TYPE(1),
          .C_MEMORY_TYPE(1),
          .C_MIF_FILE_NAME("BlankString"),
          .C_MSGON_VAL(1),
          .C_OPTIMIZATION_MODE(0),
          .C_OVERFLOW_LOW(0),
          .C_PRELOAD_LATENCY(1),
          .C_PRELOAD_REGS(0),
          .C_PRIM_FIFO_TYPE("4kx4"),
          .C_PROG_EMPTY_THRESH_ASSERT_VAL(2),
          .C_PROG_EMPTY_THRESH_ASSERT_VAL_AXIS(1021),
          .C_PROG_EMPTY_THRESH_ASSERT_VAL_RACH(29),
          .C_PROG_EMPTY_THRESH_ASSERT_VAL_RDCH(29),
          .C_PROG_EMPTY_THRESH_ASSERT_VAL_WACH(29),
          .C_PROG_EMPTY_THRESH_ASSERT_VAL_WDCH(29),
          .C_PROG_EMPTY_THRESH_ASSERT_VAL_WRCH(29),
          .C_PROG_EMPTY_THRESH_NEGATE_VAL(3),
          .C_PROG_EMPTY_TYPE(0),
          .C_PROG_EMPTY_TYPE_AXIS(5),
          .C_PROG_EMPTY_TYPE_RACH(5),
          .C_PROG_EMPTY_TYPE_RDCH(5),
          .C_PROG_EMPTY_TYPE_WACH(5),
          .C_PROG_EMPTY_TYPE_WDCH(5),
          .C_PROG_EMPTY_TYPE_WRCH(5),
          .C_PROG_FULL_THRESH_ASSERT_VAL(1022),
          .C_PROG_FULL_THRESH_ASSERT_VAL_AXIS(1023),
          .C_PROG_FULL_THRESH_ASSERT_VAL_RACH(31),
          .C_PROG_FULL_THRESH_ASSERT_VAL_RDCH(31),
          .C_PROG_FULL_THRESH_ASSERT_VAL_WACH(31),
          .C_PROG_FULL_THRESH_ASSERT_VAL_WDCH(31),
          .C_PROG_FULL_THRESH_ASSERT_VAL_WRCH(31),
          .C_PROG_FULL_THRESH_NEGATE_VAL(1021),
          .C_PROG_FULL_TYPE(0),
          .C_PROG_FULL_TYPE_AXIS(5),
          .C_PROG_FULL_TYPE_RACH(5),
          .C_PROG_FULL_TYPE_RDCH(5),
          .C_PROG_FULL_TYPE_WACH(5),
          .C_PROG_FULL_TYPE_WDCH(5),
          .C_PROG_FULL_TYPE_WRCH(5),
          .C_RACH_TYPE(C_AXI_SUPPORTS_READ ? 0 : 2),
          .C_RD_DATA_COUNT_WIDTH(10),
          .C_RD_DEPTH(1024),
          .C_RD_FREQ(1),
          .C_RD_PNTR_WIDTH(10),
          .C_RDCH_TYPE(C_AXI_SUPPORTS_READ ? 0 : 2),
          .C_REG_SLICE_MODE_AXIS(0),
          .C_REG_SLICE_MODE_RACH(0),
          .C_REG_SLICE_MODE_RDCH(0),
          .C_REG_SLICE_MODE_WACH(0),
          .C_REG_SLICE_MODE_WDCH(0),
          .C_REG_SLICE_MODE_WRCH(0),
          .C_SYNCHRONIZER_STAGE(C_SYNCHRONIZER_STAGE),
          .C_UNDERFLOW_LOW(0),
          .C_USE_COMMON_OVERFLOW(0),
          .C_USE_COMMON_UNDERFLOW(0),
          .C_USE_DEFAULT_SETTINGS(0),
          .C_USE_DOUT_RST(1),
          .C_USE_ECC(0),
          .C_USE_ECC_AXIS(0),
          .C_USE_ECC_RACH(0),
          .C_USE_ECC_RDCH(0),
          .C_USE_ECC_WACH(0),
          .C_USE_ECC_WDCH(0),
          .C_USE_ECC_WRCH(0),
          .C_USE_EMBEDDED_REG(0),
          .C_USE_FIFO16_FLAGS(0),
          .C_USE_FWFT_DATA_COUNT(0),
          .C_VALID_LOW(0),
          .C_WACH_TYPE(C_AXI_SUPPORTS_WRITE ? 0 : 2),
          .C_WDCH_TYPE(C_AXI_SUPPORTS_WRITE ? 0 : 2),
          .C_WR_ACK_LOW(0),
          .C_WR_DATA_COUNT_WIDTH(10),
          .C_WR_DEPTH(1024),
          .C_WR_DEPTH_AXIS(32),
          .C_WR_DEPTH_RACH(32),
          .C_WR_DEPTH_RDCH(32),
          .C_WR_DEPTH_WACH(32),
          .C_WR_DEPTH_WDCH(32),
          .C_WR_DEPTH_WRCH(32),
          .C_WR_FREQ(1),
          .C_WR_PNTR_WIDTH(10),
          .C_WR_PNTR_WIDTH_AXIS(5),
          .C_WR_PNTR_WIDTH_RACH(5),
          .C_WR_PNTR_WIDTH_RDCH(5),
          .C_WR_PNTR_WIDTH_WACH(5),
          .C_WR_PNTR_WIDTH_WDCH(5),
          .C_WR_PNTR_WIDTH_WRCH(5),
          .C_WR_RESPONSE_LATENCY(1),
          .C_WRCH_TYPE(C_AXI_SUPPORTS_WRITE ? 0 : 2)
        )
        asyncfifo_ro (
          .s_aclk         (S_AXI_ACLK),
          .m_aclk         (M_AXI_ACLK),
          .s_aresetn      (async_conv_reset_n),
          .s_axi_awid     (S_AXI_AWID),
          .s_axi_awaddr   (S_AXI_AWADDR),
          .s_axi_awlen    (S_AXI_AWLEN),
          .s_axi_awsize   (S_AXI_AWSIZE),
          .s_axi_awburst  (S_AXI_AWBURST),
          .s_axi_awlock   (S_AXI_AWLOCK),
          .s_axi_awcache  (S_AXI_AWCACHE),
          .s_axi_awprot   (S_AXI_AWPROT),
          .s_axi_awqos    (S_AXI_AWQOS),
          .s_axi_awregion (S_AXI_AWREGION),
          .s_axi_awuser   (S_AXI_AWUSER),
          .s_axi_awvalid  (S_AXI_AWVALID),
          .s_axi_awready  (),
          .s_axi_wid      ({C_AXI_ID_WIDTH{1'b0}}),
          .s_axi_wdata    (S_AXI_WDATA),
          .s_axi_wstrb    (S_AXI_WSTRB),
          .s_axi_wlast    (S_AXI_WLAST),
          .s_axi_wuser    (S_AXI_WUSER),
          .s_axi_wvalid   (S_AXI_WVALID),
          .s_axi_wready   (),
          .s_axi_bid      (),
          .s_axi_bresp    (),
          .s_axi_buser    (),
          .s_axi_bvalid   (),
          .s_axi_bready   (S_AXI_BREADY),
          .m_axi_awid     (),
          .m_axi_awaddr   (),
          .m_axi_awlen    (),
          .m_axi_awsize   (),
          .m_axi_awburst  (),
          .m_axi_awlock   (),
          .m_axi_awcache  (),
          .m_axi_awprot   (),
          .m_axi_awqos    (),
          .m_axi_awregion (),
          .m_axi_awuser   (),
          .m_axi_awvalid  (),
          .m_axi_awready  (M_AXI_AWREADY),
          .m_axi_wid      (),
          .m_axi_wdata    (),
          .m_axi_wstrb    (),
          .m_axi_wlast    (),
          .m_axi_wuser    (),
          .m_axi_wvalid   (),
          .m_axi_wready   (M_AXI_WREADY),
          .m_axi_bid      (M_AXI_BID),
          .m_axi_bresp    (M_AXI_BRESP),
          .m_axi_buser    (M_AXI_BUSER),
          .m_axi_bvalid   (M_AXI_BVALID),
          .m_axi_bready   (),
          .s_axi_arid     (S_AXI_ARID),
          .s_axi_araddr   (S_AXI_ARADDR),
          .s_axi_arlen    (S_AXI_ARLEN),
          .s_axi_arsize   (S_AXI_ARSIZE),
          .s_axi_arburst  (S_AXI_ARBURST),
          .s_axi_arlock   (S_AXI_ARLOCK),
          .s_axi_arcache  (S_AXI_ARCACHE),
          .s_axi_arprot   (S_AXI_ARPROT),
          .s_axi_arqos    (S_AXI_ARQOS),
          .s_axi_arregion (S_AXI_ARREGION),
          .s_axi_aruser   (S_AXI_ARUSER),
          .s_axi_arvalid  (S_AXI_ARVALID),
          .s_axi_arready  (S_AXI_ARREADY),
          .s_axi_rid      (S_AXI_RID),
          .s_axi_rdata    (S_AXI_RDATA),
          .s_axi_rresp    (S_AXI_RRESP),
          .s_axi_rlast    (S_AXI_RLAST),
          .s_axi_ruser    (S_AXI_RUSER),
          .s_axi_rvalid   (S_AXI_RVALID),
          .s_axi_rready   (S_AXI_RREADY),
          .m_axi_arid     (M_AXI_ARID),
          .m_axi_araddr   (M_AXI_ARADDR),
          .m_axi_arlen    (M_AXI_ARLEN),
          .m_axi_arsize   (M_AXI_ARSIZE),
          .m_axi_arburst  (M_AXI_ARBURST),
          .m_axi_arlock   (M_AXI_ARLOCK),
          .m_axi_arcache  (M_AXI_ARCACHE),
          .m_axi_arprot   (M_AXI_ARPROT),
          .m_axi_arqos    (M_AXI_ARQOS),
          .m_axi_arregion (M_AXI_ARREGION),
          .m_axi_aruser   (M_AXI_ARUSER),
          .m_axi_arvalid  (M_AXI_ARVALID),
          .m_axi_arready  (M_AXI_ARREADY),
          .m_axi_rid      (M_AXI_RID),
          .m_axi_rdata    (M_AXI_RDATA),
          .m_axi_rresp    (M_AXI_RRESP),
          .m_axi_rlast    (M_AXI_RLAST),
          .m_axi_ruser    (M_AXI_RUSER),
          .m_axi_rvalid   (M_AXI_RVALID),
          .m_axi_rready   (M_AXI_RREADY),
          .m_aclk_en      (1'b1),
          .s_aclk_en      (1'b1),
          .almost_empty(),
          .almost_full(),
          .axis_data_count(),
          .axis_dbiterr(),
          .axis_injectdbiterr(1'b0),
          .axis_injectsbiterr(1'b0),
          .axis_overflow(),
          .axis_prog_empty(),
          .axis_prog_empty_thresh(5'b0),
          .axis_prog_full(),
          .axis_prog_full_thresh(5'b0),
          .axis_rd_data_count(),
          .axis_sbiterr(),
          .axis_underflow(),
          .axis_wr_data_count(),
          .axi_ar_data_count(),
          .axi_ar_dbiterr(),
          .axi_ar_injectdbiterr(1'b0),
          .axi_ar_injectsbiterr(1'b0),
          .axi_ar_overflow(),
          .axi_ar_prog_empty(),
          .axi_ar_prog_empty_thresh(5'b0),
          .axi_ar_prog_full(),
          .axi_ar_prog_full_thresh(5'b0),
          .axi_ar_rd_data_count(),
          .axi_ar_sbiterr(),
          .axi_ar_underflow(),
          .axi_ar_wr_data_count(),
          .axi_aw_data_count(),
          .axi_aw_dbiterr(),
          .axi_aw_injectdbiterr(1'b0),
          .axi_aw_injectsbiterr(1'b0),
          .axi_aw_overflow(),
          .axi_aw_prog_empty(),
          .axi_aw_prog_empty_thresh(5'b0),
          .axi_aw_prog_full(),
          .axi_aw_prog_full_thresh(5'b0),
          .axi_aw_rd_data_count(),
          .axi_aw_sbiterr(),
          .axi_aw_underflow(),
          .axi_aw_wr_data_count(),
          .axi_b_data_count(),
          .axi_b_dbiterr(),
          .axi_b_injectdbiterr(1'b0),
          .axi_b_injectsbiterr(1'b0),
          .axi_b_overflow(),
          .axi_b_prog_empty(),
          .axi_b_prog_empty_thresh(5'b0),
          .axi_b_prog_full(),
          .axi_b_prog_full_thresh(5'b0),
          .axi_b_rd_data_count(),
          .axi_b_sbiterr(),
          .axi_b_underflow(),
          .axi_b_wr_data_count(),
          .axi_r_data_count(),
          .axi_r_dbiterr(),
          .axi_r_injectdbiterr(1'b0),
          .axi_r_injectsbiterr(1'b0),
          .axi_r_overflow(),
          .axi_r_prog_empty(),
          .axi_r_prog_empty_thresh(5'h00),
          .axi_r_prog_full(),
          .axi_r_prog_full_thresh(5'h00),
          .axi_r_rd_data_count(),
          .axi_r_sbiterr(),
          .axi_r_underflow(),
          .axi_r_wr_data_count(),
          .axi_w_data_count(),
          .axi_w_dbiterr(),
          .axi_w_injectdbiterr(1'b0),
          .axi_w_injectsbiterr(1'b0),
          .axi_w_overflow(),
          .axi_w_prog_empty(),
          .axi_w_prog_empty_thresh(5'h00),
          .axi_w_prog_full(),
          .axi_w_prog_full_thresh(5'h00),
          .axi_w_rd_data_count(),
          .axi_w_sbiterr(),
          .axi_w_underflow(),
          .axi_w_wr_data_count(),
          .backup(1'b0),
          .backup_marker(1'b0),
          .clk(1'b0),
          .data_count(),
          .dbiterr(),
          .din(18'b0),
          .dout(),
          .empty(),
          .full(),
          .injectdbiterr(1'b0),
          .injectsbiterr(1'b0),
          .int_clk(1'b0),
          .m_axis_tdata(),
          .m_axis_tdest(),
          .m_axis_tid(),
          .m_axis_tkeep(),
          .m_axis_tlast(),
          .m_axis_tready(1'b0),
          .m_axis_tstrb(),
          .m_axis_tuser(),
          .m_axis_tvalid(),
          .overflow(),
          .prog_empty(),
          .prog_empty_thresh(10'b0),
          .prog_empty_thresh_assert(10'b0),
          .prog_empty_thresh_negate(10'b0),
          .prog_full(),
          .prog_full_thresh(10'b0),
          .prog_full_thresh_assert(10'b0),
          .prog_full_thresh_negate(10'b0),
          .rd_clk(1'b0),
          .rd_data_count(),
          .rd_en(1'b0),
          .rd_rst(1'b0),
          .rst(1'b0),
          .sbiterr(),
          .srst(1'b0),
          .s_axis_tdata(64'b0),
          .s_axis_tdest(4'b0),
          .s_axis_tid(4'b0),
          .s_axis_tkeep(4'b0),
          .s_axis_tlast(1'b0),
          .s_axis_tready(),
          .s_axis_tstrb(4'b0),
          .s_axis_tuser(4'b0),
          .s_axis_tvalid(1'b0),
          .underflow(),
          .valid(),
          .wr_ack(),
          .wr_clk(1'b0),
          .wr_data_count(),
          .wr_en(1'b0),
          .wr_rst(1'b0)
      );
    end else if (C_AXI_IS_ACLK_ASYNC) begin : gen_async_readwrite
      fifo_generator_v10_0 #(
          .C_ADD_NGC_CONSTRAINT(0),
          .C_APPLICATION_TYPE_AXIS(0),
          .C_APPLICATION_TYPE_RACH(0),
          .C_APPLICATION_TYPE_RDCH(0),
          .C_APPLICATION_TYPE_WACH(0),
          .C_APPLICATION_TYPE_WDCH(0),
          .C_APPLICATION_TYPE_WRCH(0),
          .C_AXI_ADDR_WIDTH(C_AXI_ADDR_WIDTH),
          .C_AXI_ARUSER_WIDTH(C_AXI_ARUSER_WIDTH),
          .C_AXI_AWUSER_WIDTH(C_AXI_AWUSER_WIDTH),
          .C_AXI_BUSER_WIDTH(C_AXI_BUSER_WIDTH),
          .C_AXI_DATA_WIDTH(C_AXI_DATA_WIDTH),
          .C_AXI_ID_WIDTH(C_AXI_ID_WIDTH),
          .C_AXI_RUSER_WIDTH(C_AXI_RUSER_WIDTH),
          .C_AXI_TYPE(1),
          .C_AXI_WUSER_WIDTH(C_AXI_WUSER_WIDTH),
          .C_AXIS_TDATA_WIDTH(64),
          .C_AXIS_TDEST_WIDTH(4),
          .C_AXIS_TID_WIDTH(4),
          .C_AXIS_TKEEP_WIDTH(4),
          .C_AXIS_TSTRB_WIDTH(4),
          .C_AXIS_TUSER_WIDTH(4),
          .C_AXIS_TYPE(0),
          .C_COMMON_CLOCK(0),
          .C_COUNT_TYPE(0),
          .C_DATA_COUNT_WIDTH(10),
          .C_DEFAULT_VALUE("BlankString"),
          .C_DIN_WIDTH(18),
          .C_DIN_WIDTH_AXIS(1),
          .C_DIN_WIDTH_RACH(C_AR_SIZE),
          .C_DIN_WIDTH_RDCH(C_R_SIZE),
          .C_DIN_WIDTH_WACH(C_AW_SIZE),
          .C_DIN_WIDTH_WDCH(C_W_FIFOGEN_SIZE),
          .C_DIN_WIDTH_WRCH(C_B_SIZE),
          .C_DOUT_RST_VAL("0"),
          .C_DOUT_WIDTH(18),
          .C_ENABLE_RLOCS(0),
          .C_ENABLE_RST_SYNC(1),
          .C_ERROR_INJECTION_TYPE(0),
          .C_ERROR_INJECTION_TYPE_AXIS(0),
          .C_ERROR_INJECTION_TYPE_RACH(0),
          .C_ERROR_INJECTION_TYPE_RDCH(0),
          .C_ERROR_INJECTION_TYPE_WACH(0),
          .C_ERROR_INJECTION_TYPE_WDCH(0),
          .C_ERROR_INJECTION_TYPE_WRCH(0),
          .C_FAMILY(C_FAMILY),
          .C_FULL_FLAGS_RST_VAL(1),
          .C_HAS_ALMOST_EMPTY(0),
          .C_HAS_ALMOST_FULL(0),
          .C_HAS_AXI_ARUSER(C_AXI_SUPPORTS_USER_SIGNALS),
          .C_HAS_AXI_AWUSER(C_AXI_SUPPORTS_USER_SIGNALS),
          .C_HAS_AXI_BUSER(C_AXI_SUPPORTS_USER_SIGNALS),
          .C_HAS_AXI_RD_CHANNEL(C_AXI_SUPPORTS_READ),
          .C_HAS_AXI_RUSER(C_AXI_SUPPORTS_USER_SIGNALS),
          .C_HAS_AXI_WR_CHANNEL(C_AXI_SUPPORTS_WRITE),
          .C_HAS_AXI_WUSER(C_AXI_SUPPORTS_USER_SIGNALS),
          .C_HAS_AXIS_TDATA(0),
          .C_HAS_AXIS_TDEST(0),
          .C_HAS_AXIS_TID(0),
          .C_HAS_AXIS_TKEEP(0),
          .C_HAS_AXIS_TLAST(0),
          .C_HAS_AXIS_TREADY(1),
          .C_HAS_AXIS_TSTRB(0),
          .C_HAS_AXIS_TUSER(0),
          .C_HAS_BACKUP(0),
          .C_HAS_DATA_COUNT(0),
          .C_HAS_DATA_COUNTS_AXIS(0),
          .C_HAS_DATA_COUNTS_RACH(0),
          .C_HAS_DATA_COUNTS_RDCH(0),
          .C_HAS_DATA_COUNTS_WACH(0),
          .C_HAS_DATA_COUNTS_WDCH(0),
          .C_HAS_DATA_COUNTS_WRCH(0),
          .C_HAS_INT_CLK(0),
          .C_HAS_MASTER_CE(0),
          .C_HAS_MEMINIT_FILE(0),
          .C_HAS_OVERFLOW(0),
          .C_HAS_PROG_FLAGS_AXIS(0),
          .C_HAS_PROG_FLAGS_RACH(0),
          .C_HAS_PROG_FLAGS_RDCH(0),
          .C_HAS_PROG_FLAGS_WACH(0),
          .C_HAS_PROG_FLAGS_WDCH(0),
          .C_HAS_PROG_FLAGS_WRCH(0),
          .C_HAS_RD_DATA_COUNT(0),
          .C_HAS_RD_RST(0),
          .C_HAS_RST(1),
          .C_HAS_SLAVE_CE(0),
          .C_HAS_SRST(0),
          .C_HAS_UNDERFLOW(0),
          .C_HAS_VALID(0),
          .C_HAS_WR_ACK(0),
          .C_HAS_WR_DATA_COUNT(0),
          .C_HAS_WR_RST(0),
          .C_IMPLEMENTATION_TYPE(0),
          .C_IMPLEMENTATION_TYPE_AXIS(P_LUTRAM_ASYNC),
          .C_IMPLEMENTATION_TYPE_RACH(P_LUTRAM_ASYNC),
          .C_IMPLEMENTATION_TYPE_RDCH(P_LUTRAM_ASYNC),
          .C_IMPLEMENTATION_TYPE_WACH(P_LUTRAM_ASYNC),
          .C_IMPLEMENTATION_TYPE_WDCH(P_LUTRAM_ASYNC),
          .C_IMPLEMENTATION_TYPE_WRCH(P_LUTRAM_ASYNC),
          .C_INIT_WR_PNTR_VAL(0),
          .C_INTERFACE_TYPE(1),
          .C_MEMORY_TYPE(1),
          .C_MIF_FILE_NAME("BlankString"),
          .C_MSGON_VAL(1),
          .C_OPTIMIZATION_MODE(0),
          .C_OVERFLOW_LOW(0),
          .C_PRELOAD_LATENCY(1),
          .C_PRELOAD_REGS(0),
          .C_PRIM_FIFO_TYPE("4kx4"),
          .C_PROG_EMPTY_THRESH_ASSERT_VAL(2),
          .C_PROG_EMPTY_THRESH_ASSERT_VAL_AXIS(1021),
          .C_PROG_EMPTY_THRESH_ASSERT_VAL_RACH(29),
          .C_PROG_EMPTY_THRESH_ASSERT_VAL_RDCH(29),
          .C_PROG_EMPTY_THRESH_ASSERT_VAL_WACH(29),
          .C_PROG_EMPTY_THRESH_ASSERT_VAL_WDCH(29),
          .C_PROG_EMPTY_THRESH_ASSERT_VAL_WRCH(29),
          .C_PROG_EMPTY_THRESH_NEGATE_VAL(3),
          .C_PROG_EMPTY_TYPE(0),
          .C_PROG_EMPTY_TYPE_AXIS(5),
          .C_PROG_EMPTY_TYPE_RACH(5),
          .C_PROG_EMPTY_TYPE_RDCH(5),
          .C_PROG_EMPTY_TYPE_WACH(5),
          .C_PROG_EMPTY_TYPE_WDCH(5),
          .C_PROG_EMPTY_TYPE_WRCH(5),
          .C_PROG_FULL_THRESH_ASSERT_VAL(1022),
          .C_PROG_FULL_THRESH_ASSERT_VAL_AXIS(1023),
          .C_PROG_FULL_THRESH_ASSERT_VAL_RACH(31),
          .C_PROG_FULL_THRESH_ASSERT_VAL_RDCH(31),
          .C_PROG_FULL_THRESH_ASSERT_VAL_WACH(31),
          .C_PROG_FULL_THRESH_ASSERT_VAL_WDCH(31),
          .C_PROG_FULL_THRESH_ASSERT_VAL_WRCH(31),
          .C_PROG_FULL_THRESH_NEGATE_VAL(1021),
          .C_PROG_FULL_TYPE(0),
          .C_PROG_FULL_TYPE_AXIS(5),
          .C_PROG_FULL_TYPE_RACH(5),
          .C_PROG_FULL_TYPE_RDCH(5),
          .C_PROG_FULL_TYPE_WACH(5),
          .C_PROG_FULL_TYPE_WDCH(5),
          .C_PROG_FULL_TYPE_WRCH(5),
          .C_RACH_TYPE(C_AXI_SUPPORTS_READ ? 0 : 2),
          .C_RD_DATA_COUNT_WIDTH(10),
          .C_RD_DEPTH(1024),
          .C_RD_FREQ(1),
          .C_RD_PNTR_WIDTH(10),
          .C_RDCH_TYPE(C_AXI_SUPPORTS_READ ? 0 : 2),
          .C_REG_SLICE_MODE_AXIS(0),
          .C_REG_SLICE_MODE_RACH(0),
          .C_REG_SLICE_MODE_RDCH(0),
          .C_REG_SLICE_MODE_WACH(0),
          .C_REG_SLICE_MODE_WDCH(0),
          .C_REG_SLICE_MODE_WRCH(0),
          .C_SYNCHRONIZER_STAGE(C_SYNCHRONIZER_STAGE),
          .C_UNDERFLOW_LOW(0),
          .C_USE_COMMON_OVERFLOW(0),
          .C_USE_COMMON_UNDERFLOW(0),
          .C_USE_DEFAULT_SETTINGS(0),
          .C_USE_DOUT_RST(1),
          .C_USE_ECC(0),
          .C_USE_ECC_AXIS(0),
          .C_USE_ECC_RACH(0),
          .C_USE_ECC_RDCH(0),
          .C_USE_ECC_WACH(0),
          .C_USE_ECC_WDCH(0),
          .C_USE_ECC_WRCH(0),
          .C_USE_EMBEDDED_REG(0),
          .C_USE_FIFO16_FLAGS(0),
          .C_USE_FWFT_DATA_COUNT(0),
          .C_VALID_LOW(0),
          .C_WACH_TYPE(C_AXI_SUPPORTS_WRITE ? 0 : 2),
          .C_WDCH_TYPE(C_AXI_SUPPORTS_WRITE ? 0 : 2),
          .C_WR_ACK_LOW(0),
          .C_WR_DATA_COUNT_WIDTH(10),
          .C_WR_DEPTH(1024),
          .C_WR_DEPTH_AXIS(32),
          .C_WR_DEPTH_RACH(32),
          .C_WR_DEPTH_RDCH(32),
          .C_WR_DEPTH_WACH(32),
          .C_WR_DEPTH_WDCH(32),
          .C_WR_DEPTH_WRCH(32),
          .C_WR_FREQ(1),
          .C_WR_PNTR_WIDTH(10),
          .C_WR_PNTR_WIDTH_AXIS(5),
          .C_WR_PNTR_WIDTH_RACH(5),
          .C_WR_PNTR_WIDTH_RDCH(5),
          .C_WR_PNTR_WIDTH_WACH(5),
          .C_WR_PNTR_WIDTH_WDCH(5),
          .C_WR_PNTR_WIDTH_WRCH(5),
          .C_WR_RESPONSE_LATENCY(1),
          .C_WRCH_TYPE(C_AXI_SUPPORTS_WRITE ? 0 : 2)
        )
        asyncfifo_rw (
          .s_aclk         (S_AXI_ACLK),
          .m_aclk         (M_AXI_ACLK),
          .s_aresetn      (async_conv_reset_n),
          .s_axi_awid     (S_AXI_AWID),
          .s_axi_awaddr   (S_AXI_AWADDR),
          .s_axi_awlen    (S_AXI_AWLEN),
          .s_axi_awsize   (S_AXI_AWSIZE),
          .s_axi_awburst  (S_AXI_AWBURST),
          .s_axi_awlock   (S_AXI_AWLOCK),
          .s_axi_awcache  (S_AXI_AWCACHE),
          .s_axi_awprot   (S_AXI_AWPROT),
          .s_axi_awqos    (S_AXI_AWQOS),
          .s_axi_awregion (S_AXI_AWREGION),
          .s_axi_awuser   (S_AXI_AWUSER),
          .s_axi_awvalid  (S_AXI_AWVALID),
          .s_axi_awready  (S_AXI_AWREADY),
          .s_axi_wid      ({C_AXI_ID_WIDTH{1'b0}}),
          .s_axi_wdata    (S_AXI_WDATA),
          .s_axi_wstrb    (S_AXI_WSTRB),
          .s_axi_wlast    (S_AXI_WLAST),
          .s_axi_wuser    (S_AXI_WUSER),
          .s_axi_wvalid   (S_AXI_WVALID),
          .s_axi_wready   (S_AXI_WREADY),
          .s_axi_bid      (S_AXI_BID),
          .s_axi_bresp    (S_AXI_BRESP),
          .s_axi_buser    (S_AXI_BUSER),
          .s_axi_bvalid   (S_AXI_BVALID),
          .s_axi_bready   (S_AXI_BREADY),
          .m_axi_awid     (M_AXI_AWID),
          .m_axi_awaddr   (M_AXI_AWADDR),
          .m_axi_awlen    (M_AXI_AWLEN),
          .m_axi_awsize   (M_AXI_AWSIZE),
          .m_axi_awburst  (M_AXI_AWBURST),
          .m_axi_awlock   (M_AXI_AWLOCK),
          .m_axi_awcache  (M_AXI_AWCACHE),
          .m_axi_awprot   (M_AXI_AWPROT),
          .m_axi_awqos    (M_AXI_AWQOS),
          .m_axi_awregion (M_AXI_AWREGION),
          .m_axi_awuser   (M_AXI_AWUSER),
          .m_axi_awvalid  (M_AXI_AWVALID),
          .m_axi_awready  (M_AXI_AWREADY),
          .m_axi_wid      (),
          .m_axi_wdata    (M_AXI_WDATA),
          .m_axi_wstrb    (M_AXI_WSTRB),
          .m_axi_wlast    (M_AXI_WLAST),
          .m_axi_wuser    (M_AXI_WUSER),
          .m_axi_wvalid   (M_AXI_WVALID),
          .m_axi_wready   (M_AXI_WREADY),
          .m_axi_bid      (M_AXI_BID),
          .m_axi_bresp    (M_AXI_BRESP),
          .m_axi_buser    (M_AXI_BUSER),
          .m_axi_bvalid   (M_AXI_BVALID),
          .m_axi_bready   (M_AXI_BREADY),
          .s_axi_arid     (S_AXI_ARID),
          .s_axi_araddr   (S_AXI_ARADDR),
          .s_axi_arlen    (S_AXI_ARLEN),
          .s_axi_arsize   (S_AXI_ARSIZE),
          .s_axi_arburst  (S_AXI_ARBURST),
          .s_axi_arlock   (S_AXI_ARLOCK),
          .s_axi_arcache  (S_AXI_ARCACHE),
          .s_axi_arprot   (S_AXI_ARPROT),
          .s_axi_arqos    (S_AXI_ARQOS),
          .s_axi_arregion (S_AXI_ARREGION),
          .s_axi_aruser   (S_AXI_ARUSER),
          .s_axi_arvalid  (S_AXI_ARVALID),
          .s_axi_arready  (S_AXI_ARREADY),
          .s_axi_rid      (S_AXI_RID),
          .s_axi_rdata    (S_AXI_RDATA),
          .s_axi_rresp    (S_AXI_RRESP),
          .s_axi_rlast    (S_AXI_RLAST),
          .s_axi_ruser    (S_AXI_RUSER),
          .s_axi_rvalid   (S_AXI_RVALID),
          .s_axi_rready   (S_AXI_RREADY),
          .m_axi_arid     (M_AXI_ARID),
          .m_axi_araddr   (M_AXI_ARADDR),
          .m_axi_arlen    (M_AXI_ARLEN),
          .m_axi_arsize   (M_AXI_ARSIZE),
          .m_axi_arburst  (M_AXI_ARBURST),
          .m_axi_arlock   (M_AXI_ARLOCK),
          .m_axi_arcache  (M_AXI_ARCACHE),
          .m_axi_arprot   (M_AXI_ARPROT),
          .m_axi_arqos    (M_AXI_ARQOS),
          .m_axi_arregion (M_AXI_ARREGION),
          .m_axi_aruser   (M_AXI_ARUSER),
          .m_axi_arvalid  (M_AXI_ARVALID),
          .m_axi_arready  (M_AXI_ARREADY),
          .m_axi_rid      (M_AXI_RID),
          .m_axi_rdata    (M_AXI_RDATA),
          .m_axi_rresp    (M_AXI_RRESP),
          .m_axi_rlast    (M_AXI_RLAST),
          .m_axi_ruser    (M_AXI_RUSER),
          .m_axi_rvalid   (M_AXI_RVALID),
          .m_axi_rready   (M_AXI_RREADY),
          .m_aclk_en      (1'b1),
          .s_aclk_en      (1'b1),
          .almost_empty(),
          .almost_full(),
          .axis_data_count(),
          .axis_dbiterr(),
          .axis_injectdbiterr(1'b0),
          .axis_injectsbiterr(1'b0),
          .axis_overflow(),
          .axis_prog_empty(),
          .axis_prog_empty_thresh(5'b0),
          .axis_prog_full(),
          .axis_prog_full_thresh(5'b0),
          .axis_rd_data_count(),
          .axis_sbiterr(),
          .axis_underflow(),
          .axis_wr_data_count(),
          .axi_ar_data_count(),
          .axi_ar_dbiterr(),
          .axi_ar_injectdbiterr(1'b0),
          .axi_ar_injectsbiterr(1'b0),
          .axi_ar_overflow(),
          .axi_ar_prog_empty(),
          .axi_ar_prog_empty_thresh(5'b0),
          .axi_ar_prog_full(),
          .axi_ar_prog_full_thresh(5'b0),
          .axi_ar_rd_data_count(),
          .axi_ar_sbiterr(),
          .axi_ar_underflow(),
          .axi_ar_wr_data_count(),
          .axi_aw_data_count(),
          .axi_aw_dbiterr(),
          .axi_aw_injectdbiterr(1'b0),
          .axi_aw_injectsbiterr(1'b0),
          .axi_aw_overflow(),
          .axi_aw_prog_empty(),
          .axi_aw_prog_empty_thresh(5'b0),
          .axi_aw_prog_full(),
          .axi_aw_prog_full_thresh(5'b0),
          .axi_aw_rd_data_count(),
          .axi_aw_sbiterr(),
          .axi_aw_underflow(),
          .axi_aw_wr_data_count(),
          .axi_b_data_count(),
          .axi_b_dbiterr(),
          .axi_b_injectdbiterr(1'b0),
          .axi_b_injectsbiterr(1'b0),
          .axi_b_overflow(),
          .axi_b_prog_empty(),
          .axi_b_prog_empty_thresh(5'b0),
          .axi_b_prog_full(),
          .axi_b_prog_full_thresh(5'b0),
          .axi_b_rd_data_count(),
          .axi_b_sbiterr(),
          .axi_b_underflow(),
          .axi_b_wr_data_count(),
          .axi_r_data_count(),
          .axi_r_dbiterr(),
          .axi_r_injectdbiterr(1'b0),
          .axi_r_injectsbiterr(1'b0),
          .axi_r_overflow(),
          .axi_r_prog_empty(),
          .axi_r_prog_empty_thresh(5'h00),
          .axi_r_prog_full(),
          .axi_r_prog_full_thresh(5'h00),
          .axi_r_rd_data_count(),
          .axi_r_sbiterr(),
          .axi_r_underflow(),
          .axi_r_wr_data_count(),
          .axi_w_data_count(),
          .axi_w_dbiterr(),
          .axi_w_injectdbiterr(1'b0),
          .axi_w_injectsbiterr(1'b0),
          .axi_w_overflow(),
          .axi_w_prog_empty(),
          .axi_w_prog_empty_thresh(5'h00),
          .axi_w_prog_full(),
          .axi_w_prog_full_thresh(5'h00),
          .axi_w_rd_data_count(),
          .axi_w_sbiterr(),
          .axi_w_underflow(),
          .axi_w_wr_data_count(),
          .backup(1'b0),
          .backup_marker(1'b0),
          .clk(1'b0),
          .data_count(),
          .dbiterr(),
          .din(18'b0),
          .dout(),
          .empty(),
          .full(),
          .injectdbiterr(1'b0),
          .injectsbiterr(1'b0),
          .int_clk(1'b0),
          .m_axis_tdata(),
          .m_axis_tdest(),
          .m_axis_tid(),
          .m_axis_tkeep(),
          .m_axis_tlast(),
          .m_axis_tready(1'b0),
          .m_axis_tstrb(),
          .m_axis_tuser(),
          .m_axis_tvalid(),
          .overflow(),
          .prog_empty(),
          .prog_empty_thresh(10'b0),
          .prog_empty_thresh_assert(10'b0),
          .prog_empty_thresh_negate(10'b0),
          .prog_full(),
          .prog_full_thresh(10'b0),
          .prog_full_thresh_assert(10'b0),
          .prog_full_thresh_negate(10'b0),
          .rd_clk(1'b0),
          .rd_data_count(),
          .rd_en(1'b0),
          .rd_rst(1'b0),
          .rst(1'b0),
          .sbiterr(),
          .srst(1'b0),
          .s_axis_tdata(64'b0),
          .s_axis_tdest(4'b0),
          .s_axis_tid(4'b0),
          .s_axis_tkeep(4'b0),
          .s_axis_tlast(1'b0),
          .s_axis_tready(),
          .s_axis_tstrb(4'b0),
          .s_axis_tuser(4'b0),
          .s_axis_tvalid(1'b0),
          .underflow(),
          .valid(),
          .wr_ack(),
          .wr_clk(1'b0),
          .wr_data_count(),
          .wr_en(1'b0),
          .wr_rst(1'b0)
      );
  end else if (P_ACLK_RATIO > 1) begin : gen_sync_conv
    assign {fast_aclk, slow_aclk} = P_SI_LT_MI ? {M_AXI_ACLK, S_AXI_ACLK} : {S_AXI_ACLK, M_AXI_ACLK};
    assign {fast_areset, slow_areset} = P_SI_LT_MI ? {m_axi_reset_out_i, s_axi_reset_out_i} : {s_axi_reset_out_i, m_axi_reset_out_i};

    // Sample cycle used to determine when to assert a signal on a fast clock
    // to be flopped onto a slow clock.
    axi_interconnect_v1_7_axic_sample_cycle_ratio #(
      .C_RATIO ( P_ACLK_RATIO )
    ) 
    axic_sample_cycle_inst (
      .SLOW_ACLK          ( slow_aclk               ) ,
      .FAST_ACLK          ( fast_aclk               ) ,
      .SAMPLE_CYCLE_EARLY ( sample_cycle_early ) ,
      .SAMPLE_CYCLE       ( sample_cycle       ) 
    );

  ////////////////////////////////////////////////////////////////////////////////
  // AXI write channels
  ////////////////////////////////////////////////////////////////////////////////
    if (C_AXI_SUPPORTS_WRITE) begin : gen_conv_write_ch

      // Write Address Port
      if (C_AXI_SUPPORTS_USER_SIGNALS == 1) begin : gen_aw_user
        assign s_aw_data    = {S_AXI_AWID, S_AXI_AWADDR, S_AXI_AWLEN, S_AXI_AWSIZE, 
                               S_AXI_AWBURST, S_AXI_AWLOCK, S_AXI_AWCACHE, S_AXI_AWPROT, 
                               S_AXI_AWREGION, S_AXI_AWQOS, S_AXI_AWUSER};
        assign M_AXI_AWUSER = m_aw_data[C_AWUSER_RIGHT+:C_AWUSER_LEN];
      end
      else begin : gen_aw_no_user
        assign s_aw_data    = {S_AXI_AWID, S_AXI_AWADDR, S_AXI_AWLEN, S_AXI_AWSIZE, 
                               S_AXI_AWBURST, S_AXI_AWLOCK, S_AXI_AWCACHE, S_AXI_AWPROT, 
                               S_AXI_AWREGION, S_AXI_AWQOS};
        assign M_AXI_AWUSER = {C_AXI_AWUSER_WIDTH{1'b0}};
      end

      assign M_AXI_AWID     = m_aw_data[C_AWID_RIGHT+:C_AWID_LEN];
      assign M_AXI_AWADDR   = m_aw_data[C_AWADDR_RIGHT+:C_AWADDR_LEN];
      assign M_AXI_AWLEN    = m_aw_data[C_AWLEN_RIGHT+:C_AWLEN_LEN];
      assign M_AXI_AWSIZE   = m_aw_data[C_AWSIZE_RIGHT+:C_AWSIZE_LEN];
      assign M_AXI_AWBURST  = m_aw_data[C_AWBURST_RIGHT+:C_AWBURST_LEN];
      assign M_AXI_AWLOCK   = m_aw_data[C_AWLOCK_RIGHT+:C_AWLOCK_LEN];
      assign M_AXI_AWCACHE  = m_aw_data[C_AWCACHE_RIGHT+:C_AWCACHE_LEN];
      assign M_AXI_AWPROT   = m_aw_data[C_AWPROT_RIGHT+:C_AWPROT_LEN];
      assign M_AXI_AWREGION = m_aw_data[C_AWREGION_RIGHT+:C_AWREGION_LEN];
      assign M_AXI_AWQOS    = m_aw_data[C_AWQOS_RIGHT+:C_AWQOS_LEN];

      axi_interconnect_v1_7_axic_sync_clock_converter #( 
        .C_FAMILY         ( C_FAMILY ) ,
        .C_PAYLOAD_WIDTH ( C_AW_SIZE ) ,
        .C_S_ACLK_RATIO   ( P_SI_LT_MI ? 1 : P_ACLK_RATIO ) ,
        .C_M_ACLK_RATIO   ( P_SI_LT_MI ? P_ACLK_RATIO : 1 ) ,
        .C_MODE(P_LIGHT_WT)
      )
      aw_sync_clock_converter (
        .SAMPLE_CYCLE (sample_cycle),
        .SAMPLE_CYCLE_EARLY (sample_cycle_early),
        .S_ACLK     ( S_AXI_ACLK     ) ,
        .S_ARESET   ( s_axi_reset_out_i ) ,
        .S_PAYLOAD ( s_aw_data ) ,
        .S_VALID   ( S_AXI_AWVALID   ) ,
        .S_READY   ( S_AXI_AWREADY   ) ,
        .M_ACLK     ( M_AXI_ACLK     ) ,
        .M_ARESET   ( m_axi_reset_out_i ) ,
        .M_PAYLOAD ( m_aw_data ) ,
        .M_VALID   ( M_AXI_AWVALID   ) ,
        .M_READY   ( M_AXI_AWREADY   ) 
      );
    
      // Write Data Port
      if (C_AXI_SUPPORTS_USER_SIGNALS == 1) begin : gen_w_user
        assign s_w_data     = {S_AXI_WDATA, S_AXI_WSTRB, S_AXI_WLAST, S_AXI_WUSER};
        assign M_AXI_WUSER = m_w_data[C_WUSER_RIGHT+:C_WUSER_LEN];
      end
      else begin : gen_w_no_user
        assign s_w_data     = {S_AXI_WDATA, S_AXI_WSTRB, S_AXI_WLAST};
        assign M_AXI_WUSER  = {C_AXI_WUSER_WIDTH{1'b0}};
      end

      assign M_AXI_WDATA    = m_w_data[C_WDATA_RIGHT+:C_WDATA_LEN];
      assign M_AXI_WSTRB    = m_w_data[C_WSTRB_RIGHT+:C_WSTRB_LEN];
      assign M_AXI_WLAST    = m_w_data[C_WLAST_RIGHT+:C_WLAST_LEN];

      axi_interconnect_v1_7_axic_sync_clock_converter #( 
        .C_FAMILY         ( C_FAMILY ) ,
        .C_PAYLOAD_WIDTH ( C_W_SIZE ) ,
        .C_S_ACLK_RATIO   ( P_SI_LT_MI ? 1 : P_ACLK_RATIO ) ,
        .C_M_ACLK_RATIO   ( P_SI_LT_MI ? P_ACLK_RATIO : 1 ) ,
        .C_MODE((C_AXI_PROTOCOL == P_AXILITE) ? P_LIGHT_WT : P_FULLY_REG)
      )
      w_sync_clock_converter (
        .SAMPLE_CYCLE (sample_cycle),
        .SAMPLE_CYCLE_EARLY (sample_cycle_early),
        .S_ACLK     ( S_AXI_ACLK     ) ,
        .S_ARESET   ( s_axi_reset_out_i ) ,
        .S_PAYLOAD ( s_w_data ) ,
        .S_VALID   ( S_AXI_WVALID   ) ,
        .S_READY   ( S_AXI_WREADY   ) ,
        .M_ACLK     ( M_AXI_ACLK     ) ,
        .M_ARESET   ( m_axi_reset_out_i ) ,
        .M_PAYLOAD ( m_w_data ) ,
        .M_VALID   ( M_AXI_WVALID   ) ,
        .M_READY   ( M_AXI_WREADY   ) 
      );
    
      // Write Response Port
      if (C_AXI_SUPPORTS_USER_SIGNALS == 1) begin : gen_b_user
        assign m_b_data     = {M_AXI_BID, M_AXI_BRESP, M_AXI_BUSER};
        assign S_AXI_BUSER  = s_b_data[C_BUSER_RIGHT+:C_BUSER_LEN];
      end
      else begin : gen_b_no_user
        assign m_b_data     = {M_AXI_BID, M_AXI_BRESP};
        assign S_AXI_BUSER  = {C_AXI_BUSER_WIDTH{1'b0}};
      end

      assign S_AXI_BID      = s_b_data[C_BID_RIGHT+:C_BID_LEN];
      assign S_AXI_BRESP    = s_b_data[C_BRESP_RIGHT+:C_BRESP_LEN];

      axi_interconnect_v1_7_axic_sync_clock_converter #( 
        .C_FAMILY         ( C_FAMILY ) ,
        .C_PAYLOAD_WIDTH ( C_B_SIZE ) ,
        .C_M_ACLK_RATIO   ( P_SI_LT_MI ? 1 : P_ACLK_RATIO ) ,
        .C_S_ACLK_RATIO   ( P_SI_LT_MI ? P_ACLK_RATIO : 1 ) ,
        .C_MODE(P_LIGHT_WT)
      )
      b_sync_clock_converter (
        .SAMPLE_CYCLE (sample_cycle),
        .SAMPLE_CYCLE_EARLY (sample_cycle_early),
        .S_ACLK     ( M_AXI_ACLK     ) ,
        .S_ARESET   ( m_axi_reset_out_i ) ,
        .S_PAYLOAD ( m_b_data ) ,
        .S_VALID   ( M_AXI_BVALID   ) ,
        .S_READY   ( M_AXI_BREADY   ) ,
        .M_ACLK     ( S_AXI_ACLK     ) ,
        .M_ARESET   ( s_axi_reset_out_i ) ,
        .M_PAYLOAD ( s_b_data ) ,
        .M_VALID   ( S_AXI_BVALID   ) ,
        .M_READY   ( S_AXI_BREADY   ) 
      );
    
    end else begin : gen_tieoff_write_ch

      // Write address port
      assign M_AXI_AWID     = 0;
      assign M_AXI_AWADDR   = 0;
      assign M_AXI_AWLEN    = 0;
      assign M_AXI_AWSIZE   = 0;
      assign M_AXI_AWBURST  = 0;
      assign M_AXI_AWLOCK   = 0;
      assign M_AXI_AWCACHE  = 0;
      assign M_AXI_AWPROT   = 0;
      assign M_AXI_AWREGION = 0;
      assign M_AXI_AWQOS    = 0;
      assign M_AXI_AWUSER   = 0;
      assign M_AXI_AWVALID  = 1'b0;
      assign S_AXI_AWREADY  = 1'b0;

      // Write Data Port
      assign M_AXI_WDATA    = 0;
      assign M_AXI_WSTRB    = 0;
      assign M_AXI_WLAST    = 0;
      assign M_AXI_WUSER    = 0;
      assign M_AXI_WVALID   = 1'b0;
      assign S_AXI_WREADY   = 1'b0;

      // Write Response Port
      assign S_AXI_BID      = 0;
      assign S_AXI_BRESP    = 0;
      assign S_AXI_BUSER    = 0;
      assign S_AXI_BVALID   = 1'b0;
      assign M_AXI_BREADY   = 1'b0;
    end

    ////////////////////////////////////////////////////////////////////////////////
    // AXI read channels
    ////////////////////////////////////////////////////////////////////////////////

    if (C_AXI_SUPPORTS_READ) begin : gen_conv_read_ch

      // Read Address Port
      if (C_AXI_SUPPORTS_USER_SIGNALS == 1) begin : gen_ar_user
        assign s_ar_data    = {S_AXI_ARID, S_AXI_ARADDR, S_AXI_ARLEN, S_AXI_ARSIZE, 
                               S_AXI_ARBURST, S_AXI_ARLOCK, S_AXI_ARCACHE, S_AXI_ARPROT, 
                               S_AXI_ARREGION, S_AXI_ARQOS, S_AXI_ARUSER};
        assign M_AXI_ARUSER = m_ar_data[C_ARUSER_RIGHT+:C_ARUSER_LEN];
      end
      else begin : gen_ar_no_user
        assign s_ar_data    = {S_AXI_ARID, S_AXI_ARADDR, S_AXI_ARLEN, S_AXI_ARSIZE, 
                               S_AXI_ARBURST, S_AXI_ARLOCK, S_AXI_ARCACHE, S_AXI_ARPROT, 
                               S_AXI_ARREGION, S_AXI_ARQOS};
        
        assign M_AXI_ARUSER = {C_AXI_ARUSER_WIDTH{1'b0}};
      end

      assign M_AXI_ARID     = m_ar_data[C_ARID_RIGHT+:C_ARID_LEN];
      assign M_AXI_ARADDR   = m_ar_data[C_ARADDR_RIGHT+:C_ARADDR_LEN];
      assign M_AXI_ARLEN    = m_ar_data[C_ARLEN_RIGHT+:C_ARLEN_LEN];
      assign M_AXI_ARSIZE   = m_ar_data[C_ARSIZE_RIGHT+:C_ARSIZE_LEN];
      assign M_AXI_ARBURST  = m_ar_data[C_ARBURST_RIGHT+:C_ARBURST_LEN];
      assign M_AXI_ARLOCK   = m_ar_data[C_ARLOCK_RIGHT+:C_ARLOCK_LEN];
      assign M_AXI_ARCACHE  = m_ar_data[C_ARCACHE_RIGHT+:C_ARCACHE_LEN];
      assign M_AXI_ARPROT   = m_ar_data[C_ARPROT_RIGHT+:C_ARPROT_LEN];
      assign M_AXI_ARREGION = m_ar_data[C_ARREGION_RIGHT+:C_ARREGION_LEN];
      assign M_AXI_ARQOS    = m_ar_data[C_ARQOS_RIGHT+:C_ARQOS_LEN];

      axi_interconnect_v1_7_axic_sync_clock_converter #( 
        .C_FAMILY         ( C_FAMILY ) ,
        .C_PAYLOAD_WIDTH ( C_AR_SIZE ) ,
        .C_S_ACLK_RATIO   ( P_SI_LT_MI ? 1 : P_ACLK_RATIO ) ,
        .C_M_ACLK_RATIO   ( P_SI_LT_MI ? P_ACLK_RATIO : 1 ) ,
        .C_MODE(P_LIGHT_WT)
      )
      ar_sync_clock_converter (
        .SAMPLE_CYCLE (sample_cycle),
        .SAMPLE_CYCLE_EARLY (sample_cycle_early),
        .S_ACLK     ( S_AXI_ACLK     ) ,
        .S_ARESET   ( s_axi_reset_out_i ) ,
        .S_PAYLOAD ( s_ar_data ) ,
        .S_VALID   ( S_AXI_ARVALID   ) ,
        .S_READY   ( S_AXI_ARREADY   ) ,
        .M_ACLK     ( M_AXI_ACLK     ) ,
        .M_ARESET   ( m_axi_reset_out_i ) ,
        .M_PAYLOAD ( m_ar_data ) ,
        .M_VALID   ( M_AXI_ARVALID   ) ,
        .M_READY   ( M_AXI_ARREADY   ) 
      );
    
      // Read Data Port
      if (C_AXI_SUPPORTS_USER_SIGNALS == 1) begin : gen_r_user
        assign m_r_data     = {M_AXI_RID, M_AXI_RDATA, M_AXI_RRESP, M_AXI_RLAST, M_AXI_RUSER};
        assign S_AXI_RUSER  = s_r_data[C_RUSER_RIGHT+:C_RUSER_LEN];
      end
      else begin : gen_r_no_user
        assign m_r_data     = {M_AXI_RID, M_AXI_RDATA, M_AXI_RRESP, M_AXI_RLAST};
        assign S_AXI_RUSER  = {C_AXI_RUSER_WIDTH{1'b0}};
      end

      assign S_AXI_RID      = s_r_data[C_RID_RIGHT+:C_RID_LEN];
      assign S_AXI_RDATA    = s_r_data[C_RDATA_RIGHT+:C_RDATA_LEN];
      assign S_AXI_RRESP    = s_r_data[C_RRESP_RIGHT+:C_RRESP_LEN];
      assign S_AXI_RLAST    = s_r_data[C_RLAST_RIGHT+:C_RLAST_LEN];

      axi_interconnect_v1_7_axic_sync_clock_converter #( 
        .C_FAMILY         ( C_FAMILY ) ,
        .C_PAYLOAD_WIDTH ( C_R_SIZE ) ,
        .C_M_ACLK_RATIO   ( P_SI_LT_MI ? 1 : P_ACLK_RATIO ) ,
        .C_S_ACLK_RATIO   ( P_SI_LT_MI ? P_ACLK_RATIO : 1 ) ,
        .C_MODE((C_AXI_PROTOCOL == P_AXILITE) ? P_LIGHT_WT : P_FULLY_REG)
      )
      r_sync_clock_converter (
        .SAMPLE_CYCLE (sample_cycle),
        .SAMPLE_CYCLE_EARLY (sample_cycle_early),
        .S_ACLK     ( M_AXI_ACLK     ) ,
        .S_ARESET   ( m_axi_reset_out_i ) ,
        .S_PAYLOAD ( m_r_data ) ,
        .S_VALID   ( M_AXI_RVALID   ) ,
        .S_READY   ( M_AXI_RREADY   ) ,
        .M_ACLK     ( S_AXI_ACLK     ) ,
        .M_ARESET   ( s_axi_reset_out_i ) ,
        .M_PAYLOAD ( s_r_data ) ,
        .M_VALID   ( S_AXI_RVALID   ) ,
        .M_READY   ( S_AXI_RREADY   ) 
      );
    
    end else begin : gen_tieoff_read_ch

      // Read Address Port
      assign M_AXI_ARID     = 0;
      assign M_AXI_ARADDR   = 0;
      assign M_AXI_ARLEN    = 0;
      assign M_AXI_ARSIZE   = 0;
      assign M_AXI_ARBURST  = 0;
      assign M_AXI_ARLOCK   = 0;
      assign M_AXI_ARCACHE  = 0;
      assign M_AXI_ARPROT   = 0;
      assign M_AXI_ARREGION = 0;
      assign M_AXI_ARQOS    = 0;
      assign M_AXI_ARUSER   = 0;
      assign M_AXI_ARVALID  = 1'b0;
      assign S_AXI_ARREADY  = 1'b0;

      // Read Data Port
      assign S_AXI_RID      = 0;
      assign S_AXI_RDATA    = 0;
      assign S_AXI_RRESP    = 0;
      assign S_AXI_RLAST    = 0;
      assign S_AXI_RUSER    = 0;
      assign S_AXI_RVALID   = 1'b0;
      assign M_AXI_RREADY   = 1'b0;
    end
  end else begin : gen_bypass
    // No clock conversion, i.e. 1:1 

      // Write address port
      assign M_AXI_AWID     = S_AXI_AWID;
      assign M_AXI_AWADDR   = S_AXI_AWADDR;
      assign M_AXI_AWLEN    = S_AXI_AWLEN;
      assign M_AXI_AWSIZE   = S_AXI_AWSIZE;
      assign M_AXI_AWBURST  = S_AXI_AWBURST;
      assign M_AXI_AWLOCK   = S_AXI_AWLOCK;
      assign M_AXI_AWCACHE  = S_AXI_AWCACHE;
      assign M_AXI_AWPROT   = S_AXI_AWPROT;
      assign M_AXI_AWREGION = S_AXI_AWREGION;
      assign M_AXI_AWQOS    = S_AXI_AWQOS;
      assign M_AXI_AWUSER   = S_AXI_AWUSER;
      assign M_AXI_AWVALID  = S_AXI_AWVALID & (C_AXI_SUPPORTS_WRITE != 0);
      assign S_AXI_AWREADY  = M_AXI_AWREADY & (C_AXI_SUPPORTS_WRITE != 0);

      // Write Data Port
      assign M_AXI_WDATA    = S_AXI_WDATA;
      assign M_AXI_WSTRB    = S_AXI_WSTRB;
      assign M_AXI_WLAST    = S_AXI_WLAST;
      assign M_AXI_WUSER    = S_AXI_WUSER;
      assign M_AXI_WVALID   = S_AXI_WVALID & (C_AXI_SUPPORTS_WRITE != 0);
      assign S_AXI_WREADY   = M_AXI_WREADY & (C_AXI_SUPPORTS_WRITE != 0);

      // Write Response Port
      assign S_AXI_BID      = M_AXI_BID;
      assign S_AXI_BRESP    = M_AXI_BRESP;
      assign S_AXI_BUSER    = M_AXI_BUSER;
      assign S_AXI_BVALID   = M_AXI_BVALID & (C_AXI_SUPPORTS_WRITE != 0);
      assign M_AXI_BREADY   = S_AXI_BREADY & (C_AXI_SUPPORTS_WRITE != 0);

      // Read Address Port
      assign M_AXI_ARID     = S_AXI_ARID;
      assign M_AXI_ARADDR   = S_AXI_ARADDR;
      assign M_AXI_ARLEN    = S_AXI_ARLEN;
      assign M_AXI_ARSIZE   = S_AXI_ARSIZE;
      assign M_AXI_ARBURST  = S_AXI_ARBURST;
      assign M_AXI_ARLOCK   = S_AXI_ARLOCK;
      assign M_AXI_ARCACHE  = S_AXI_ARCACHE;
      assign M_AXI_ARPROT   = S_AXI_ARPROT;
      assign M_AXI_ARREGION = S_AXI_ARREGION;
      assign M_AXI_ARQOS    = S_AXI_ARQOS;
      assign M_AXI_ARUSER   = S_AXI_ARUSER;
      assign M_AXI_ARVALID  = S_AXI_ARVALID & (C_AXI_SUPPORTS_READ != 0);
      assign S_AXI_ARREADY  = M_AXI_ARREADY & (C_AXI_SUPPORTS_READ != 0);

      // Read Data Port
      assign S_AXI_RID      = M_AXI_RID;
      assign S_AXI_RDATA    = M_AXI_RDATA;
      assign S_AXI_RRESP    = M_AXI_RRESP;
      assign S_AXI_RLAST    = M_AXI_RLAST;
      assign S_AXI_RUSER    = M_AXI_RUSER;
      assign S_AXI_RVALID   = M_AXI_RVALID & (C_AXI_SUPPORTS_READ != 0);
      assign M_AXI_RREADY   = S_AXI_RREADY & (C_AXI_SUPPORTS_READ != 0);
  end

  endgenerate

endmodule


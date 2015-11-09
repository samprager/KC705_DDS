// (c) Copyright 1995-2014 Xilinx, Inc. All rights reserved.
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
// 
// DO NOT MODIFY THIS FILE.

// IP VLNV: xilinx.com:ip:axi_ethernet_buffer:2.0
// IP Revision: 4

// The following must be inserted into your Verilog file for this
// core to be instantiated. Change the instance name and port connections
// (in parentheses) to your own signal names.

//----------- Begin Cut here for INSTANTIATION Template ---// INST_TAG
system_eth_buf_0 your_instance_name (
  .INTERRUPT(INTERRUPT),                              // output wire INTERRUPT
  .S_AXI_ACLK(S_AXI_ACLK),                            // input wire S_AXI_ACLK
  .S_AXI_ARESETN(S_AXI_ARESETN),                      // input wire S_AXI_ARESETN
  .S_AXI_AWADDR(S_AXI_AWADDR),                        // input wire [17 : 0] S_AXI_AWADDR
  .S_AXI_AWVALID(S_AXI_AWVALID),                      // input wire S_AXI_AWVALID
  .S_AXI_AWREADY(S_AXI_AWREADY),                      // output wire S_AXI_AWREADY
  .S_AXI_WDATA(S_AXI_WDATA),                          // input wire [31 : 0] S_AXI_WDATA
  .S_AXI_WSTRB(S_AXI_WSTRB),                          // input wire [3 : 0] S_AXI_WSTRB
  .S_AXI_WVALID(S_AXI_WVALID),                        // input wire S_AXI_WVALID
  .S_AXI_WREADY(S_AXI_WREADY),                        // output wire S_AXI_WREADY
  .S_AXI_BRESP(S_AXI_BRESP),                          // output wire [1 : 0] S_AXI_BRESP
  .S_AXI_BVALID(S_AXI_BVALID),                        // output wire S_AXI_BVALID
  .S_AXI_BREADY(S_AXI_BREADY),                        // input wire S_AXI_BREADY
  .S_AXI_ARADDR(S_AXI_ARADDR),                        // input wire [17 : 0] S_AXI_ARADDR
  .S_AXI_ARVALID(S_AXI_ARVALID),                      // input wire S_AXI_ARVALID
  .S_AXI_ARREADY(S_AXI_ARREADY),                      // output wire S_AXI_ARREADY
  .S_AXI_RDATA(S_AXI_RDATA),                          // output wire [31 : 0] S_AXI_RDATA
  .S_AXI_RRESP(S_AXI_RRESP),                          // output wire [1 : 0] S_AXI_RRESP
  .S_AXI_RVALID(S_AXI_RVALID),                        // output wire S_AXI_RVALID
  .S_AXI_RREADY(S_AXI_RREADY),                        // input wire S_AXI_RREADY
  .EMAC_CLIENT_AUTONEG_INT(EMAC_CLIENT_AUTONEG_INT),  // input wire EMAC_CLIENT_AUTONEG_INT
  .EMAC_RESET_DONE_INT(EMAC_RESET_DONE_INT),          // input wire EMAC_RESET_DONE_INT
  .EMAC_RX_DCM_LOCKED_INT(EMAC_RX_DCM_LOCKED_INT),    // input wire EMAC_RX_DCM_LOCKED_INT
  .PCSPMA_STATUS_VECTOR(PCSPMA_STATUS_VECTOR),        // input wire [15 : 0] PCSPMA_STATUS_VECTOR
  .AXI_STR_TXD_ACLK(AXI_STR_TXD_ACLK),                // input wire AXI_STR_TXD_ACLK
  .AXI_STR_TXD_ARESETN(AXI_STR_TXD_ARESETN),          // input wire AXI_STR_TXD_ARESETN
  .AXI_STR_TXD_TVALID(AXI_STR_TXD_TVALID),            // input wire AXI_STR_TXD_TVALID
  .AXI_STR_TXD_TREADY(AXI_STR_TXD_TREADY),            // output wire AXI_STR_TXD_TREADY
  .AXI_STR_TXD_TLAST(AXI_STR_TXD_TLAST),              // input wire AXI_STR_TXD_TLAST
  .AXI_STR_TXD_TKEEP(AXI_STR_TXD_TKEEP),              // input wire [3 : 0] AXI_STR_TXD_TKEEP
  .AXI_STR_TXD_TDATA(AXI_STR_TXD_TDATA),              // input wire [31 : 0] AXI_STR_TXD_TDATA
  .AXI_STR_TXC_ACLK(AXI_STR_TXC_ACLK),                // input wire AXI_STR_TXC_ACLK
  .AXI_STR_TXC_ARESETN(AXI_STR_TXC_ARESETN),          // input wire AXI_STR_TXC_ARESETN
  .AXI_STR_TXC_TVALID(AXI_STR_TXC_TVALID),            // input wire AXI_STR_TXC_TVALID
  .AXI_STR_TXC_TREADY(AXI_STR_TXC_TREADY),            // output wire AXI_STR_TXC_TREADY
  .AXI_STR_TXC_TLAST(AXI_STR_TXC_TLAST),              // input wire AXI_STR_TXC_TLAST
  .AXI_STR_TXC_TKEEP(AXI_STR_TXC_TKEEP),              // input wire [3 : 0] AXI_STR_TXC_TKEEP
  .AXI_STR_TXC_TDATA(AXI_STR_TXC_TDATA),              // input wire [31 : 0] AXI_STR_TXC_TDATA
  .AXI_STR_RXD_ACLK(AXI_STR_RXD_ACLK),                // input wire AXI_STR_RXD_ACLK
  .AXI_STR_RXD_ARESETN(AXI_STR_RXD_ARESETN),          // input wire AXI_STR_RXD_ARESETN
  .AXI_STR_RXD_VALID(AXI_STR_RXD_VALID),              // output wire AXI_STR_RXD_VALID
  .AXI_STR_RXD_READY(AXI_STR_RXD_READY),              // input wire AXI_STR_RXD_READY
  .AXI_STR_RXD_LAST(AXI_STR_RXD_LAST),                // output wire AXI_STR_RXD_LAST
  .AXI_STR_RXD_KEEP(AXI_STR_RXD_KEEP),                // output wire [3 : 0] AXI_STR_RXD_KEEP
  .AXI_STR_RXD_DATA(AXI_STR_RXD_DATA),                // output wire [31 : 0] AXI_STR_RXD_DATA
  .AXI_STR_RXS_ACLK(AXI_STR_RXS_ACLK),                // input wire AXI_STR_RXS_ACLK
  .AXI_STR_RXS_ARESETN(AXI_STR_RXS_ARESETN),          // input wire AXI_STR_RXS_ARESETN
  .AXI_STR_RXS_VALID(AXI_STR_RXS_VALID),              // output wire AXI_STR_RXS_VALID
  .AXI_STR_RXS_READY(AXI_STR_RXS_READY),              // input wire AXI_STR_RXS_READY
  .AXI_STR_RXS_LAST(AXI_STR_RXS_LAST),                // output wire AXI_STR_RXS_LAST
  .AXI_STR_RXS_KEEP(AXI_STR_RXS_KEEP),                // output wire [3 : 0] AXI_STR_RXS_KEEP
  .AXI_STR_RXS_DATA(AXI_STR_RXS_DATA),                // output wire [31 : 0] AXI_STR_RXS_DATA
  .pause_req(pause_req),                              // output wire pause_req
  .pause_val(pause_val),                              // output wire [16 : 31] pause_val
  .S_AXI_2TEMAC_AWADDR(S_AXI_2TEMAC_AWADDR),          // output wire [11 : 0] S_AXI_2TEMAC_AWADDR
  .S_AXI_2TEMAC_AWVALID(S_AXI_2TEMAC_AWVALID),        // output wire S_AXI_2TEMAC_AWVALID
  .S_AXI_2TEMAC_AWREADY(S_AXI_2TEMAC_AWREADY),        // input wire S_AXI_2TEMAC_AWREADY
  .S_AXI_2TEMAC_WDATA(S_AXI_2TEMAC_WDATA),            // output wire [31 : 0] S_AXI_2TEMAC_WDATA
  .S_AXI_2TEMAC_WVALID(S_AXI_2TEMAC_WVALID),          // output wire S_AXI_2TEMAC_WVALID
  .S_AXI_2TEMAC_WREADY(S_AXI_2TEMAC_WREADY),          // input wire S_AXI_2TEMAC_WREADY
  .S_AXI_2TEMAC_BRESP(S_AXI_2TEMAC_BRESP),            // input wire [1 : 0] S_AXI_2TEMAC_BRESP
  .S_AXI_2TEMAC_BVALID(S_AXI_2TEMAC_BVALID),          // input wire S_AXI_2TEMAC_BVALID
  .S_AXI_2TEMAC_BREADY(S_AXI_2TEMAC_BREADY),          // output wire S_AXI_2TEMAC_BREADY
  .S_AXI_2TEMAC_ARADDR(S_AXI_2TEMAC_ARADDR),          // output wire [11 : 0] S_AXI_2TEMAC_ARADDR
  .S_AXI_2TEMAC_ARVALID(S_AXI_2TEMAC_ARVALID),        // output wire S_AXI_2TEMAC_ARVALID
  .S_AXI_2TEMAC_ARREADY(S_AXI_2TEMAC_ARREADY),        // input wire S_AXI_2TEMAC_ARREADY
  .S_AXI_2TEMAC_RDATA(S_AXI_2TEMAC_RDATA),            // input wire [31 : 0] S_AXI_2TEMAC_RDATA
  .S_AXI_2TEMAC_RRESP(S_AXI_2TEMAC_RRESP),            // input wire [1 : 0] S_AXI_2TEMAC_RRESP
  .S_AXI_2TEMAC_RVALID(S_AXI_2TEMAC_RVALID),          // input wire S_AXI_2TEMAC_RVALID
  .S_AXI_2TEMAC_RREADY(S_AXI_2TEMAC_RREADY),          // output wire S_AXI_2TEMAC_RREADY
  .RX_CLK_ENABLE_IN(RX_CLK_ENABLE_IN),                // input wire RX_CLK_ENABLE_IN
  .rx_statistics_vector(rx_statistics_vector),        // input wire [27 : 0] rx_statistics_vector
  .rx_statistics_valid(rx_statistics_valid),          // input wire rx_statistics_valid
  .rx_mac_aclk(rx_mac_aclk),                          // input wire rx_mac_aclk
  .rx_reset(rx_reset),                                // input wire rx_reset
  .rx_axis_mac_tdata(rx_axis_mac_tdata),              // input wire [7 : 0] rx_axis_mac_tdata
  .rx_axis_mac_tvalid(rx_axis_mac_tvalid),            // input wire rx_axis_mac_tvalid
  .rx_axis_mac_tlast(rx_axis_mac_tlast),              // input wire rx_axis_mac_tlast
  .rx_axis_mac_tuser(rx_axis_mac_tuser),              // input wire rx_axis_mac_tuser
  .tx_ifg_delay(tx_ifg_delay),                        // output wire [24 : 31] tx_ifg_delay
  .tx_mac_aclk(tx_mac_aclk),                          // input wire tx_mac_aclk
  .tx_reset(tx_reset),                                // input wire tx_reset
  .tx_axis_mac_tdata(tx_axis_mac_tdata),              // output wire [7 : 0] tx_axis_mac_tdata
  .tx_axis_mac_tvalid(tx_axis_mac_tvalid),            // output wire tx_axis_mac_tvalid
  .tx_axis_mac_tlast(tx_axis_mac_tlast),              // output wire tx_axis_mac_tlast
  .tx_axis_mac_tuser(tx_axis_mac_tuser),              // output wire [0 : 0] tx_axis_mac_tuser
  .tx_axis_mac_tready(tx_axis_mac_tready),            // input wire tx_axis_mac_tready
  .speed_is_10_100(speed_is_10_100),                  // input wire speed_is_10_100
  .RESET2PCSPMA(RESET2PCSPMA),                        // output wire RESET2PCSPMA
  .RESET2TEMACn(RESET2TEMACn),                        // output wire RESET2TEMACn
  .PHY_RST_N(PHY_RST_N),                              // output wire PHY_RST_N
  .mdio_i_top(mdio_i_top),                            // input wire mdio_i_top
  .mdio_o_top(mdio_o_top),                            // output wire mdio_o_top
  .mdio_t_top(mdio_t_top),                            // output wire mdio_t_top
  .mdc_top(mdc_top),                                  // output wire mdc_top
  .mdio_t_pcspma(mdio_t_pcspma),                      // input wire mdio_t_pcspma
  .mdio_o_pcspma(mdio_o_pcspma),                      // input wire mdio_o_pcspma
  .mdio_i_temac(mdio_i_temac),                        // output wire mdio_i_temac
  .mdio_o_temac(mdio_o_temac),                        // input wire mdio_o_temac
  .mdio_t_temac(mdio_t_temac),                        // input wire mdio_t_temac
  .mdc_temac(mdc_temac),                              // input wire mdc_temac
  .GTX_CLK(GTX_CLK)                                  // input wire GTX_CLK
);
// INST_TAG_END ------ End INSTANTIATION Template ---------

// You must compile the wrapper file system_eth_buf_0.v when simulating
// the core, system_eth_buf_0. When compiling the wrapper file, be sure to
// reference the Verilog simulation library.


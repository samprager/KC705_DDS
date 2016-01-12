set_property SRC_FILE_INFO {cfile:D:/Prager/KC705_DDS/Verilog/ethernet_mig_sp/ethernet_mig_sp.srcs/constrs_1/imports/example_design/kc705_ethernet_rgmii_example_design.xdc rfile:../ethernet_mig_sp.srcs/constrs_1/imports/example_design/kc705_ethernet_rgmii_example_design.xdc id:1} [current_design]
set_property src_info {type:XDC file:1 line:107 export:INPUT save:INPUT read:READ} [current_design]
set_input_jitter clk_in_p 0.050
set_property src_info {type:XDC file:1 line:110 export:INPUT save:INPUT read:READ} [current_design]
set_input_jitter sys_clk_p 0.050
set_property src_info {type:XDC file:1 line:138 export:INPUT save:INPUT read:READ} [current_design]
set_max_delay -datapath_only -from [get_ports update_speed] 4.000
set_property src_info {type:XDC file:1 line:177 export:INPUT save:INPUT read:READ} [current_design]
set_max_delay -datapath_only -from [get_cells tx_stats_toggle_reg] -to [get_cells tx_stats_sync/data_sync_reg0] 6.000
set_property src_info {type:XDC file:1 line:178 export:INPUT save:INPUT read:READ} [current_design]
set_max_delay -datapath_only -from [get_cells rx_stats_toggle_reg] -to [get_cells rx_stats_sync/data_sync_reg0] 6.000
set_property src_info {type:XDC file:1 line:195 export:INPUT save:INPUT read:READ} [current_design]
set_max_delay -datapath_only -from [get_cells -hier -filter {name =~ *tx_fifo_i/rd_addr_txfer_reg[*]}] -to [get_cells -hier -filter {name =~ *fifo*wr_rd_addr_reg[*]}] 6.000
set_property src_info {type:XDC file:1 line:196 export:INPUT save:INPUT read:READ} [current_design]
set_max_delay -datapath_only -from [get_cells -hier -filter {name =~ *rx_fifo_i/rd_addr_reg[*]}] -to [get_cells -hier -filter {name =~ *fifo*wr_rd_addr_reg[*]}] 6.000
set_property src_info {type:XDC file:1 line:197 export:INPUT save:INPUT read:READ} [current_design]
set_max_delay -datapath_only -from [get_cells -hier -filter {name =~ *rx_fifo_i/wr_store_frame_tog_reg}] -to [get_cells -hier -filter {name =~ *fifo_i/resync_wr_store_frame_tog/data_sync_reg0}] 6.000
set_property src_info {type:XDC file:1 line:198 export:INPUT save:INPUT read:READ} [current_design]
set_max_delay -datapath_only -from [get_cells -hier -filter {name =~ *rx_fifo_i/update_addr_tog_reg}] -to [get_cells -hier -filter {name =~ *rx_fifo_i/sync_rd_addr_tog/data_sync_reg0}] 6.000
set_property src_info {type:XDC file:1 line:199 export:INPUT save:INPUT read:READ} [current_design]
set_max_delay -datapath_only -from [get_cells -hier -filter {name =~ *tx_fifo_i/wr_frame_in_fifo_reg}] -to [get_cells -hier -filter {name =~ *tx_fifo_i/resync_wr_frame_in_fifo/data_sync_reg0}] 6.000
set_property src_info {type:XDC file:1 line:200 export:INPUT save:INPUT read:READ} [current_design]
set_max_delay -datapath_only -from [get_cells -hier -filter {name =~ *tx_fifo_i/wr_frames_in_fifo_reg}] -to [get_cells -hier -filter {name =~ *tx_fifo_i/resync_wr_frames_in_fifo/data_sync_reg0}] 6.000
set_property src_info {type:XDC file:1 line:201 export:INPUT save:INPUT read:READ} [current_design]
set_max_delay -datapath_only -from [get_cells -hier -filter {name =~ *tx_fifo_i/frame_in_fifo_valid_tog_reg}] -to [get_cells -hier -filter {name =~ *tx_fifo_i/resync_fif_valid_tog/data_sync_reg0}] 6.000
set_property src_info {type:XDC file:1 line:202 export:INPUT save:INPUT read:READ} [current_design]
set_max_delay -datapath_only -from [get_cells -hier -filter {name =~ *tx_fifo_i/rd_txfer_tog_reg}] -to [get_cells -hier -filter {name =~ *tx_fifo_i/resync_rd_txfer_tog/data_sync_reg0}] 6.000
set_property src_info {type:XDC file:1 line:203 export:INPUT save:INPUT read:READ} [current_design]
set_max_delay -datapath_only -from [get_cells -hier -filter {name =~ *tx_fifo_i/rd_tran_frame_tog_reg}] -to [get_cells -hier -filter {name =~ *tx_fifo_i/resync_rd_tran_frame_tog/data_sync_reg0}] 6.000
set_property src_info {type:XDC file:1 line:209 export:INPUT save:INPUT read:READ} [current_design]
create_generated_clock -name ddr3_ck_p[0] -source [get_pins {u_mig_example_top/u_mig_7series_0/u_mig_7series_0_mig/u_memc_ui_top_axi/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_1.u_ddr_phy_4lanes/ddr_byte_lane_B.ddr_byte_lane_B/ddr_ck_gen_loop[0].ddr_ck_gen.ddr_ck/C}] -divide_by 1 -invert [get_ports {ddr3_ck_p[0]}]
set_property src_info {type:XDC file:1 line:252 export:INPUT save:INPUT read:READ} [current_design]
set_clock_groups -logically_exclusive -group [get_clocks -include_generated_clocks iserdes_clk_8] -group [get_clocks -include_generated_clocks iserdes_clkdiv_8]
set_property src_info {type:XDC file:1 line:253 export:INPUT save:INPUT read:READ} [current_design]
set_clock_groups -logically_exclusive -group [get_clocks -include_generated_clocks oserdes_clk_11] -group [get_clocks -include_generated_clocks oserdes_clkdiv_11]
set_property src_info {type:XDC file:1 line:254 export:INPUT save:INPUT read:READ} [current_design]
set_clock_groups -logically_exclusive -group [get_clocks -include_generated_clocks iserdes_clk_9] -group [get_clocks -include_generated_clocks iserdes_clkdiv_9]
set_property src_info {type:XDC file:1 line:255 export:INPUT save:INPUT read:READ} [current_design]
set_clock_groups -logically_exclusive -group [get_clocks -include_generated_clocks oserdes_clk_12] -group [get_clocks -include_generated_clocks oserdes_clkdiv_12]
set_property src_info {type:XDC file:1 line:256 export:INPUT save:INPUT read:READ} [current_design]
set_clock_groups -logically_exclusive -group [get_clocks -include_generated_clocks iserdes_clk_10] -group [get_clocks -include_generated_clocks iserdes_clkdiv_10]
set_property src_info {type:XDC file:1 line:257 export:INPUT save:INPUT read:READ} [current_design]
set_clock_groups -logically_exclusive -group [get_clocks -include_generated_clocks oserdes_clk_13] -group [get_clocks -include_generated_clocks oserdes_clkdiv_13]
set_property src_info {type:XDC file:1 line:258 export:INPUT save:INPUT read:READ} [current_design]
set_clock_groups -logically_exclusive -group [get_clocks -include_generated_clocks iserdes_clk_11] -group [get_clocks -include_generated_clocks iserdes_clkdiv_11]
set_property src_info {type:XDC file:1 line:259 export:INPUT save:INPUT read:READ} [current_design]
set_clock_groups -logically_exclusive -group [get_clocks -include_generated_clocks oserdes_clk_14] -group [get_clocks -include_generated_clocks oserdes_clkdiv_14]
set_property src_info {type:XDC file:1 line:260 export:INPUT save:INPUT read:READ} [current_design]
set_clock_groups -logically_exclusive -group [get_clocks -include_generated_clocks oserdes_clk_15] -group [get_clocks -include_generated_clocks oserdes_clkdiv_15]
set_property src_info {type:XDC file:1 line:261 export:INPUT save:INPUT read:READ} [current_design]
set_clock_groups -logically_exclusive -group [get_clocks -include_generated_clocks oserdes_clk_16] -group [get_clocks -include_generated_clocks oserdes_clkdiv_16]
set_property src_info {type:XDC file:1 line:262 export:INPUT save:INPUT read:READ} [current_design]
set_clock_groups -logically_exclusive -group [get_clocks -include_generated_clocks oserdes_clk_17] -group [get_clocks -include_generated_clocks oserdes_clkdiv_17]
set_property src_info {type:XDC file:1 line:263 export:INPUT save:INPUT read:READ} [current_design]
set_clock_groups -logically_exclusive -group [get_clocks -include_generated_clocks iserdes_clk_12] -group [get_clocks -include_generated_clocks iserdes_clkdiv_12]
set_property src_info {type:XDC file:1 line:264 export:INPUT save:INPUT read:READ} [current_design]
set_clock_groups -logically_exclusive -group [get_clocks -include_generated_clocks oserdes_clk_18] -group [get_clocks -include_generated_clocks oserdes_clkdiv_18]
set_property src_info {type:XDC file:1 line:265 export:INPUT save:INPUT read:READ} [current_design]
set_clock_groups -logically_exclusive -group [get_clocks -include_generated_clocks iserdes_clk_13] -group [get_clocks -include_generated_clocks iserdes_clkdiv_13]
set_property src_info {type:XDC file:1 line:266 export:INPUT save:INPUT read:READ} [current_design]
set_clock_groups -logically_exclusive -group [get_clocks -include_generated_clocks oserdes_clk_19] -group [get_clocks -include_generated_clocks oserdes_clkdiv_19]
set_property src_info {type:XDC file:1 line:267 export:INPUT save:INPUT read:READ} [current_design]
set_clock_groups -logically_exclusive -group [get_clocks -include_generated_clocks iserdes_clk_14] -group [get_clocks -include_generated_clocks iserdes_clkdiv_14]
set_property src_info {type:XDC file:1 line:268 export:INPUT save:INPUT read:READ} [current_design]
set_clock_groups -logically_exclusive -group [get_clocks -include_generated_clocks oserdes_clk_20] -group [get_clocks -include_generated_clocks oserdes_clkdiv_20]
set_property src_info {type:XDC file:1 line:269 export:INPUT save:INPUT read:READ} [current_design]
set_clock_groups -logically_exclusive -group [get_clocks -include_generated_clocks iserdes_clk_15] -group [get_clocks -include_generated_clocks iserdes_clkdiv_15]
set_property src_info {type:XDC file:1 line:270 export:INPUT save:INPUT read:READ} [current_design]
set_clock_groups -logically_exclusive -group [get_clocks -include_generated_clocks oserdes_clk_21] -group [get_clocks -include_generated_clocks oserdes_clkdiv_21]
set_property src_info {type:XDC file:1 line:273 export:INPUT save:INPUT read:READ} [current_design]
set_property LOC XADC_X0Y0 [get_cells u_mig_example_top/u_mig_7series_0/u_mig_7series_0_mig/temp_mon_enabled.u_tempmon/xadc_supplied_temperature.XADC_inst]
set_property src_info {type:XDC file:1 line:280 export:INPUT save:INPUT read:READ} [current_design]
set_property FIXED_ROUTE { { IOB_IBUF0 RIOI_I0 RIOI_ILOGIC0_D IOI_ILOGIC0_O RIOI_I2GCLK_TOP0  { HCLK_CMT_CK_IN0 CLK_HROW_BOT_R_CK_BUFG_CASCO14 CLK_HROW_BOT_R_CK_BUFG_CASCO14 CLK_HROW_BOT_R_CK_BUFG_CASCO14 CLK_BUFG_BUFGCTRL7_I0 }  HCLK_CMT_MUX_OUT_FREQ_REF0 HCLK_CMT_FREQ_REF_NS0 PLL_CLK_FREQ_BB_BUFOUT_NS0 MMCM_CLK_FREQ_BB_NS0 CMT_L_LOWER_B_CLK_FREQ_BB3 CMT_LR_LOWER_B_MMCM_CLKIN1 }  } [get_nets example_clocks/clkin1]

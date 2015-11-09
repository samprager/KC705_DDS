set_property SRC_FILE_INFO {cfile:c:/kc705_ethernet/kc705_ethernet.srcs/sources_1/ip/kc705_ethernet_rgmii/synth/kc705_ethernet_rgmii.xdc rfile:../../../kc705_ethernet.srcs/sources_1/ip/kc705_ethernet_rgmii/synth/kc705_ethernet_rgmii.xdc id:1 order:EARLY scoped_inst:inst} [current_design]
set_property SRC_FILE_INFO {cfile:c:/kc705_ethernet/kc705_ethernet.srcs/sources_1/ip/kc705_ethernet_rgmii/synth/kc705_ethernet_rgmii_clocks.xdc rfile:../../../kc705_ethernet.srcs/sources_1/ip/kc705_ethernet_rgmii/synth/kc705_ethernet_rgmii_clocks.xdc id:2 order:LATE scoped_inst:inst} [current_design]
set_property src_info {type:SCOPED_XDC file:1 line:66 export:INPUT save:INPUT read:READ} [current_design]
set_max_delay -from [get_cells {kc705_ethernet_rgmii_core/flow/rx_pause/pause*to_tx_reg[*]}] -to [get_cells {kc705_ethernet_rgmii_core/flow/tx_pause/count_set*reg}] 32 -datapath_only
set_property src_info {type:SCOPED_XDC file:1 line:67 export:INPUT save:INPUT read:READ} [current_design]
set_max_delay -from [get_cells {kc705_ethernet_rgmii_core/flow/rx_pause/pause*to_tx_reg[*]}] -to [get_cells {kc705_ethernet_rgmii_core/flow/tx_pause/pause_count*reg[*]}] 32 -datapath_only
set_property src_info {type:SCOPED_XDC file:1 line:68 export:INPUT save:INPUT read:READ} [current_design]
set_max_delay -from [get_cells {kc705_ethernet_rgmii_core/flow/rx_pause/pause_req_to_tx_int_reg}] -to [get_cells {kc705_ethernet_rgmii_core/flow/tx_pause/sync_good_rx/data_sync_reg0}] 6 -datapath_only
set_property src_info {type:SCOPED_XDC file:1 line:85 export:INPUT save:INPUT read:READ} [current_design]
set_max_delay -from [get_cells {kc705_ethernet_rgmii_core/addr_filter_top/addr_regs.promiscuous_mode_reg_reg}] -to [get_cells {kc705_ethernet_rgmii_core/addr_filter_top/address_filter_inst/resync_promiscuous_mode/data_sync_reg0}] 6 -datapath_only
set_property src_info {type:SCOPED_XDC file:1 line:86 export:INPUT save:INPUT read:READ} [current_design]
set_max_delay -from [get_cells {kc705_ethernet_rgmii_core/*managen/conf/update_pause_ad_int_reg}] -to [get_cells {kc705_ethernet_rgmii_core/addr_filter_top/address_filter_inst/sync_update/data_sync_reg0}] 6 -datapath_only
set_property src_info {type:SCOPED_XDC file:2 line:43 export:INPUT save:INPUT read:READ} [current_design]
set_false_path -rise_from [get_clocks kc705_ethernet_rgmii_rgmii_rx_clk] -rise_to [get_clocks -of_objects [get_ports rgmii_rxc]] -hold
set_property src_info {type:SCOPED_XDC file:2 line:44 export:INPUT save:INPUT read:READ} [current_design]
set_false_path -fall_from [get_clocks kc705_ethernet_rgmii_rgmii_rx_clk] -fall_to [get_clocks -of_objects [get_ports rgmii_rxc]] -hold
set_property src_info {type:SCOPED_XDC file:2 line:57 export:INPUT save:INPUT read:READ} [current_design]
set_false_path -rise_from [get_clocks -of_objects [get_ports gtx_clk]] -rise_to [get_clocks rgmii_tx_clk] -hold
set_property src_info {type:SCOPED_XDC file:2 line:58 export:INPUT save:INPUT read:READ} [current_design]
set_false_path -fall_from [get_clocks -of_objects [get_ports gtx_clk]] -fall_to [get_clocks rgmii_tx_clk] -hold
set_property src_info {type:SCOPED_XDC file:2 line:70 export:INPUT save:INPUT read:READ} [current_design]
set_max_delay -from [get_cells {axi4_lite_ipif/axi_lite_top/*/bus2ip_addr_reg_reg[*]}] -to [get_clocks -of_objects [get_ports gtx_clk]] 6 -datapath_only

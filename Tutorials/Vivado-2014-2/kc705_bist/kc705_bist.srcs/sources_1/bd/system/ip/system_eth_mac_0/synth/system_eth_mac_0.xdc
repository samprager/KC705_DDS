
# PART is xc7k325tffg900-1

############################################################
# Clock Period Constraints                                 #
############################################################

############################################################
# RX Clock period Constraints (per instance)               #
############################################################
# Receiver clock period constraints: please do not relax
create_clock -period 8 [get_ports gmii_rx_clk]

############################################################
# MII TX Clock period Constraints (per instance)               #
############################################################
create_clock -period 8 [get_ports mii_tx_clk]

#
####
#######
##########
#############
#################
#BLOCK CONSTRAINTS

############################################################
# Physical Interface Constraints
############################################################

############################################################
# External GMII Constraints                                #
############################################################

# GMII Transmitter/Receiver Constraints:  place flip-flops in IOB
set_property IOB TRUE  [get_cells {tri_mode_ethernet_mac_i/gmii_interface/gmii_txd*reg[*]}]
set_property IOB TRUE  [get_cells {tri_mode_ethernet_mac_i/gmii_interface/gmii_tx_e*reg}]
set_property IOB TRUE  [get_cells {tri_mode_ethernet_mac_i/gmii_interface/rx*_to_mac*reg}]
set_property IOB TRUE  [get_cells {tri_mode_ethernet_mac_i/gmii_interface/rx*_to_mac*reg[*]}]

############################################################
# The following are required to maximise setup/hold        #
############################################################

set_property SLEW FAST [get_ports {gmii_tx_en gmii_tx_er gmii_txd[7] gmii_txd[6] gmii_txd[5] gmii_txd[4] gmii_txd[3] gmii_txd[2] gmii_txd[1] gmii_txd[0]}]
set_property SLEW FAST [get_ports {gmii_tx_clk}]


############################################################
# GMII: IODELAY Constraints
############################################################
# Please modify the value of the IDELAY_VALUE
# according to your design.
# For more information on IDELAYCTRL and IODELAY, please
# refer to the Series-7 User Guide.
# apply the same IDELAY_VALUE to all GMII RX inputs
set_property IDELAY_VALUE 30 [get_cells {tri_mode_ethernet_mac_i/gmii_interface/delay_gmii_rx* tri_mode_ethernet_mac_i/gmii_interface/rxdata_bus[*].delay_gmii_rxd}]
# Group IODELAY components
set_property IODELAY_GROUP tri_mode_ethernet_mac_iodelay_grp [get_cells {tri_mode_ethernet_mac_i/gmii_interface/delay_gmii_rx* tri_mode_ethernet_mac_i/gmii_interface/rxdata_bus[*].delay_gmii_rxd}]
set_property IODELAY_GROUP tri_mode_ethernet_mac_iodelay_grp [get_cells  {tri_mode_ethernet_mac_idelayctrl_common_i}]

#
####
#######
##########
#############
#################
#CORE CONSTRAINTS



############################################################
# Crossing of Clock Domain Constraints: please do not edit #
############################################################

# control signal is synced separately so we want a max delay to ensure the signal has settled by the time the control signal has passed through the synch
set_max_delay -from [get_cells {tri_mode_ethernet_mac_i/system_eth_mac_0_core/flow/rx_pause/pause*to_tx_reg[*]}] -to [get_cells {tri_mode_ethernet_mac_i/system_eth_mac_0_core/flow/tx_pause/count_set*reg}] 32 -datapath_only
set_max_delay -from [get_cells {tri_mode_ethernet_mac_i/system_eth_mac_0_core/flow/rx_pause/pause*to_tx_reg[*]}] -to [get_cells {tri_mode_ethernet_mac_i/system_eth_mac_0_core/flow/tx_pause/pause_count*reg[*]}] 32 -datapath_only
set_max_delay -from [get_cells {tri_mode_ethernet_mac_i/system_eth_mac_0_core/flow/rx_pause/pause_req_to_tx_int_reg}] -to [get_cells {tri_mode_ethernet_mac_i/system_eth_mac_0_core/flow/tx_pause/sync_good_rx/data_sync_reg0}] 6 -datapath_only


# ignore paths from the speed control
set_false_path -from [get_cells {tri_mode_ethernet_mac_i/system_eth_mac_0_core/speed*speed_is*100_reg}] -to [get_cells {tri_mode_ethernet_mac_i/clock_inst/BUFGMUX_SPEED_CLK}]
set_false_path -from [get_cells {tri_mode_ethernet_mac_i/system_eth_mac_0_core/speed*speed_is*100_reg}] -to [get_cells {tri_mode_ethernet_mac_i/*xspeedis10100gen/data_sync_reg0}]

# false path due to synced control path
set_max_delay -from [get_cells {tri_mode_ethernet_mac_i/system_eth_mac_0_core/*statistics_counters/rd_data_ref_reg[*]}] -to [get_cells {tri_mode_ethernet_mac_i/system_eth_mac_0_core/*statistics_counters/ip2bus_data_reg[*]}] 6 -datapath_only


############################################################
# Ignore paths to resync flops
############################################################
set_false_path -to [get_pins -hier -filter {NAME =~ */async_rst*/PRE}]
set_false_path -to [get_pins -hier -filter {NAME =~ */reset_sync*/PRE}]
set_max_delay -from [get_cells {tri_mode_ethernet_mac_i/system_eth_mac_0_core/addr_filter_top/addr_regs.promiscuous_mode_reg_reg}] -to [get_cells {tri_mode_ethernet_mac_i/system_eth_mac_0_core/addr_filter_top/address_filter_inst/resync_promiscuous_mode/data_sync_reg0}] 6 -datapath_only
set_max_delay -from [get_cells {tri_mode_ethernet_mac_i/system_eth_mac_0_core/addr_filter_top/addr_regs.filter_enable_reg_reg[*]}] -to [get_cells {tri_mode_ethernet_mac_i/system_eth_mac_0_core/addr_filter_top/address_filter_inst/address_filters[*].sync_enable/data_sync_reg0}] 6 -datapath_only
set_max_delay -from [get_cells {tri_mode_ethernet_mac_i/system_eth_mac_0_core/*managen/conf/update_pause_ad_int_reg}] -to [get_cells {tri_mode_ethernet_mac_i/system_eth_mac_0_core/addr_filter_top/address_filter_inst/sync_update/data_sync_reg0}] 6 -datapath_only

# the mdio interface is clocked from the axi clock but the clock is so slow is can be considered to be data
# the data related outputs are output on the falling edge of the MDC output so both can simply be considered to be multicycle paths
set_multicycle_path 10 -setup -from [get_cells {tri_mode_ethernet_mac_i/system_eth_mac_0_core/*managen/miim_clk_int_reg}  ] -throu [get_ports mdc]
set_multicycle_path 9 -hold -from   [get_cells {tri_mode_ethernet_mac_i/system_eth_mac_0_core/*managen/miim_clk_int_reg}  ] -throu [get_ports mdc]
set_multicycle_path 10 -setup -from [get_cells {tri_mode_ethernet_mac_i/system_eth_mac_0_core/*managen/phy/enable_reg_reg}] -throu [get_ports mdc]
set_multicycle_path 9 -hold -from   [get_cells {tri_mode_ethernet_mac_i/system_eth_mac_0_core/*managen/phy/enable_reg_reg}] -throu [get_ports mdc]
set_multicycle_path 10 -setup -from [get_cells {tri_mode_ethernet_mac_i/system_eth_mac_0_core/*managen/phy/mdio*reg}      ] -throu [get_ports mdio]
set_multicycle_path 9 -hold -from   [get_cells {tri_mode_ethernet_mac_i/system_eth_mac_0_core/*managen/phy/mdio*reg}      ] -throu [get_ports mdio]




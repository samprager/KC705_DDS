set_property BITSTREAM.CONFIG.CONFIGFALLBACK Enable [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN div-1 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE YES [current_design ]
set_property BITSTREAM.config.SPI_opcode 0x6B [current_design ]

set_property LOC L26 [ get_ports SM_FAN_PWM]
set_property IOSTANDARD LVCMOS25 [ get_ports SM_FAN_PWM]

set_property LOC P24 [ get_ports SPI_0_io0_io]
set_property IOSTANDARD LVCMOS25 [ get_ports SPI_0_io0_io]

set_property LOC R25 [ get_ports SPI_0_io1_io]
set_property IOSTANDARD LVCMOS25 [ get_ports SPI_0_io1_io]

set_property LOC R20 [ get_ports SPI_0_io2_io]
set_property IOSTANDARD LVCMOS25 [ get_ports SPI_0_io2_io]

set_property LOC R21 [ get_ports SPI_0_io3_io]
set_property IOSTANDARD LVCMOS25 [ get_ports SPI_0_io3_io]

set_property LOC U19 [ get_ports SPI_0_ss_io]
set_property IOSTANDARD LVCMOS25 [ get_ports SPI_0_ss_io]


#
# additional constraints
#
create_clock -name sys_clk_pin -period "5.0" [get_ports "sys_diff_clock_clk_p"]


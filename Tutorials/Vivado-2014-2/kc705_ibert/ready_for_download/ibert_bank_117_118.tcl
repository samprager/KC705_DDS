start_gui
open_hw
connect_hw_server -host localhost -port 60001 -url localhost:3121
current_hw_target [get_hw_targets */xilinx_tcf/Digilent/*]
set_property PARAM.FREQUENCY 15000000 [get_hw_targets */xilinx_tcf/Digilent/*]
open_hw_target
current_hw_device [lindex [get_hw_devices] 0]
refresh_hw_device -update_hw_probes false [lindex [get_hw_devices] 0]
set_property PROGRAM.FILE {example_ibert_bank_117_118.bit} [lindex [get_hw_devices] 0]
program_hw_devices [lindex [get_hw_devices] 0]
refresh_hw_device [lindex [get_hw_devices] 0]
set xil_newLinks [list]
set xil_newLink [create_hw_sio_link -description {Link 0} [lindex [get_hw_sio_txs localhost/xilinx_tcf/Digilent/*/0_1/IBERT/Quad_117/MGT_X0Y8/TX] 0] [lindex [get_hw_sio_rxs localhost/xilinx_tcf/Digilent/*/0_1/IBERT/Quad_117/MGT_X0Y8/RX] 0] ]
lappend xil_newLinks $xil_newLink
set xil_newLink [create_hw_sio_link -description {Link 1} [lindex [get_hw_sio_txs localhost/xilinx_tcf/Digilent/*/0_1/IBERT/Quad_117/MGT_X0Y9/TX] 0] [lindex [get_hw_sio_rxs localhost/xilinx_tcf/Digilent/*/0_1/IBERT/Quad_117/MGT_X0Y9/RX] 0] ]
lappend xil_newLinks $xil_newLink
set xil_newLink [create_hw_sio_link -description {Link 2} [lindex [get_hw_sio_txs localhost/xilinx_tcf/Digilent/*/0_1/IBERT/Quad_117/MGT_X0Y10/TX] 0] [lindex [get_hw_sio_rxs localhost/xilinx_tcf/Digilent/*/0_1/IBERT/Quad_117/MGT_X0Y10/RX] 0] ]
lappend xil_newLinks $xil_newLink
set xil_newLink [create_hw_sio_link -description {Link 3} [lindex [get_hw_sio_txs localhost/xilinx_tcf/Digilent/*/0_1/IBERT/Quad_117/MGT_X0Y11/TX] 0] [lindex [get_hw_sio_rxs localhost/xilinx_tcf/Digilent/*/0_1/IBERT/Quad_117/MGT_X0Y11/RX] 0] ]
lappend xil_newLinks $xil_newLink
set xil_newLink [create_hw_sio_link -description {Link 4} [lindex [get_hw_sio_txs localhost/xilinx_tcf/Digilent/*/0_1/IBERT/Quad_118/MGT_X0Y12/TX] 0] [lindex [get_hw_sio_rxs localhost/xilinx_tcf/Digilent/*/0_1/IBERT/Quad_118/MGT_X0Y12/RX] 0] ]
lappend xil_newLinks $xil_newLink
set xil_newLink [create_hw_sio_link -description {Link 5} [lindex [get_hw_sio_txs localhost/xilinx_tcf/Digilent/*/0_1/IBERT/Quad_118/MGT_X0Y13/TX] 0] [lindex [get_hw_sio_rxs localhost/xilinx_tcf/Digilent/*/0_1/IBERT/Quad_118/MGT_X0Y13/RX] 0] ]
lappend xil_newLinks $xil_newLink
set xil_newLink [create_hw_sio_link -description {Link 6} [lindex [get_hw_sio_txs localhost/xilinx_tcf/Digilent/*/0_1/IBERT/Quad_118/MGT_X0Y14/TX] 0] [lindex [get_hw_sio_rxs localhost/xilinx_tcf/Digilent/*/0_1/IBERT/Quad_118/MGT_X0Y14/RX] 0] ]
lappend xil_newLinks $xil_newLink
set xil_newLink [create_hw_sio_link -description {Link 7} [lindex [get_hw_sio_txs localhost/xilinx_tcf/Digilent/*/0_1/IBERT/Quad_118/MGT_X0Y15/TX] 0] [lindex [get_hw_sio_rxs localhost/xilinx_tcf/Digilent/*/0_1/IBERT/Quad_118/MGT_X0Y15/RX] 0] ]
lappend xil_newLinks $xil_newLink
set xil_newLinkGroup [create_hw_sio_linkgroup -description {Link Group 0} [get_hw_sio_links $xil_newLinks]]
unset xil_newLinks
set_property TX_PATTERN {PRBS 31-bit} [get_hw_sio_links -of_objects [get_hw_sio_linkgroups {LINKGROUP_0}]]
commit_hw_sio [get_hw_sio_links -of_objects [get_hw_sio_linkgroups {LINKGROUP_0}]]
set_property RX_PATTERN {PRBS 31-bit} [get_hw_sio_links -of_objects [get_hw_sio_linkgroups {LINKGROUP_0}]]
commit_hw_sio [get_hw_sio_links -of_objects [get_hw_sio_linkgroups {LINKGROUP_0}]]
set_property LOOPBACK {Near-End PCS} [get_hw_sio_links -of_objects [get_hw_sio_linkgroups {LINKGROUP_0}]]
commit_hw_sio [get_hw_sio_links -of_objects [get_hw_sio_linkgroups {LINKGROUP_0}]]
set_property LOGIC.MGT_ERRCNT_RESET_CTRL 1 [get_hw_sio_links -of_objects [get_hw_sio_linkgroups {LINKGROUP_0}]]
commit_hw_sio [get_hw_sio_links -of_objects [get_hw_sio_linkgroups {LINKGROUP_0}]]
set_property LOGIC.MGT_ERRCNT_RESET_CTRL 0 [get_hw_sio_links -of_objects [get_hw_sio_linkgroups {LINKGROUP_0}]]
commit_hw_sio [get_hw_sio_links -of_objects [get_hw_sio_linkgroups {LINKGROUP_0}]]

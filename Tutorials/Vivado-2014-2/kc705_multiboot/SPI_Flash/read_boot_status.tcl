proc refresh_boot_status {} {
	refresh_hw_device -update_hw_probes false [lindex [get_hw_devices] 0]
	report_property [lindex [get_hw_devices] 0] -regexp REGISTER.BOOT_STATUS.BIT.*
}

start_gui
open_hw
connect_hw_server -host localhost -port 60001 -url localhost:3121
current_hw_target [get_hw_targets */xilinx_tcf/Digilent/*]
set_property PARAM.FREQUENCY 15000000 [get_hw_targets */xilinx_tcf/Digilent/*]
open_hw_target
current_hw_device [lindex [get_hw_devices] 0]
refresh_boot_status

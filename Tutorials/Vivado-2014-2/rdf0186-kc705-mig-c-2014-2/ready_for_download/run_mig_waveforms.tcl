start_gui
open_hw
connect_hw_server -host localhost -port 60001 -url localhost:3121
current_hw_target [get_hw_targets */xilinx_tcf/Digilent/*]
set_property PARAM.FREQUENCY 15000000 [get_hw_targets */xilinx_tcf/Digilent/*]
open_hw_target
set_property PROGRAM.FILE {example_top.bit} [lindex [get_hw_devices] 0]
set_property PROBES.FILE {debug_nets.ltx} [lindex [get_hw_devices] 0]
current_hw_device [lindex [get_hw_devices] 0]
program_hw_devices [lindex [get_hw_devices] 0]
refresh_hw_device [lindex [get_hw_devices] 0]
reset_hw_vio_outputs [get_hw_vios {hw_vio_1}]
refresh_hw_vio -update_output_values [get_hw_vios {hw_vio_1}]
set_property OUTPUT_VALUE 3 [get_hw_probes vio_addr_mode_value -of_objects [get_hw_vios hw_vio_1]]
commit_hw_vio [get_hw_probes {vio_addr_mode_value} -of_objects [get_hw_vios hw_vio_1]]
set_property OUTPUT_VALUE 7 [get_hw_probes vio_data_mode_value -of_objects [get_hw_vios hw_vio_1]]
commit_hw_vio [get_hw_probes {vio_data_mode_value} -of_objects [get_hw_vios hw_vio_1]]
set_property OUTPUT_VALUE 2 [get_hw_probes vio_instr_mode_value -of_objects [get_hw_vios hw_vio_1]]
commit_hw_vio [get_hw_probes {vio_instr_mode_value} -of_objects [get_hw_vios hw_vio_1]]
set_property OUTPUT_VALUE 2 [get_hw_probes vio_bl_mode_value -of_objects [get_hw_vios hw_vio_1]]
commit_hw_vio [get_hw_probes {vio_bl_mode_value} -of_objects [get_hw_vios hw_vio_1]]
set_property OUTPUT_VALUE 010 [get_hw_probes vio_fixed_bl_value -of_objects [get_hw_vios hw_vio_1]]
commit_hw_vio [get_hw_probes {vio_fixed_bl_value} -of_objects [get_hw_vios hw_vio_1]]
set_property OUTPUT_VALUE 0 [get_hw_probes vio_data_mask_gen -of_objects [get_hw_vios hw_vio_1]]
commit_hw_vio [get_hw_probes {vio_data_mask_gen} -of_objects [get_hw_vios hw_vio_1]]
set_property OUTPUT_VALUE 1 [get_hw_probes vio_fixed_instr_value -of_objects [get_hw_vios hw_vio_1]]
commit_hw_vio [get_hw_probes {vio_fixed_instr_value} -of_objects [get_hw_vios hw_vio_1]]
run_hw_ila hw_ila_1 -trigger_now
wait_on_hw_ila hw_ila_1
display_hw_ila_data -wcfg {hw_ila_data_1.wcfg} [upload_hw_ila_data hw_ila_1]

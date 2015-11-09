# 
# Synthesis run script generated by Vivado
# 

set_msg_config -id {HDL 9-1061} -limit 100000
set_msg_config -id {HDL 9-1654} -limit 100000
create_project -in_memory -part xc7k325tffg900-2
set_property target_language Verilog [current_project]
set_property board_part xilinx.com:kc705:part0:1.0 [current_project]
set_param project.compositeFile.enableAutoGeneration 0
set_property default_lib xil_defaultlib [current_project]

read_ip C:/kc705_ibert/ibert_bank_115_116/ibert_bank_115_116_example/ibert_bank_115_116_example.srcs/sources_1/ip/ibert_bank_115_116/ibert_bank_115_116.xci
set_msg_config -id {IP_Flow 19-2162} -severity warning -new_severity info
set_property is_locked true [get_files C:/kc705_ibert/ibert_bank_115_116/ibert_bank_115_116_example/ibert_bank_115_116_example.srcs/sources_1/ip/ibert_bank_115_116/ibert_bank_115_116.xci]

read_verilog -library xil_defaultlib C:/kc705_ibert/ibert_bank_115_116/ibert_bank_115_116_example/ibert_bank_115_116_example.srcs/sources_1/imports/example_design/example_ibert_bank_115_116.v
read_xdc C:/kc705_ibert/ibert_bank_115_116/ibert_bank_115_116_example/ibert_bank_115_116_example.srcs/constrs_1/imports/example_design/example_ibert_bank_115_116.xdc
set_property used_in_implementation false [get_files C:/kc705_ibert/ibert_bank_115_116/ibert_bank_115_116_example/ibert_bank_115_116_example.srcs/constrs_1/imports/example_design/example_ibert_bank_115_116.xdc]

read_xdc dont_touch.xdc
set_property used_in_implementation false [get_files dont_touch.xdc]
set_param synth.vivado.isSynthRun true
set_property webtalk.parent_dir C:/kc705_ibert/ibert_bank_115_116/ibert_bank_115_116_example/ibert_bank_115_116_example.cache/wt [current_project]
set_property parent.project_dir C:/kc705_ibert/ibert_bank_115_116/ibert_bank_115_116_example [current_project]
catch { write_hwdef -file example_ibert_bank_115_116.hwdef }
synth_design -top example_ibert_bank_115_116 -part xc7k325tffg900-2
write_checkpoint example_ibert_bank_115_116.dcp
report_utilization -file example_ibert_bank_115_116_utilization_synth.rpt -pb example_ibert_bank_115_116_utilization_synth.pb

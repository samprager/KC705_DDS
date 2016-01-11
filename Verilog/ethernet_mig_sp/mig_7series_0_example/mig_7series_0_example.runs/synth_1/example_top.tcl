# 
# Synthesis run script generated by Vivado
# 

  set_param gui.test TreeTableDev
set_msg_config -id {HDL 9-1061} -limit 100000
set_msg_config -id {HDL 9-1654} -limit 100000
create_project -in_memory -part xc7k325tffg900-2
set_property target_language Verilog [current_project]
set_property board_part xilinx.com:kc705:part0:1.0 [current_project]
set_param project.compositeFile.enableAutoGeneration 0
set_property default_lib xil_defaultlib [current_project]
add_files -quiet {{C:/Users/Sam/Vivado Projects/ethernet_mig_sp/mig_7series_0_example/mig_7series_0_example.runs/mig_7series_0_synth_1/mig_7series_0.dcp}}
set_property used_in_implementation false [get_files {{C:/Users/Sam/Vivado Projects/ethernet_mig_sp/mig_7series_0_example/mig_7series_0_example.runs/mig_7series_0_synth_1/mig_7series_0.dcp}}]
read_verilog -library xil_defaultlib {
  {C:/Users/Sam/Vivado Projects/ethernet_mig_sp/mig_7series_0_example/mig_7series_0_example.srcs/sources_1/imports/rtl/traffic_gen/mig_7series_v2_1_data_gen_chk.v}
  {C:/Users/Sam/Vivado Projects/ethernet_mig_sp/mig_7series_0_example/mig_7series_0_example.srcs/sources_1/imports/rtl/traffic_gen/mig_7series_v2_1_cmd_prbs_gen_axi.v}
  {C:/Users/Sam/Vivado Projects/ethernet_mig_sp/mig_7series_0_example/mig_7series_0_example.srcs/sources_1/imports/rtl/traffic_gen/mig_7series_v2_1_tg.v}
  {C:/Users/Sam/Vivado Projects/ethernet_mig_sp/mig_7series_0_example/mig_7series_0_example.srcs/sources_1/imports/rtl/traffic_gen/mig_7series_v2_1_axi4_wrapper.v}
  {C:/Users/Sam/Vivado Projects/ethernet_mig_sp/mig_7series_0_example/mig_7series_0_example.srcs/sources_1/imports/rtl/traffic_gen/mig_7series_v2_1_axi4_tg.v}
  {C:/Users/Sam/Vivado Projects/ethernet_mig_sp/mig_7series_0_example/mig_7series_0_example.srcs/sources_1/imports/rtl/example_top.v}
}
read_xdc {{C:/Users/Sam/Vivado Projects/ethernet_mig_sp/mig_7series_0_example/mig_7series_0_example.srcs/constrs_1/imports/par/example_top.xdc}}
set_property used_in_implementation false [get_files {{C:/Users/Sam/Vivado Projects/ethernet_mig_sp/mig_7series_0_example/mig_7series_0_example.srcs/constrs_1/imports/par/example_top.xdc}}]
set_property processing_order EARLY [get_files {{C:/Users/Sam/Vivado Projects/ethernet_mig_sp/mig_7series_0_example/mig_7series_0_example.srcs/constrs_1/imports/par/example_top.xdc}}]

read_xdc dont_buffer.xdc
set_property used_in_implementation false [get_files dont_buffer.xdc]
set_param synth.vivado.isSynthRun true
set_property webtalk.parent_dir {C:/Users/Sam/Vivado Projects/ethernet_mig_sp/mig_7series_0_example/mig_7series_0_example.cache/wt} [current_project]
set_property parent.project_dir {C:/Users/Sam/Vivado Projects/ethernet_mig_sp/mig_7series_0_example} [current_project]
catch { write_hwdef -file example_top.hwdef }
synth_design -top example_top -part xc7k325tffg900-2
write_checkpoint example_top.dcp
report_utilization -file example_top_utilization_synth.rpt -pb example_top_utilization_synth.pb
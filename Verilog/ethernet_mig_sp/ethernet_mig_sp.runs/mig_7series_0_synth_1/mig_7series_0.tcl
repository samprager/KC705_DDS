# 
# Synthesis run script generated by Vivado
# 

  set_param gui.test TreeTableDev
set_msg_config -id {HDL 9-1061} -limit 100000
set_msg_config -id {HDL 9-1654} -limit 100000
set_msg_config -id {Synth 8-256} -limit 10000
set_msg_config -id {Synth 8-638} -limit 10000
create_project -in_memory -part xc7k325tffg900-2
set_property target_language Verilog [current_project]
set_property board_part xilinx.com:kc705:part0:1.0 [current_project]
set_param project.compositeFile.enableAutoGeneration 0
set_property default_lib xil_defaultlib [current_project]

read_ip {{C:/Users/Sam/Vivado Projects/ethernet_mig_sp/ethernet_mig_sp.srcs/sources_1/ip/mig_7series_0/mig_7series_0.xci}}
set_property used_in_implementation false [get_files {{c:/Users/Sam/Vivado Projects/ethernet_mig_sp/ethernet_mig_sp.srcs/sources_1/ip/mig_7series_0/mig_7series_0.dcp}}]
set_property used_in_implementation false [get_files -all {{c:/Users/Sam/Vivado Projects/ethernet_mig_sp/ethernet_mig_sp.srcs/sources_1/ip/mig_7series_0/mig_7series_0.dcp}}]
set_msg_config -id {IP_Flow 19-2162} -severity warning -new_severity info
set_property is_locked true [get_files {{C:/Users/Sam/Vivado Projects/ethernet_mig_sp/ethernet_mig_sp.srcs/sources_1/ip/mig_7series_0/mig_7series_0.xci}}]

set_param synth.vivado.isSynthRun true
set_property webtalk.parent_dir {C:/Users/Sam/Vivado Projects/ethernet_mig_sp/ethernet_mig_sp.cache/wt} [current_project]
set_property parent.project_dir {C:/Users/Sam/Vivado Projects/ethernet_mig_sp} [current_project]
catch { write_hwdef -file mig_7series_0.hwdef }
synth_design -top mig_7series_0 -part xc7k325tffg900-2 -mode out_of_context

rename_ref -prefix_all mig_7series_0_
write_checkpoint -noxdef mig_7series_0.dcp
report_utilization -file mig_7series_0_utilization_synth.rpt -pb mig_7series_0_utilization_synth.pb
if { [catch {
  file copy -force {C:/Users/Sam/Vivado Projects/ethernet_mig_sp/ethernet_mig_sp.runs/mig_7series_0_synth_1/mig_7series_0.dcp} {C:/Users/Sam/Vivado Projects/ethernet_mig_sp/ethernet_mig_sp.srcs/sources_1/ip/mig_7series_0/mig_7series_0.dcp}
  write_verilog -force -mode synth_stub {C:/Users/Sam/Vivado Projects/ethernet_mig_sp/ethernet_mig_sp.srcs/sources_1/ip/mig_7series_0/mig_7series_0_stub.v}
  write_vhdl -force -mode synth_stub {C:/Users/Sam/Vivado Projects/ethernet_mig_sp/ethernet_mig_sp.srcs/sources_1/ip/mig_7series_0/mig_7series_0_stub.vhdl}
  write_verilog -force -mode funcsim {C:/Users/Sam/Vivado Projects/ethernet_mig_sp/ethernet_mig_sp.srcs/sources_1/ip/mig_7series_0/mig_7series_0_funcsim.v}
  write_vhdl -force -mode funcsim {C:/Users/Sam/Vivado Projects/ethernet_mig_sp/ethernet_mig_sp.srcs/sources_1/ip/mig_7series_0/mig_7series_0_funcsim.vhdl}
} _RESULT ] } { 
  send_msg_id runtcl-3 error "Unable to successfully create or copy supporting IP files."
  return -code error
}

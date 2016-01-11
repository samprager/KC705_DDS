# 
# Synthesis run script generated by Vivado
# 

  set_param gui.test TreeTableDev
set_msg_config -id {HDL 9-1061} -limit 100000
set_msg_config -id {HDL 9-1654} -limit 100000
create_project -in_memory -part xc7k325tffg900-2
set_property target_language VHDL [current_project]
set_param project.compositeFile.enableAutoGeneration 0
set_property default_lib xil_defaultlib [current_project]

read_ip C:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.srcs/sources_1/ip/blk_mem_gen_v6_3_0/dac3283_init_mem.xci
set_msg_config -id {IP_Flow 19-2162} -severity warning -new_severity info
set_property is_locked true [get_files C:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.srcs/sources_1/ip/blk_mem_gen_v6_3_0/dac3283_init_mem.xci]

set_param synth.vivado.isSynthRun true
set_property webtalk.parent_dir C:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.cache/wt [current_project]
set_property parent.project_dir C:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado [current_project]
catch { write_hwdef -file dac3283_init_mem.hwdef }
synth_design -top dac3283_init_mem -part xc7k325tffg900-2 -mode out_of_context

rename_ref -prefix_all dac3283_init_mem_
write_checkpoint -noxdef dac3283_init_mem.dcp
report_utilization -file dac3283_init_mem_utilization_synth.rpt -pb dac3283_init_mem_utilization_synth.pb
if { [catch {
  file copy -force C:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.runs/dac3283_init_mem_synth_1/dac3283_init_mem.dcp C:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.srcs/sources_1/ip/blk_mem_gen_v6_3_0/dac3283_init_mem.dcp
  write_verilog -force -mode synth_stub C:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.srcs/sources_1/ip/blk_mem_gen_v6_3_0/dac3283_init_mem_stub.v
  write_vhdl -force -mode synth_stub C:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.srcs/sources_1/ip/blk_mem_gen_v6_3_0/dac3283_init_mem_stub.vhdl
  write_verilog -force -mode funcsim C:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.srcs/sources_1/ip/blk_mem_gen_v6_3_0/dac3283_init_mem_funcsim.v
  write_vhdl -force -mode funcsim C:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.srcs/sources_1/ip/blk_mem_gen_v6_3_0/dac3283_init_mem_funcsim.vhdl
} _RESULT ] } { 
  send_msg_id runtcl-3 error "Unable to successfully create or copy supporting IP files."
  return -code error
}

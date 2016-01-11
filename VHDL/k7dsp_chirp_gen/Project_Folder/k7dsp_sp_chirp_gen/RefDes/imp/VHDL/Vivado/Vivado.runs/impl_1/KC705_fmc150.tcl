proc start_step { step } {
  set stopFile ".stop.rst"
  if {[file isfile .stop.rst]} {
    puts ""
    puts "*** Halting run - EA reset detected ***"
    puts ""
    puts ""
    return -code error
  }
  set beginFile ".$step.begin.rst"
  set platform "$::tcl_platform(platform)"
  set user "$::tcl_platform(user)"
  set pid [pid]
  set host ""
  if { [string equal $platform unix] } {
    if { [info exist ::env(HOSTNAME)] } {
      set host $::env(HOSTNAME)
    }
  } else {
    if { [info exist ::env(COMPUTERNAME)] } {
      set host $::env(COMPUTERNAME)
    }
  }
  set ch [open $beginFile w]
  puts $ch "<?xml version=\"1.0\"?>"
  puts $ch "<ProcessHandle Version=\"1\" Minor=\"0\">"
  puts $ch "    <Process Command=\".planAhead.\" Owner=\"$user\" Host=\"$host\" Pid=\"$pid\">"
  puts $ch "    </Process>"
  puts $ch "</ProcessHandle>"
  close $ch
}

proc end_step { step } {
  set endFile ".$step.end.rst"
  set ch [open $endFile w]
  close $ch
}

proc step_failed { step } {
  set endFile ".$step.error.rst"
  set ch [open $endFile w]
  close $ch
}

set_msg_config -id {HDL 9-1061} -limit 100000
set_msg_config -id {HDL 9-1654} -limit 100000
set_msg_config -id {Labtools 27-147} -limit 4294967295

start_step init_design
set rc [catch {
  create_msg_db init_design.pb
  set_param gui.test TreeTableDev
  set_param xicom.use_bs_reader 1
  set_property design_mode GateLvl [current_fileset]
  set_property webtalk.parent_dir C:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.cache/wt [current_project]
  set_property parent.project_dir C:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado [current_project]
  add_files -quiet C:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.runs/synth_1/KC705_fmc150.dcp
  add_files -quiet C:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.runs/SP_DDS_synth_1/SP_DDS.dcp
  set_property netlist_only true [get_files C:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.runs/SP_DDS_synth_1/SP_DDS.dcp]
  add_files -quiet C:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.runs/ddc_imf1_synth_1/ddc_imf1.dcp
  set_property netlist_only true [get_files C:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.runs/ddc_imf1_synth_1/ddc_imf1.dcp]
  add_files -quiet C:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.runs/complex_multiplier_DUC_synth_1/complex_multiplier_DUC.dcp
  set_property netlist_only true [get_files C:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.runs/complex_multiplier_DUC_synth_1/complex_multiplier_DUC.dcp]
  add_files -quiet C:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.runs/dds_ddc_synth_1/dds_ddc.dcp
  set_property netlist_only true [get_files C:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.runs/dds_ddc_synth_1/dds_ddc.dcp]
  add_files -quiet C:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.runs/dds_duc_synth_1/dds_duc.dcp
  set_property netlist_only true [get_files C:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.runs/dds_duc_synth_1/dds_duc.dcp]
  add_files -quiet C:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.runs/complex_multiplier_synth_1/complex_multiplier.dcp
  set_property netlist_only true [get_files C:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.runs/complex_multiplier_synth_1/complex_multiplier.dcp]
  add_files -quiet C:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.runs/ddc_imf2_synth_1/ddc_imf2.dcp
  set_property netlist_only true [get_files C:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.runs/ddc_imf2_synth_1/ddc_imf2.dcp]
  add_files -quiet C:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.runs/ddc_srrc_synth_1/ddc_srrc.dcp
  set_property netlist_only true [get_files C:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.runs/ddc_srrc_synth_1/ddc_srrc.dcp]
  add_files -quiet C:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.runs/duc_imf1_synth_1/duc_imf1.dcp
  set_property netlist_only true [get_files C:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.runs/duc_imf1_synth_1/duc_imf1.dcp]
  add_files -quiet C:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.runs/duc_imf2_synth_1/duc_imf2.dcp
  set_property netlist_only true [get_files C:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.runs/duc_imf2_synth_1/duc_imf2.dcp]
  add_files -quiet C:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.runs/duc_imf3_synth_1/duc_imf3.dcp
  set_property netlist_only true [get_files C:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.runs/duc_imf3_synth_1/duc_imf3.dcp]
  add_files -quiet C:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.runs/duc_srrc_synth_1/duc_srrc.dcp
  set_property netlist_only true [get_files C:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.runs/duc_srrc_synth_1/duc_srrc.dcp]
  add_files -quiet C:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.runs/ads62p49_init_mem_synth_1/ads62p49_init_mem.dcp
  set_property netlist_only true [get_files C:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.runs/ads62p49_init_mem_synth_1/ads62p49_init_mem.dcp]
  add_files -quiet C:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.runs/amc7823_init_mem_synth_1/amc7823_init_mem.dcp
  set_property netlist_only true [get_files C:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.runs/amc7823_init_mem_synth_1/amc7823_init_mem.dcp]
  add_files -quiet C:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.runs/cdce72010_init_mem_ext_synth_1/cdce72010_init_mem_ext.dcp
  set_property netlist_only true [get_files C:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.runs/cdce72010_init_mem_ext_synth_1/cdce72010_init_mem_ext.dcp]
  add_files -quiet C:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.runs/cdce72010_init_mem_int_synth_1/cdce72010_init_mem_int.dcp
  set_property netlist_only true [get_files C:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.runs/cdce72010_init_mem_int_synth_1/cdce72010_init_mem_int.dcp]
  add_files -quiet C:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.runs/dac3283_init_mem_synth_1/dac3283_init_mem.dcp
  set_property netlist_only true [get_files C:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.runs/dac3283_init_mem_synth_1/dac3283_init_mem.dcp]
  add_files -quiet C:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.runs/DDS_synth_1/DDS.dcp
  set_property netlist_only true [get_files C:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.runs/DDS_synth_1/DDS.dcp]
  read_xdc -ref vio -cells inst c:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.srcs/sources_1/ip/vio/vio.xdc
  set_property processing_order EARLY [get_files c:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.srcs/sources_1/ip/vio/vio.xdc]
  read_xdc -ref mmcm_adac -cells U0 c:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.srcs/sources_1/ip/mmcm_adac/mmcm_adac.xdc
  set_property processing_order EARLY [get_files c:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.srcs/sources_1/ip/mmcm_adac/mmcm_adac.xdc]
  read_xdc -prop_thru_buffers -ref mmcm_adac -cells U0 c:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.srcs/sources_1/ip/mmcm_adac/mmcm_adac_board.xdc
  set_property processing_order EARLY [get_files c:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.srcs/sources_1/ip/mmcm_adac/mmcm_adac_board.xdc]
  read_xdc -ref mmcm -cells U0 c:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.srcs/sources_1/ip/mmcm/mmcm.xdc
  set_property processing_order EARLY [get_files c:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.srcs/sources_1/ip/mmcm/mmcm.xdc]
  read_xdc -prop_thru_buffers -ref mmcm -cells U0 c:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.srcs/sources_1/ip/mmcm/mmcm_board.xdc
  set_property processing_order EARLY [get_files c:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.srcs/sources_1/ip/mmcm/mmcm_board.xdc]
  read_xdc -ref ila c:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.srcs/sources_1/ip/ila/constraints/ila.xdc
  set_property processing_order EARLY [get_files c:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.srcs/sources_1/ip/ila/constraints/ila.xdc]
  read_xdc -mode out_of_context -ref SP_DDS -cells U0 c:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.srcs/sources_1/ip/SP_DDS/SP_DDS_ooc.xdc
  set_property processing_order EARLY [get_files c:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.srcs/sources_1/ip/SP_DDS/SP_DDS_ooc.xdc]
  read_xdc -mode out_of_context -ref ddc_imf1 -cells U0 c:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.srcs/sources_1/ip/fir_compiler_v6_3_6/ddc_imf1_ooc.xdc
  set_property processing_order EARLY [get_files c:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.srcs/sources_1/ip/fir_compiler_v6_3_6/ddc_imf1_ooc.xdc]
  read_xdc -mode out_of_context -ref complex_multiplier_DUC -cells U0 c:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.srcs/sources_1/ip/cmpy_v5_0_0/complex_multiplier_DUC_ooc.xdc
  set_property processing_order EARLY [get_files c:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.srcs/sources_1/ip/cmpy_v5_0_0/complex_multiplier_DUC_ooc.xdc]
  read_xdc -mode out_of_context -ref dds_ddc -cells U0 c:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.srcs/sources_1/ip/dds_compiler_v5_0_1/dds_ddc_ooc.xdc
  set_property processing_order EARLY [get_files c:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.srcs/sources_1/ip/dds_compiler_v5_0_1/dds_ddc_ooc.xdc]
  read_xdc -mode out_of_context -ref dds_duc -cells U0 c:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.srcs/sources_1/ip/dds_compiler_v5_0_0/dds_duc_ooc.xdc
  set_property processing_order EARLY [get_files c:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.srcs/sources_1/ip/dds_compiler_v5_0_0/dds_duc_ooc.xdc]
  read_xdc -mode out_of_context -ref complex_multiplier -cells U0 c:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.srcs/sources_1/ip/cmpy_v5_0_1/complex_multiplier_ooc.xdc
  set_property processing_order EARLY [get_files c:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.srcs/sources_1/ip/cmpy_v5_0_1/complex_multiplier_ooc.xdc]
  read_xdc -mode out_of_context -ref ddc_imf2 -cells U0 c:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.srcs/sources_1/ip/fir_compiler_v6_3_5/ddc_imf2_ooc.xdc
  set_property processing_order EARLY [get_files c:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.srcs/sources_1/ip/fir_compiler_v6_3_5/ddc_imf2_ooc.xdc]
  read_xdc -mode out_of_context -ref ddc_srrc -cells U0 c:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.srcs/sources_1/ip/fir_compiler_v6_3_4/ddc_srrc_ooc.xdc
  set_property processing_order EARLY [get_files c:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.srcs/sources_1/ip/fir_compiler_v6_3_4/ddc_srrc_ooc.xdc]
  read_xdc -mode out_of_context -ref duc_imf1 -cells U0 c:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.srcs/sources_1/ip/fir_compiler_v6_3_3/duc_imf1_ooc.xdc
  set_property processing_order EARLY [get_files c:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.srcs/sources_1/ip/fir_compiler_v6_3_3/duc_imf1_ooc.xdc]
  read_xdc -mode out_of_context -ref duc_imf2 -cells U0 c:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.srcs/sources_1/ip/fir_compiler_v6_3_2/duc_imf2_ooc.xdc
  set_property processing_order EARLY [get_files c:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.srcs/sources_1/ip/fir_compiler_v6_3_2/duc_imf2_ooc.xdc]
  read_xdc -mode out_of_context -ref duc_imf3 -cells U0 c:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.srcs/sources_1/ip/fir_compiler_v6_3_1/duc_imf3_ooc.xdc
  set_property processing_order EARLY [get_files c:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.srcs/sources_1/ip/fir_compiler_v6_3_1/duc_imf3_ooc.xdc]
  read_xdc -mode out_of_context -ref duc_srrc -cells U0 c:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.srcs/sources_1/ip/fir_compiler_v6_3_0/duc_srrc_ooc.xdc
  set_property processing_order EARLY [get_files c:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.srcs/sources_1/ip/fir_compiler_v6_3_0/duc_srrc_ooc.xdc]
  read_xdc -mode out_of_context -ref ads62p49_init_mem c:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.srcs/sources_1/ip/blk_mem_gen_v6_3_4/ads62p49_init_mem_ooc.xdc
  set_property processing_order EARLY [get_files c:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.srcs/sources_1/ip/blk_mem_gen_v6_3_4/ads62p49_init_mem_ooc.xdc]
  read_xdc -mode out_of_context -ref amc7823_init_mem c:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.srcs/sources_1/ip/blk_mem_gen_v6_3_3/amc7823_init_mem_ooc.xdc
  set_property processing_order EARLY [get_files c:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.srcs/sources_1/ip/blk_mem_gen_v6_3_3/amc7823_init_mem_ooc.xdc]
  read_xdc -mode out_of_context -ref cdce72010_init_mem_ext c:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.srcs/sources_1/ip/blk_mem_gen_v6_3_2/cdce72010_init_mem_ext_ooc.xdc
  set_property processing_order EARLY [get_files c:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.srcs/sources_1/ip/blk_mem_gen_v6_3_2/cdce72010_init_mem_ext_ooc.xdc]
  read_xdc -mode out_of_context -ref cdce72010_init_mem_int c:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.srcs/sources_1/ip/blk_mem_gen_v6_3_1/cdce72010_init_mem_int_ooc.xdc
  set_property processing_order EARLY [get_files c:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.srcs/sources_1/ip/blk_mem_gen_v6_3_1/cdce72010_init_mem_int_ooc.xdc]
  read_xdc -mode out_of_context -ref dac3283_init_mem c:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.srcs/sources_1/ip/blk_mem_gen_v6_3_0/dac3283_init_mem_ooc.xdc
  set_property processing_order EARLY [get_files c:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.srcs/sources_1/ip/blk_mem_gen_v6_3_0/dac3283_init_mem_ooc.xdc]
  read_xdc -mode out_of_context -ref DDS -cells U0 c:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.srcs/sources_1/ip/dds_compiler_v5_0_2/DDS_ooc.xdc
  set_property processing_order EARLY [get_files c:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.srcs/sources_1/ip/dds_compiler_v5_0_2/DDS_ooc.xdc]
  read_xdc C:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.srcs/constrs_1/imports/k7_TRD/k7dsp_rtl_tutorial.xdc
  link_design -top KC705_fmc150 -part xc7k325tffg900-2
  close_msg_db -file init_design.pb
} RESULT]
if {$rc} {
  step_failed init_design
  return -code error $RESULT
} else {
  end_step init_design
}

start_step opt_design
set rc [catch {
  create_msg_db opt_design.pb
  catch {write_debug_probes -quiet -force debug_nets}
  catch {update_ip_catalog -quiet -current_ip_cache {c:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.cache} }
  opt_design 
  write_checkpoint -force KC705_fmc150_opt.dcp
  close_msg_db -file opt_design.pb
} RESULT]
if {$rc} {
  step_failed opt_design
  return -code error $RESULT
} else {
  end_step opt_design
}

start_step place_design
set rc [catch {
  create_msg_db place_design.pb
  place_design 
  write_checkpoint -force KC705_fmc150_placed.dcp
  catch { report_io -file KC705_fmc150_io_placed.rpt }
  catch { report_clock_utilization -file KC705_fmc150_clock_utilization_placed.rpt }
  catch { report_utilization -file KC705_fmc150_utilization_placed.rpt -pb KC705_fmc150_utilization_placed.pb }
  catch { report_control_sets -verbose -file KC705_fmc150_control_sets_placed.rpt }
  close_msg_db -file place_design.pb
} RESULT]
if {$rc} {
  step_failed place_design
  return -code error $RESULT
} else {
  end_step place_design
}

start_step route_design
set rc [catch {
  create_msg_db route_design.pb
  route_design 
  write_checkpoint -force KC705_fmc150_routed.dcp
  catch { report_drc -file KC705_fmc150_drc_routed.rpt -pb KC705_fmc150_drc_routed.pb }
  catch { report_timing_summary -warn_on_violation -file KC705_fmc150_timing_summary_routed.rpt -pb KC705_fmc150_timing_summary_routed.pb }
  catch { report_power -file KC705_fmc150_power_routed.rpt -pb KC705_fmc150_power_summary_routed.pb }
  catch { report_route_status -file KC705_fmc150_route_status.rpt -pb KC705_fmc150_route_status.pb }
  close_msg_db -file route_design.pb
} RESULT]
if {$rc} {
  step_failed route_design
  return -code error $RESULT
} else {
  end_step route_design
}

start_step write_bitstream
set rc [catch {
  create_msg_db write_bitstream.pb
  write_bitstream -force KC705_fmc150.bit 
  if { [file exists C:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.runs/synth_1/KC705_fmc150.hwdef] } {
    catch { write_sysdef -hwdef C:/k7dsp_rtl_tut_sp_edit_v2/k7dsp_rtl_tut/RTL/RefDes/imp/VHDL/Vivado/Vivado.runs/synth_1/KC705_fmc150.hwdef -bitfile KC705_fmc150.bit -meminfo KC705_fmc150_bd.bmm -file KC705_fmc150.sysdef }
  }
  close_msg_db -file write_bitstream.pb
} RESULT]
if {$rc} {
  step_failed write_bitstream
  return -code error $RESULT
} else {
  end_step write_bitstream
}


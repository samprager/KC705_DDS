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

start_step init_design
set rc [catch {
  create_msg_db init_design.pb
  set_param gui.test TreeTableDev
  open_checkpoint -netlist_only C:/GitRepos/KC705_DDS/Verilog/ethernet_mig_sp/ethernet_mig_sp.runs/mig_7series_0_synth_1/mig_7series_0.dcp
  set_property webtalk.parent_dir C:/GitRepos/KC705_DDS/Verilog/ethernet_mig_sp/ethernet_mig_sp.cache/wt [current_project]
  set_property parent.project_dir C:/GitRepos/KC705_DDS/Verilog/ethernet_mig_sp [current_project]
  read_xdc -mode out_of_context -ref mig_7series_0 c:/GitRepos/KC705_DDS/Verilog/ethernet_mig_sp/ethernet_mig_sp.srcs/sources_1/ip/mig_7series_0/mig_7series_0/user_design/constraints/mig_7series_0_ooc.xdc
  set_property processing_order EARLY [get_files c:/GitRepos/KC705_DDS/Verilog/ethernet_mig_sp/ethernet_mig_sp.srcs/sources_1/ip/mig_7series_0/mig_7series_0/user_design/constraints/mig_7series_0_ooc.xdc]
  read_xdc -ref mig_7series_0 c:/GitRepos/KC705_DDS/Verilog/ethernet_mig_sp/ethernet_mig_sp.srcs/sources_1/ip/mig_7series_0/mig_7series_0/user_design/constraints/mig_7series_0.xdc
  set_property processing_order EARLY [get_files c:/GitRepos/KC705_DDS/Verilog/ethernet_mig_sp/ethernet_mig_sp.srcs/sources_1/ip/mig_7series_0/mig_7series_0/user_design/constraints/mig_7series_0.xdc]
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
  catch {update_ip_catalog -quiet -current_ip_cache {c:/GitRepos/KC705_DDS/Verilog/ethernet_mig_sp/ethernet_mig_sp.cache} }
  opt_design 
  write_checkpoint -force mig_7series_0_opt.dcp
  close_msg_db -file opt_design.pb
} RESULT]
if {$rc} {
  step_failed opt_design
  return -code error $RESULT
} else {
  end_step opt_design
}


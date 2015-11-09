open_project C:/kc705_bist/kc705_bist.xpr
open_run impl_1
remove_files -quiet {*.elf}
add_files -norecurse C:/kc705_bist/kc705_bist.sdk/bist_app/Debug/bist_app.elf
set_property MEMDATA.ADDR_MAP_CELLS {{system_i/microblaze_0}} [get_files -all -of_objects [get_fileset sources_1] {C:/kc705_bist/kc705_bist.sdk/bist_app/Debug/bist_app.elf}]
write_bitstream -force C:/kc705_bist/ready_for_download/bist_app.bit
remove_files {C:/kc705_bist/kc705_bist.sdk/bist_app/Debug/bist_app.elf}
add_files -norecurse C:/kc705_bist/kc705_bist.sdk/lwip_echo_server/Debug/lwip_echo_server.elf
set_property MEMDATA.ADDR_MAP_CELLS {{system_i/microblaze_0}} [get_files -all -of_objects [get_fileset sources_1] {C:/kc705_bist/kc705_bist.sdk/lwip_echo_server/Debug/lwip_echo_server.elf}]
write_bitstream -force C:/kc705_bist/ready_for_download/lwip_echo_server.bit
remove_files {C:/kc705_bist/kc705_bist.sdk/lwip_echo_server/Debug/lwip_echo_server.elf}
close_project
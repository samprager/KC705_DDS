open_project C:/kc705_multiboot/kc705_multiboot.xpr
open_run impl_1
remove_files -quiet {*.elf}
add_files -norecurse {C:/kc705_multiboot/kc705_multiboot.sdk/golden_iprog_spi/Debug/golden_iprog_spi.elf}
set_property MEMDATA.ADDR_MAP_CELLS {{system_i/microblaze_0}} [get_files -all -of_objects [get_fileset sources_1] {C:\kc705_multiboot\kc705_multiboot.sdk\golden_iprog_spi\Debug\golden_iprog_spi.elf}]
write_bitstream -force C:/kc705_multiboot/SPI_Flash/golden_iprog_spi.bit
remove_files {C:\kc705_multiboot\kc705_multiboot.sdk\golden_iprog_spi\Debug\golden_iprog_spi.elf}
add_files -norecurse {C:/kc705_multiboot/kc705_multiboot.sdk/multiboot/Debug/multiboot.elf}
set_property MEMDATA.ADDR_MAP_CELLS {{system_i/microblaze_0}} [get_files -all -of_objects [get_fileset sources_1] {C:\kc705_multiboot\kc705_multiboot.sdk\multiboot\Debug\multiboot.elf}]
write_bitstream -force C:/kc705_multiboot/SPI_Flash/multiboot.bit
remove_files {C:/kc705_multiboot/kc705_multiboot.sdk/multiboot/Debug/multiboot.elf}
close_project
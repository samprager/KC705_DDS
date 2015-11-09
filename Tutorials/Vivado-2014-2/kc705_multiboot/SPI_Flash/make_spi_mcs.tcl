write_cfgmem -force -format MCS -size 128 -interface SPIx4 -loadbit "up 0x00000000 golden_iprog_spi.bit up 0x00400000 multiboot.bit up 0x00800000 corrupted.bit" kc705_multiboot_spi.mcs

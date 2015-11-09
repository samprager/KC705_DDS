# Vivado Launch Script

#### Change design settings here #######
set design k7_pcie_dma_ddr3_base_x4_gen1
set top k7_pcie_dma_ddr3_base
set device xc7k325t-2-ffg900
set proj_dir vivado_proj_1
#set synth_constraints ./k7_pcie_dma_ddr3_base_x4_gen1_synth.xdc
set impl_constraints ./k7_pcie_dma_ddr3_base_x4_gen1.xdc
########################################

# Project Settings
create_project -name ${design} -force -dir "./${proj_dir}" -part ${device}
set_property top ${top} [current_fileset]
set_property verilog_define { {RDS=1} {PCIEx4=1} {USE_KC705=1} {USE_DDR3_FIFO=1} {USE_7SERIES=1} } [current_fileset]

# Project Constraints

add_files -fileset constrs_1 -norecurse ./${impl_constraints}
set_property used_in_synthesis true [get_files  ./${impl_constraints}]

#add_files -fileset constrs_1 -norecurse ./${synth_constraints}
#set_property used_in_implementation false [get_files  ./${synth_constraints}]

# Project Design Files from IP Catalog (comment out IPs using legacy Coregen cores)
import_ip -file {../../ip_catalog/axis_async_fifo.xci} -name axis_async_fifo 
import_ip -file {../../ip_catalog/axi_ic.xci} -name axi_interconnect_4m_1s  
import_ip -file {../../ip_catalog/pcie_7x_x4gen1.xci} -name pcie_7x
import_ip -file {../../ip_catalog/mig.xci} -name mig_7x  

#- NWL Packet DMA source
read_verilog "../../ip_cores/dma/netlist/eval/dma_back_end_axi_bb.v"

# Other Custom logic source files
read_verilog "../../source/virtual_packet_fifo/packetizer/control_word_insert.v"
read_verilog "../../source/virtual_packet_fifo/packetizer/control_word_strip.v"
read_verilog "../../source/virtual_packet_fifo/vfifo_controller/address_manager.v"
read_verilog "../../source/virtual_packet_fifo/vfifo_controller/egress_fifo.v"
read_verilog "../../source/virtual_packet_fifo/vfifo_controller/ingress_fifo.v"
read_verilog "../../source/virtual_packet_fifo/vfifo_controller/vfifo_controller.v"
read_verilog "../../source/virtual_packet_fifo/packetized_vfifo_controller.v"
read_verilog "../../source/virtual_packet_fifo/multiport_mc.v"
read_verilog "../../source/virtual_packet_fifo/virtual_packet_fifo.v"
read_verilog "../../source/virtual_packet_fifo_wrapper.v"
read_verilog "../../source/synchronizer_simple.v"
read_verilog "../../source/modified_ip_files/dma/packet_dma_axi.v"
read_verilog "../../source/modified_ip_files/dma/register_map.v"
read_verilog "../../source/pcie_performance_monitor.v"
read_verilog "../../source/raw_data_packet.v"
read_verilog "../../source/k7_pcie_dma_ddr3_base.v"
read_verilog "../../source/pcie_7x_pipe_clock.v" 

# Netlist files
read_edif "../../ip_cores/dma/netlist/eval/dma_back_end_axi.ngc"

#Setting Synthesis options
set_property flow {Vivado Synthesis 2012} [get_runs synth_1]

#Setting Implementation options
set_property flow {Vivado Implementation 2012} [get_runs impl_1]

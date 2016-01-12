@echo off
rem  Vivado(TM)
rem  compile.bat: a Vivado-generated XSim simulation Script
rem  Copyright 1986-2014 Xilinx, Inc. All Rights Reserved.

set PATH=%XILINX%\lib\%PLATFORM%;%XILINX%\bin\%PLATFORM%;C:/Xilinx/Vivado/2014.2/ids_lite/ISE/bin/nt64;C:/Xilinx/Vivado/2014.2/ids_lite/ISE/lib/nt64;C:/Xilinx/Vivado/2014.2/bin;%PATH%
set XILINX_PLANAHEAD=C:/Xilinx/Vivado/2014.2

xelab -m64 --debug typical --relax --include c:/GitRepos/KC705_DDS/Verilog/ethernet_mig_sp/ethernet_mig_sp.srcs/sources_1/ip/kc705_ethernet_rgmii/tri_mode_ethernet_mac_v8_2/hdl --include C:/GitRepos/KC705_DDS/Verilog/ethernet_mig_sp/ethernet_mig_sp.srcs/sim_1/imports/sim -L xil_defaultlib -L xbip_utils_v3_0 -L xbip_pipe_v3_0 -L xbip_bram18k_v3_0 -L mult_gen_v12_0 -L tri_mode_ethernet_mac_v8_2 -L unisims_ver -L unimacro_ver -L secureip --snapshot demo_tb_behav --prj C:/GitRepos/KC705_DDS/Verilog/ethernet_mig_sp/ethernet_mig_sp.sim/sim_1/behav/demo_tb.prj   xil_defaultlib.demo_tb   xil_defaultlib.glbl
if errorlevel 1 (
   cmd /c exit /b %errorlevel%
)

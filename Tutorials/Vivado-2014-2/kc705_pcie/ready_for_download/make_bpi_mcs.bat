copy /Y ..\kc705_pcie_x8_gen2_example\kc705_pcie_x8_gen2_example.runs\impl_1\xilinx_pcie_2_1_ep_7x.bit .
call C:\\Xilinx\\Vivado\\2014.2\\.\\bin\\vivado.bat -mode batch -source make_bpi_mcs.tcl
if exist *isWriteableTest*.tmp del /F *isWriteableTest*.tmp
if exist vivado_*.backup.jou del /F vivado_*.backup.jou
if exist vivado_*.backup.log del /F vivado_*.backup.log
pause

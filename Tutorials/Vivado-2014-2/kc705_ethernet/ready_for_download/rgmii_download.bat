copy /Y ..\kc705_ethernet_rgmii_example\kc705_ethernet_rgmii_example.runs\impl_1\kc705_ethernet_rgmii_example_design.bit .
call C:\\Xilinx\\Vivado\\2014.2\\.\\bin\\vivado.bat -mode batch -source rgmii_download.tcl
if exist *isWriteableTest*.tmp del /F *isWriteableTest*.tmp
if exist vivado_*.backup.jou del /F vivado_*.backup.jou
if exist vivado_*.backup.log del /F vivado_*.backup.log
pause

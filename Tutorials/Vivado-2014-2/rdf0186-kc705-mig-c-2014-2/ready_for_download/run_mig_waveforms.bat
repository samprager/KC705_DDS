copy /Y ..\mig_7series_0_example\mig_7series_0_example.runs\impl_1\debug_nets.ltx .
copy /Y ..\mig_7series_0_example\mig_7series_0_example.runs\impl_1\example_top.bit .
call C:\\Xilinx\\Vivado\\2014.2\\.\\bin\\vivado.bat -mode batch -source run_mig_waveforms.tcl
if exist *isWriteableTest*.tmp del /F *isWriteableTest*.tmp
if exist vivado_*.backup.jou del /F vivado_*.backup.jou
if exist vivado_*.backup.log del /F vivado_*.backup.log
pause

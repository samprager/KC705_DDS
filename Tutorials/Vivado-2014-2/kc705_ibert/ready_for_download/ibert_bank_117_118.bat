copy /Y ..\ibert_bank_117_118\ibert_bank_117_118_example\ibert_bank_117_118_example.runs\impl_1\example_ibert_bank_117_118.bit .
call C:\\Xilinx\\Vivado\\2014.2\\.\\bin\\vivado.bat -mode batch -source ibert_bank_117_118.tcl
if exist *isWriteableTest*.tmp del /F *isWriteableTest*.tmp
if exist vivado_*.backup.jou del /F vivado_*.backup.jou
if exist vivado_*.backup.log del /F vivado_*.backup.log
pause
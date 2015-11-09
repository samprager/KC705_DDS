copy /Y ..\kc705_bist.sdk\bist_app\Debug\bist_app.elf .
copy /Y ..\kc705_bist.sdk\lwip_echo_server\Debug\lwip_echo_server.elf .
call C:\\Xilinx\\Vivado\\2014.2\\.\\bin\\vivado.bat -mode batch -source make_download_files.tcl
if exist *isWriteableTest*.tmp del /F *isWriteableTest*.tmp
if exist vivado_*.backup.jou del /F vivado_*.backup.jou
if exist vivado_*.backup.log del /F vivado_*.backup.log
pause

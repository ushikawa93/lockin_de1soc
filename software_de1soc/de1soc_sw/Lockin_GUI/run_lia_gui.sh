cd Pipe_c++/
make
cd ..

rm /tmp/myfifo1
rm /tmp/myfifo2
rm /tmp/myfifo3

./Pipe_c++/fpga_driver &

mono LIA_GUI_1/LIA_GUI_1/bin/Debug/LIA_GUI_1.exe

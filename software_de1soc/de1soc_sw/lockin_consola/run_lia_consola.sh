cd Pipe_c++/
make
cd ..

rm /tmp/myfifo1
rm /tmp/myfifo2
rm /tmp/myfifo3

./Pipe_c++/fpga_driver &

mono lockin_consola/lockin_consola/bin/Debug/lockin_consola.exe

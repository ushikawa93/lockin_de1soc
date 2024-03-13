% Grafica una transferencia desafectando los efectos de etapa analogica

transferencia_vacio = 'r82c1n/de1soc/transf_sin_capacitor_cali.dat';
transferencia_dut = 'r82c1n/de1soc/r82c1n.dat';

%% Abrir el archivo 1 para lectura
fileID = fopen(transferencia_vacio, 'r');

% Leer la primera línea (información de encabezado)
fgetl(fileID);fgetl(fileID);fgetl(fileID);%fgetl(fileID);

% Leer los datos usando textscan
data_vacio = textscan(fileID, formatSpec, 'Delimiter', ',', 'HeaderLines', 1);

% Extraer info
f_vacio = data_vacio{1};
R_vacio  = data_vacio{4};R_vacio=R_vacio/R_vacio(1);
phi_vacio  = data_vacio{5};

%% Abrir el archivo 2 para lectura
fileID = fopen(transferencia_dut, 'r');

% Leer la primera línea (información de encabezado)
fgetl(fileID);fgetl(fileID);fgetl(fileID);fgetl(fileID);

% Leer los datos usando textscan
data_dut = textscan(fileID, formatSpec, 'Delimiter', ',', 'HeaderLines', 1);

% Extraer info
f_dut = data_dut{1};
R_dut = data_dut{4};R_dut=R_dut/R_dut(1);
phi_dut = data_dut{5};


%% Desafecto la transferencia en vacio de la dut

R_dut_final = R_dut * R_vacio(1) ./ R_vacio;
phi_dut_final = phi_dut - phi_vacio(1) * pi / 180;

% Crear la figura con dos subplots
% Crear la figura con dos subplots
figure;

% Primer subplot
subplot(2, 1, 1);
semilogx(f_dut, R_dut_final, 'o-');
xlabel('N');
ylabel('R');
title('Gráfico de f vs R');
grid on;

% Segundo subplot
subplot(2, 1, 2);
semilogx(f_dut, phi_dut_final, 'o-');
xlabel('N');
ylabel('phi');
title('Gráfico de f vs phi');
grid on;


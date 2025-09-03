% Grafica y compara dos transferencias% Nombre del archivo CSV
archivoCSV1 = 'r10kc1n/sr865/transf_r10kc1n_3.dat';
archivoCSV2 = 'r10kc1n/de1soc/r10kc1n_M512_cali.dat';
formatSpec = '%d%f%f%f%f';

% Abrir el archivo 1 para lectura
fileID = fopen(archivoCSV1, 'r');

% Leer la primera línea (información de encabezado)
fgetl(fileID);fgetl(fileID);fgetl(fileID);

% Leer los datos usando textscan
data1 = textscan(fileID, formatSpec, 'Delimiter', ',', 'HeaderLines', 1);

% Abrir el archivo 2 para lectura
fileID = fopen(archivoCSV2, 'r');

% Leer la primera línea (información de encabezado)
fgetl(fileID);fgetl(fileID);fgetl(fileID);

% Leer los datos usando textscan
data2 = textscan(fileID, formatSpec, 'Delimiter', ',', 'HeaderLines', 1);

% Extraer info
f1 = data1{1};
R1 = data1{4};R1=R1/R1(1);
phi1 = data1{5};

f2 = data2{1};
R2 = data2{4};R2=R2/R2(1);
phi2 = data2{5};

% En realidad las frecuencias a las que calcule son un poco distintas
% esta funcion hace el mismo algoritmo que hago en la fpga para calcularlas
f2_real = zeros(size(f2));

for i = 1:numel(f2)
    f2_real(i) = frecuencias_de_fpga(f2(i), 512);
end

% Crear la figura con dos subplots
figure;

% Primer subplot
subplot(2, 1, 1);
semilogx(f1, R1, 'o-');hold on;semilogx(f2_real, R2, 'o-');
xlabel('frecuency [Hz]');
ylabel('Magnitude');
title('Transfer Function');
grid on;
xlim([0,125000]);

% Segundo subplot
subplot(2, 1, 2);
semilogx(f1, phi1, 'o-');hold on;semilogx(f2_real, phi2, 'o-');
xlabel('frecuency [Hz]');
ylabel('Phase (degrees)');
%title('Phase of the Transfer Function');
grid on;
xlim([0,125000]);

publicationPrint6(gcf,14,[],'Transference Function','png')
% Nombre del archivo CSV
archivoCSV = 'r82c1n/sr865/transf_r82c1n.dat';

% Abrir el archivo para lectura
fileID = fopen(archivoCSV, 'r');

% Leer la primera l�nea (informaci�n de encabezado)
headerLine0 = fgetl(fileID);
headerLine1 = fgetl(fileID);
headerLine2 = fgetl(fileID);
headerLine3 = fgetl(fileID);

% Leer los datos usando textscan
formatSpec = '%d%f%f%f%f';
data = textscan(fileID, formatSpec, 'Delimiter', ',', 'HeaderLines', 1);

% Cerrar el archivo
fclose(fileID);

% Extraer columnas
f = data{1};
R = data{4};R=R/R(1);
phi = data{5};

% Crear la figura con dos subplots
figure;

% Primer subplot
subplot(2, 1, 1);
semilogx(f, R, 'o-');
xlabel('N');
ylabel('R');
title('Gr�fico de f vs R');
grid on;

% Segundo subplot
subplot(2, 1, 2);
semilogx(f, phi, 'o-');
xlabel('N');
ylabel('phi');
title('Gr�fico de f vs phi');
grid on;
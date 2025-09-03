% Grafica y compara dos transferencias% Nombre del archivo CSV
archivoCSV1 = 'r10kc1n/sr865/transf_r10kc1n_3.dat';
archivoCSV2 = 'r10kc1n/de1soc/r10kc1n_M512_cali.dat';
archivoCSV3 = 'r10kc1n/de1soc/r10kc1n_M512_li.dat';

formatSpec = '%d%f%f%f%f';

%% Primera transferencia -> SR865
% Abrir el archivo 1 para lectura
fileID = fopen(archivoCSV1, 'r');

% Leer la primera línea (información de encabezado)
fgetl(fileID);fgetl(fileID);fgetl(fileID);

% Leer los datos usando textscan
data1 = textscan(fileID, formatSpec, 'Delimiter', ',', 'HeaderLines', 1);

% Extraer info
f1 = data1{1};
R1 = data1{4};R1=R1/R1(1);
phi1 = data1{5};


%% Segunda transferencia -> FPGA
% Abrir el archivo 2 para lectura
fileID = fopen(archivoCSV2, 'r');

% Leer la primera línea (información de encabezado)
fgetl(fileID);fgetl(fileID);fgetl(fileID);

% Leer los datos usando textscan
data2 = textscan(fileID, formatSpec, 'Delimiter', ',', 'HeaderLines', 1);

f2 = data2{1};
R2 = data2{4};R2=R2/R2(1);
phi2 = data2{5};

%% Tercera transferencia -> FPGA
% Abrir el archivo 2 para lectura
fileID = fopen(archivoCSV3, 'r');

% Leer la primera línea (información de encabezado)
fgetl(fileID);fgetl(fileID);fgetl(fileID);

% Leer los datos usando textscan
data3 = textscan(fileID, formatSpec, 'Delimiter', ',', 'HeaderLines', 1);

% Extraer info
f3 = data3{1};
R3 = data3{4};R3=R3/R3(1);
phi3 = data3{5};


% Crear la figura con dos subplots
figure;

% Primer subplot
subplot(2, 1, 1);
semilogx(f1, R1, 'k-o'); hold on; % Utiliza líneas negras para el primer conjunto de datos
semilogx(f2, R2, 'b-^'); % Utiliza líneas azules para el segundo conjunto de datos
semilogx(f3, R3, 'g-x'); % Utiliza líneas rojas para el tercer conjunto de datos
xlabel('Frecuency [Hz]');
ylabel('Magnitude');
title('Transfer Function');
grid on;
xlim([0, 125000]);

% Segundo subplot
subplot(2, 1, 2);
semilogx(f1, phi1-abs(phi1(1)-phi2(1)), 'k-o'); hold on; % Utiliza líneas negras para el primer conjunto de datos
semilogx(f2, phi2, 'b-^'); % Utiliza líneas azules para el segundo conjunto de datos
semilogx(f3, phi3, 'g-x'); % Utiliza líneas rojas para el tercer conjunto de datos
xlabel('Frecuency [Hz]');
ylabel('Phase (degrees)');
grid on;
xlim([0, 125000]);

% Crear un único legend que abarque ambos subplots
legend('SR865', 'CA/LI system in FPGA', 'LI system in FPGA', 'Location', 'Best');

% Ajusta la figura para mejorar la legibilidad en escala de grises
set(findall(gcf,'-property','FontName'),'FontName','Times New Roman');
set(findall(gcf,'-property','FontSize'),'FontSize',14);

% Imprimir la figura en escala de grises
%publicationPrint6(gcf, 14, [], 'Transference Function - Grayscale', 'png');






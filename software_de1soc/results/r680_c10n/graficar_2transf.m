% Grafica y compara dos transferencias% Nombre del archivo CSV

%% Primera transferencia: datos de FPGA
archivoCSV = 'r680_c10n_4.txt';
formatSpec = '%d%f%f%f%f';

% Abrir el archivo 1 para lectura
fileID = fopen(archivoCSV, 'r');

% Leer la primera línea (información de encabezado)
fgetl(fileID);fgetl(fileID);fgetl(fileID);

% Leer los datos usando textscan
data1 = textscan(fileID, formatSpec, 'Delimiter', ',', 'HeaderLines', 1);

% Extraer info
f1 = double(data1{1});
R1 = double(data1{4});
R1=R1/max(R1);
phi1 = double(data1{5});

%% Segunda transferencia: datos teóricos

f2 = f1;

R = 680; % Resistencia de 680
C = 1e-9; % Capacitancia de 1 nF

H = 1 ./ (1 + 1i*2*pi*R*2*C.*f2); % Respuesta en frecuencia del filtro RC pasa bajos
R2 = abs(H);
phi2 = angle(H) * (180/pi);

fcorte = 1/(2*pi*R*2*C);

%% Tercera transferencia: Medidas obtenida6s con sr865

archivo_sr865 =  "r680_c10n_sr865.dat";

% Abrir el archivo 1 para lectura
fileID = fopen(archivo_sr865, 'r');

% Leer la primera línea (información de encabezado)
fgetl(fileID);

% Leer los datos usando textscan
formatSpec = '%d%f%f%f%f';
data1 = textscan(fileID, formatSpec, 'Delimiter', ',', 'HeaderLines', 1);

% Extraer info
f3 = data1{1};
R3 = data1{4};
R3=R3/max(R3);
phi3 = data1{5};


%% Graficos


% Crear la figura con dos subplots
figure;
markersize = 8; linewidth = 1;

% Primer subplot
subplot(2, 1, 1);
semilogx(f1, R1, 'ko-','LineWidth', linewidth,'MarkerSize',markersize);
hold on;semilogx(f2, R2, 'kx-','LineWidth', linewidth,'MarkerSize',markersize);
semilogx(f3, R3, 'k^-','LineWidth', linewidth,'MarkerSize',markersize);
xlabel('Frecuencia [Hz]');
ylabel('Magnitud');
title('Función de Transferencia');
grid on;
xlim([0,500000]);
ylim([0,1.1])


% Crear el gráfico de zoom para Magnitud
axes('Position', [0.20, 0.68, 0.25, 0.15]); % Ajusta la posición y el tamaño del zoom
box on;
semilogx(f1, R1, 'ko-','LineWidth', linewidth,'MarkerSize',markersize);
hold on;semilogx(f2, R2, 'kx-','LineWidth', linewidth,'MarkerSize',markersize);
semilogx(f3, R3, 'k^-','LineWidth', linewidth,'MarkerSize',markersize);
xlim([fcorte * 0.96, fcorte * 1.03]); % Ajusta la ventana de zoom alrededor de fcorte
ylim([0.66 0.74]); % Ajusta los límites de Y según sea necesario
title("Zoom en amplitud");
grid on;


% Segundo subplot
subplot(2, 1, 2);
semilogx(f1, phi1, 'ko-','LineWidth', linewidth,'MarkerSize',markersize);
hold on;semilogx(f2, phi2, 'kx-','LineWidth', linewidth,'MarkerSize',markersize);
semilogx(f3, phi3, 'k^-','LineWidth', linewidth,'MarkerSize',markersize);
xlabel('Frecuencia [Hz]');
ylabel('Fase (grados)');
grid on;
xlim([0,500000]);

% Crear el gráfico de zoom para Fase
axes('Position', [0.20, 0.2, 0.25, 0.15]); % Ajusta la posición y el tamaño del zoom
box on;
semilogx(f1, phi1, 'ko-','LineWidth', linewidth,'MarkerSize',markersize);
hold on;semilogx(f2, phi2, 'kx-','LineWidth', linewidth,'MarkerSize',markersize);
semilogx(f3, phi3, 'k^-','LineWidth', linewidth,'MarkerSize',markersize);
xlim([fcorte * 0.96, fcorte * 1.03]); % Ajusta la ventana de zoom alrededor de fcorte
ylim([-50 -41]); % Ajusta los límites de Y según sea necesario
title("Zoom en fase");
 
grid on;
 


% Añadir la leyenda
lgd = legend('Datos medidos (DE1-SoC)','Datos teóricos','Datos medidos (SR865)');
% Ajustar la posición de la leyenda
set(lgd, 'Position', [0.75, 0.4, 0.2, 0.1]); % [x, y, ancho, alto]
set(lgd, 'Units', 'normalized'); % Usar unidades normalizadas

publicationPrint6(gcf,40,[],'Transferencia_R680c10n','png',20)


%% Diferencias entre teorico y DE1-li:

fprintf ( "Diferencia media de R entre teoria y DE1-li: %f (%f %%) \n", mean(abs(R1-R2)),100*mean(abs(R1-R2)));
fprintf ( "Maxima diferencia de R entre teoria y DE1-li: %f (%f %%) \n", max(abs(R1-R2)),100*max(abs(R1-R2)));

fprintf ( "Diferencia media de phi entre teoria y DE1-li: %f (%f %%) \n", mean(abs(phi1-phi2)),100*mean(abs(phi1-phi2))/360);
fprintf ( "Maxima diferencia de phi entre teoria y DE1-li: %f (%f %%)\n", max(abs(phi1-phi2)),100*max(abs(phi1-phi2))/360);
 


fprintf ( "Diferencia media de R entre SR865 y DE1-li: %f (%f %%) \n", mean(abs(R1-R3)),100*mean(abs(R1-R3)));
fprintf ( "Maxima diferencia de R entre SR865 y DE1-li: %f (%f %%) \n", max(abs(R1-R3)),100*max(abs(R1-R3)));

fprintf ( "Diferencia media de phi entre SR865 y DE1-li: %f (%f %%) \n", mean(abs(phi1-phi3)),100*mean(abs(phi1-phi3))/360);
fprintf ( "Maxima diferencia de phi entre SR865 y DE1-li: %f (%f %%)\n", max(abs(phi1-phi3)),100*max(abs(phi1-phi3))/360);
 



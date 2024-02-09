%%%%%%%PREPROCESAMIENTO DE LA IMAGEN%%%%%%%
%Limpiamos la memoria
clear; close all; clc;
%Llamar a la image
I=imread('B2.jpg');
figure;
%Imagen Original
%subplot(3,3,1);
imshow(I);
title('Imagen Original');
%Mostrar la imagen en escala de grises
I_gray = rgb2gray(I);
subplot(3,3,1);
imshow(I_gray);
title('Escala de Grises')
%ImagenContrastada
contrast = imadjust(I_gray);
subplot(3,3,2);
imshow(contrast);
title('Contrastada')
%Imagen binaria
umbral = graythresh(I_gray);
binaryImage = imbinarize(I_gray, umbral);
subplot(3,3,3);
imshow(binaryImage);
title('Imagen Binaria')
%Inverted Binary image
subplot(3,3,4);
imshow(~binaryImage);
title('Imagen Binaria invertida');
%Operaciones Morfológicas
I_dilated = imdilate(~binaryImage,strel('disk',5));
I_eroded = imerode(I_dilated,strel('disk',1));
subplot(3,3,5);
imshow(I_eroded);
title('Eroded');
% Calcular los bordes del lunar *************
bordes = edge(contrast, 'Canny',.5);
subplot(3,3,6);
imshow(bordes);
title('Bordes del lunar');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
format shortG
%PERÍMETRO%
area = bwarea(binaryImage); %Número de pixeles blancos que representan el lunar

%PERÍMETRO%
periferia = bwperim(binaryImage);
stats = regionprops(periferia,'Perimeter');
perimetro = stats.Perimeter;

%ASIMETRÍA%
asimetria = sum(abs(periferia(:) - imrotate(periferia(:), 180))) / area

%VARIABILIDAD DE COLOR
histograma_rgb = zeros(256, 3); % Creamos una matriz para almacenar el histograma de 3 canales, RGB
for i = 1:3
    canal = I(:,:,i); % Extraemos el canal de color
    histograma_rgb(:, i) = imhist(canal);
end

desviacion_rojo = std(histograma_rgb(:, 1));
desviacion_verde = std(histograma_rgb(:, 2));
desviacion_azul = std(histograma_rgb(:, 3));
variabilidad_color = (desviacion_rojo + desviacion_verde + desviacion_azul) / 3;

subplot(3,3,7:9);
bar(0:255, histograma_rgb, 'hist')
title('Histograma RGB');
xlabel('Valor de color');
ylabel('Frecuencia');
% Mostrar la medida de variabilidad de color
disp(['La variabilidad de color es: ' num2str(variabilidad_color)]); %%%%%%%%%%%%

% UMBRALES
umbral_asimetria = 0.02;
umbral_color = 180;
umbral_irregularidad = .573;

%BORDES
laplaciano = del2(double(bordes));
curvatura_promedio = mean(abs(laplaciano(bordes))) %%%%%%%%%%%%

if curvatura_promedio >= umbral_irregularidad
    disp('La imagen tiene bordes irregulares')
else
    disp('La imagen tiene bordes continuos')
end

%RESULTADOS
figure
imshow(I);
title('Imagen del lunar');

%inicialización de variables del ABCD de los lunares
asimetrico=0; % 75%
pct_asimetria=0.75;

color_variable=0;% 10%
pct_color=0.1;

bordes_irregulares=0; % 15%
pct_bordes=0.15;

%inicialización de las variables de calificación
calificacion_asimetria=0;
calificacion_color=0;
calificacion_bordes=0;

%CONDICIONALES
if asimetria > umbral_asimetria
    asimetrico=1;
    calificacion_asimetria=asimetrico*pct_asimetria;
else
    asimetrico=0;
    calificacion_asimetria=asimetrico*pct_asimetria;
end    
%%%%%%%%%%%%%%%5
if variabilidad_color > 200 && variabilidad_color < 480
    color_variable=1;
    calificacion_color=color_variable*pct_color;
else
    color_variable=0;
    calificacion_color=color_variable*pct_color;
end    
%%%%%%%%%%%%%%%
if curvatura_promedio >= umbral_irregularidad
    bordes_irregulares=1;
    calificacion_bordes=bordes_irregulares*pct_bordes;
else
    bordes_irregulares=0;
    calificacion_bordes=bordes_irregulares*pct_bordes;
end

%CÁLCULO DE PROBABILIDAD
probabilidad_maligno=(calificacion_asimetria+calificacion_color+calificacion_bordes)*100;
disp(['La probabilidad de que este lunar sea maligno es de: ' num2str(probabilidad_maligno) '%. Consulte a su médico.'])
text(10, 20, (['Probabilidad: ' num2str(probabilidad_maligno) '%']), 'Color', 'red', 'FontSize', 12);

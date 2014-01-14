%% IMAGEMASKSOLNVEC Solution to the "Ticket Authentication" Exercise, using vectorization

%% Read in a Black and White Logo
clear all
logo = imread('bwlogo.bmp');

%% Create random image of the same size 
[m,n] = size(logo);
key = rand(m,n) > 0.5;

%% Create encrypted image by flipping any pixels covered by logo
encrypted = key;
encrypted(logo) = ~encrypted(logo);

%% Decrypt the image via an exclusive OR operation
final = xor(encrypted, key);

%% Display the pictures
figure
colormap(gray(2));
subplot(2, 2, 1);
image(logo)
title('Mask')
subplot(2, 2, 2);
image(key)
title('Key')
subplot(2, 2, 3);
image(encrypted)
title('Encryption')
subplot(2, 2, 4)
image(final)
title('Final')


%% Read in a Black and White Logo
clear all
logo = imread('bwlogo.bmp');

%% Create random image of the same size 
[m,n] = size(logo);
for i = 1:m
    for j = 1:n        
        key(i,j) = ( rand(1) > 0.5 );        
    end
end

%% Create encrypted image by flipping any pixels covered by logo
for i = 1:m
    for j = 1:n
        if logo(i,j)
            encrypted(i,j) = ~key(i,j);
        else
            encrypted(i,j) = key(i,j);
        end
    end
end

%% Decrypt the image via an exclusive OR operation
for i = 1:m
    for j = 1:n        
        final(i,j) = xor(encrypted(i,j), key(i,j));        
    end
end

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


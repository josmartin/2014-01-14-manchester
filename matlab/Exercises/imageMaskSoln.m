%% IMAGEMASKSOLN Solution to the "Ticket Authentication" Exercise

%% Read in a Black and White Logo
logo = imread('bwlogo.bmp');
logo = logo(:,:,1);
figure
subplot(2, 2, 1);
image(logo)
colormap(gray(2));
title('Mask')

%% Create an image the same size as the logo with random elements
part1 = rand(size(logo)) > 0.5;
subplot(2, 2, 2);
image(part1)
colormap(gray(2))
title('Key')


%% Create a second half to the image by flipping any pixels covered by logo
part2 = part1;
part2(logical(logo)) = ~part2(logical(logo));
subplot(2, 2, 3);
image(part2)
title('Inverse Key')

%% Superimpose the two images
final = part1 & part2;

subplot(2, 2, 4)
image(final)
title('Final')


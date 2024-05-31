% Load the images
% image2 = imread('photos2\IMG_2239.JPEG');
image1 = imread('photos2\reference.JPEG');

% Display the images and manually select the points
figure; imshow(cutRefimg); title('Select 4 points in the first image');
[x1, y1] = ginput(4); % Manually select 4 points in the first image
figure; imshow(image2); title('Select the corresponding 4 points in the second image');
[x2, y2] = ginput(4); % Manually select the corresponding 4 points in the second image

% Store the points in matrices
points1 = [x1, y1];
points2 = [x2, y2];

% Compute the projective transformation matrix
tform = fitgeotrans(points2, points1, 'projective');

% Transform the second image
outputImage = imwarp(image2, tform, 'OutputView', imref2d(size(image1)));

% Display the transformed second image
figure; imshow(outputImage); title('Transformed second image');

% Overlay the images
figure;
imshowpair(image1, outputImage, 'blend'); % You can use 'diff', 'montage', etc. for different viewing options
title('Overlay of the two images');

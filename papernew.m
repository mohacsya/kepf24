% Read the reference image with the "+" marks
referenceImage = imread('photos/reference.JPEG');

% Convert the reference image to grayscale
referenceGray = rgb2gray(referenceImage);

% Detect corners of the "+" marks (assuming Harris corner detection)
corners = detectHarrisFeatures(referenceGray);

% Extract coordinates of the four strongest corners
referencePoints = corners.selectStrongest(4).Location;
referencePoints = double(referencePoints);
% Define the target locations of the reference points (e.g., corners of a rectangle)
imshow(referenceImage);
hold on
for i=1:size(referencePoints,1)
    x = [referencePoints(i,1)-20, referencePoints(i,1)+20];
    y = [referencePoints(i,2), referencePoints(i,2)];
    line(x,y,'LineWidth',2);
    x = [referencePoints(i,1), referencePoints(i,1)];
    y = [referencePoints(i,2)-20, referencePoints(i,2)+20];
    line(x,y,'LineWidth',2);
end
hold off;

% Read the new image
newImage = imread('photos/badparking1.JPEG');


% Convert the reference image to grayscale
newGray = rgb2gray(newImage);

% Detect corners of the "+" marks (assuming Harris corner detection)
newcorners = detectHarrisFeatures(newGray);

% Extract coordinates of the four strongest corners
newreferencePoints = newcorners.selectStrongest(4).Location;
newreferencePoints = double(newreferencePoints);

% Estimate geometric transformation between reference and target points
tform = estimateGeometricTransform(referencePoints, newreferencePoints, 'projective');

% Apply the estimated transformation to align the new image with the reference image
registeredImage = imwarp(newImage, tform);



% Display the registered image
imshowpair(referenceImage, registeredImage, 'montage');
title('Reference Image (Left) and Registered Image (Right)');

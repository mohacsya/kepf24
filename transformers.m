clear all
img1 = imread('photos/reference.JPEG');
refPoints1 = [250,152;
    1418,181;
    297,1870;
    1418,1805;
    ];

interestingImage1 = img1(min(refPoints1(:,2)):max(refPoints1(:,2)),min(refPoints1(:,1)):max(refPoints1(:,1)),:);

img2 = imread('photos/IMG_2022.JPEG');
refPoints2 = [342,348;
    1349,351;
    398,1787;
    1360,1739;
    ];
% Estimate geometric transformation between reference and target points
tform = fitgeotform2d(refPoints2,refPoints1, 'projective');

% Apply the estimated transformation to align the new image with the reference image
[registeredImage, RB] = imwarp(img2, tform );
[newX,newY] = RB.worldToIntrinsic(refPoints1(:,1),refPoints1(:,2))
interestingImage2 = registeredImage(floor(min(newY)):floor(max(newY)),floor(min(newX)):floor(max(newX)),:);

imshow(registeredImage);
hold on
for i=1:4
    x = [newX(i)-20,newX(i)+20];
    y = [newY(i), newY(i)];
    line(x,y,'LineWidth',2);
    x = [newX(i), newX(i)];
    y = [newY(i)-20, newY(i)+20];
    line(x,y,'LineWidth',2);
end
hold off;


 imshowpair(interestingImage1,interestingImage2,"montage");
% imshowpair(img1,registeredImage,"montage");
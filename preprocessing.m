function [binaryIMG,BW] = preprocessing(imgRGB)
   

img = rgb2gray(imgRGB);
img = img +50;
img = imgaussfilt(img);
BW = img;
img = ~imbinarize(img);
se = strel('disk', 3);
img = bwareaopen(img,10);
binaryIMG = ~img;
end


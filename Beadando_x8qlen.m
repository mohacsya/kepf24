clear all;
startime = string(datetime,"yyyyMMdd_HHmm");
workfolder = strjoin(["work\"  startime]);

%create folder in work 
mkdir(workfolder);

%reading reference img
referenceimg = imread("photos2\reference.JPEG");

%preprocessing ref img
[refbinaryIMG,refBW] = preprocessing(referenceimg);

%saving images to work
imwrite(referenceimg, fullfile(workfolder,"referenceIMG_00.png"));
imwrite(refBW, fullfile(workfolder,"referenceIMG_01_preprocessed_gray.png"));
imwrite(refbinaryIMG, fullfile(workfolder,"referenceIMG_02_preprocessed_bin.png"));

%finding ordered QR codes on reference img
[topLeftQR,topRightQR,bottomLeftQR,bottomRightQR] = findLocalizers(refbinaryIMG);
positions =[   topLeftQR.LocTopLeft;
                
                topRightQR.LocTopLeft;
               
                bottomLeftQR.LocTopLeft;
               
                bottomRightQR.LocTopLeft
               
                ];

%switching x and y just because
positions = [positions(:,2), positions(:,1)];

%ROI boundingbox corners
boundariesX = [407, 1223];
boundariesY = [528, 1379];

%colors for drawing regions
carInParkingSpotColorMultiplier(1,1,:) = [116, 237, 144];
parkingSpotColorMultiplier(1,1,:) = [82, 173, 242];
carColorMultiplier(1,1,:) = [214, 208, 94];

%cutting reference image
cutRefimg = referenceimg(boundariesY(1):boundariesY(2),boundariesX(1):boundariesX(2),:);
cutRefimgBW = refBW(boundariesY(1):boundariesY(2),boundariesX(1):boundariesX(2));
cutRefimgBin = refbinaryIMG(boundariesY(1):boundariesY(2),boundariesX(1):boundariesX(2));

%parking spot polygon and region properties
parkingSpotX = [281;568;579;295];
parkingSpotY = [110;107;699;708];
parkingSpotMask = poly2mask(parkingSpotX,parkingSpotY,size(cutRefimgBW,1),size(cutRefimgBW,2));
parkingSpotRegion = regionprops(parkingSpotMask,"all");
parkingSpotAngle = parkingSpotRegion.Orientation;
parkingSpotCentroid = parkingSpotRegion.Centroid;


imwrite(cutRefimg, fullfile(workfolder,"referenceIMG_03_Cut.png"));
imwrite(cutRefimgBW, fullfile(workfolder,"referenceIMG_04_Cut_preprocessed_gray.png"));
imwrite(cutRefimgBin, fullfile(workfolder,"referenceIMG_05_Cut_preprocessed_bin.png"));



imagelist = dir("photos2\*.jpeg");
 

for ii=1:length(imagelist)
    
    image = imread([imagelist(ii).folder '\'  imagelist(ii).name]);
    [~,imgname,~]  = fileparts([imagelist(ii).folder '\'  imagelist(ii).name]);
    if(strcmp(imgname,'reference'))
        continue;
    end
    
    %preprocessing parked img
    [binaryIMG,BW] = preprocessing(image);
    
    
    imwrite(image, fullfile(workfolder,strcat(imgname,"_00.png")));
    imwrite(BW, fullfile(workfolder,strcat(imgname,"_01_preprocessed_gray.png")));
    imwrite(binaryIMG, fullfile(workfolder,strcat(imgname,"_02_preprocessed_bin.png")));
    
    %finding ordered QR codes on parked img
    [topLeftQR,topRightQR,bottomLeftQR,bottomRightQR] = findLocalizers(binaryIMG);
    varPositions= [   topLeftQR.LocTopLeft;
               
                topRightQR.LocTopLeft;
                
                bottomLeftQR.LocTopLeft;
               
                bottomRightQR.LocTopLeft;
                
                ];

    %switching x and y just because
    varPositions = [varPositions(:,2), varPositions(:,1)];


    % Compute the projective transformation matrix
    tform = fitgeotrans(  varPositions,positions,'projective');

    % Transform the parked image
    outputImage = imwarp(image, tform, 'OutputView', imref2d(size(referenceimg)));
    outputImageBW = imwarp(BW, tform, 'OutputView', imref2d(size(referenceimg)));
    outputImageBin = imwarp(binaryIMG, tform, 'OutputView', imref2d(size(referenceimg)));
    
    %cut the transformed parked image
    cutImgBW = outputImageBW(boundariesY(1):boundariesY(2),boundariesX(1):boundariesX(2));
    cutImgBin = outputImageBin(boundariesY(1):boundariesY(2),boundariesX(1):boundariesX(2));
    cutImg = outputImage(boundariesY(1):boundariesY(2),boundariesX(1):boundariesX(2),:);
    
    imwrite(cutImg, fullfile(workfolder,strcat(imgname,"_03_cut.png")));
    imwrite(cutImgBW, fullfile(workfolder,strcat(imgname,"_04_cut_gray.png")));
    imwrite(cutImgBin, fullfile(workfolder,strcat(imgname,"_05_cut_bin.png")));
    
    % calculate difference between ref and parked img
    diffimg = uint8(abs(double(cutImgBW)-doube(cutRefimgBW)));
    
    imwrite(diffimg, fullfile(workfolder,strcat(imgname,"_06_diffimg.png")));

    diffimg = imgaussfilt(diffimg);

    %this actually doesn't do much
    diffbin = diffimg >= 60; %max(diffimg,[],"all")*0.3;

    diffbin=imopen(diffbin,ones(10));
    
    imwrite(diffimg, fullfile(workfolder,strcat(imgname,"_07_diffimg_tresholded.png")));

    SE = strel("disk",20);
    diffbin = imdilate(diffbin,SE);
    diffbin = imdilate(diffbin,SE);
    diffbin = imdilate(diffbin,SE);
    diffbin = imdilate(diffbin,SE);
    diffbin = imdilate(diffbin,SE);
    diffbin = imerode(diffbin,SE);
    diffbin = imerode(diffbin,SE);
    diffbin = imerode(diffbin,SE);
    diffbin = imerode(diffbin,SE);
    diffbin = imerode(diffbin,SE);
    % diffbin = imerode(diffbin,SE);

    % getting regions of binary image
    regions = regionprops(diffbin,"All");

    %ordering regions by area in descending order
    [~,idx] = sort([regions.Area],"descend");

    %generating new binary image of just the region with biggest area
    diffbin(:,:) = 0;
    diffbin(regions(1).PixelIdxList) = 1;
    
    %just for debug 
    rgbOverlay_ = uint8(diffbin .* carInParkingSpotColorMultiplier);
    imobj_ = imshowpair(cutImg, rgbOverlay_,"blend");
    imwrite(imobj_.CData, fullfile(workfolder,strcat(imgname,"_99_debug.png")));

    imwrite(diffbin, fullfile(workfolder,strcat(imgname,"_08_diffimg_binarized.png")));

    imshow(cutImg);
    
    %getting the properties of the region corresponding to the car
    carregion = regionprops(diffbin,"all");
    [boundingBoxPoints,angle] = getAngleAndTrueBoundingBox(carregion,true);
    
    %creating a polygon from the car bounding box
    carBoxMask = poly2mask(boundingBoxPoints(:,1),boundingBoxPoints(:,2),size(cutRefimgBW,1),size(cutRefimgBW,2));
    
    %calculating the mask for the car in the parking spot
    carInParkingSpotMask = carBoxMask & parkingSpotMask;

    %calculating the pixels of the car in the parking spot
    carInParkingSpotAreaProportion = sum(carInParkingSpotMask,"all")/sum(carBoxMask,"all");

    %calculating the pixels of the car NOT in the parking spot
    carNotInParkingSpotMask = carBoxMask & ~parkingSpotMask;

    %calculating the pixels of the parking spot not taken by the car
    parkingSpotMaskNotCar = parkingSpotMask & ~carBoxMask;
    
    
    %creating an rgb overlay to mark regions of car and parking spot
    rgbOverlay = uint8(carInParkingSpotMask .* carInParkingSpotColorMultiplier) + ...
                   uint8(carNotInParkingSpotMask .*  carColorMultiplier) + ...
                   uint8(parkingSpotMaskNotCar .* parkingSpotColorMultiplier);
    
    
    %creating an image with the cut parked image and the overlay
    imobj = imshowpair(cutImg, rgbOverlay,"blend");

    %saving the image of the blended image
    identifiedRGB = imobj.CData;

    %calculating the parking scores
    anglediff =  abs(abs(parkingSpotAngle) - abs(angle));
    angleVerdict = 1-(anglediff/90);
    totalVerdict = angleVerdict * carInParkingSpotAreaProportion;   
    verdictText = ['Car position multiplier: ' num2str(carInParkingSpotAreaProportion,3) newline ...
                   'Car angle multiplier: ' num2str(angleVerdict,3) newline ...
                   'Parking verdict: ' num2str(totalVerdict,3)
    ];
     identifiedTextedRGB = insertText(identifiedRGB,[50,50], verdictText);
    imshow(identifiedTextedRGB);
    imwrite(identifiedTextedRGB,fullfile(workfolder,strcat(imgname,"_09_identified.png")));

end


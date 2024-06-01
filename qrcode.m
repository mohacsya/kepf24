clear all;
startime = string(datetime,"yyyyMMdd_HHmm");
workfolder = strjoin(["work\"  startime]);
%create folder in work 
mkdir(workfolder);

referenceimg = imread("photos2\reference.JPEG");
[refbinaryIMG,refBW] = preprocessing(referenceimg);

imwrite(referenceimg, fullfile(workfolder,"referenceIMG_00.png"));
imwrite(refBW, fullfile(workfolder,"referenceIMG_01_preprocessed_gray.png"));
imwrite(refbinaryIMG, fullfile(workfolder,"referenceIMG_02_preprocessed_bin.png"));

% binaryIMG = ~binaryIMG;
[topLeftQR,topRightQR,bottomLeftQR,bottomRightQR] = findLocalizers(refbinaryIMG);
positions =[   topLeftQR.LocTopLeft;
                
                topRightQR.LocTopLeft;
               
                bottomLeftQR.LocTopLeft;
               
                bottomRightQR.LocTopLeft
               
                ];

positions = [positions(:,2), positions(:,1)];
% texts = {'topLeftQR';'topRightQR';'bottomLeftQR';'bottomRightQR'};
% RGB = insertText(BW,positions,texts);
% imshow(RGB);

boundariesX = [407, 1223];
boundariesY = [528, 1379];
carInParkingSpotColorMultiplier(1,1,:) = [116, 237, 144];
parkingSpotColorMultiplier(1,1,:) = [82, 173, 242];
carColorMultiplier(1,1,:) = [214, 208, 94];



cutRefimg = referenceimg(boundariesY(1):boundariesY(2),boundariesX(1):boundariesX(2),:);
cutRefimgBW = refBW(boundariesY(1):boundariesY(2),boundariesX(1):boundariesX(2));
cutRefimgBin = refbinaryIMG(boundariesY(1):boundariesY(2),boundariesX(1):boundariesX(2));


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
    
    [binaryIMG,BW] = preprocessing(image);
    
    imwrite(image, fullfile(workfolder,strcat(imgname,"_00.png")));
    imwrite(BW, fullfile(workfolder,strcat(imgname,"_01_preprocessed_gray.png")));
    imwrite(binaryIMG, fullfile(workfolder,strcat(imgname,"_02_preprocessed_bin.png")));
    

    [topLeftQR,topRightQR,bottomLeftQR,bottomRightQR] = findLocalizers(binaryIMG);
    varPositions= [   topLeftQR.LocTopLeft;
               
                topRightQR.LocTopLeft;
                
                bottomLeftQR.LocTopLeft;
               
                bottomRightQR.LocTopLeft;
                
                ];
    varPositions = [varPositions(:,2), varPositions(:,1)];
    % Compute the projective transformation matrix
    tform = fitgeotrans(  varPositions,positions,'projective');
    % Transform the second image
    outputImage = imwarp(image, tform, 'OutputView', imref2d(size(referenceimg)));
    outputImageBW = imwarp(BW, tform, 'OutputView', imref2d(size(referenceimg)));
    outputImageBin = imwarp(binaryIMG, tform, 'OutputView', imref2d(size(referenceimg)));

    cutImgBW = outputImageBW(boundariesY(1):boundariesY(2),boundariesX(1):boundariesX(2));
    cutImgBin = outputImageBin(boundariesY(1):boundariesY(2),boundariesX(1):boundariesX(2));
    cutImg = outputImage(boundariesY(1):boundariesY(2),boundariesX(1):boundariesX(2),:);
    
    imwrite(cutImg, fullfile(workfolder,strcat(imgname,"_03_cut.png")));
    imwrite(cutImgBW, fullfile(workfolder,strcat(imgname,"_04_cut_gray.png")));
    imwrite(cutImgBin, fullfile(workfolder,strcat(imgname,"_05_cut_bin.png")));

    % [BW,maskedRGBImage] = shadowMask5(cutImg);
    % 
    % imwrite(maskedRGBImage, fullfile(workfolder,strcat(imgname,"_cut_shadowmasked_rgb.png")));
    % imwrite(cutRefimgBW, fullfile(workfolder,strcat(imgname,"_shadowmask_bin.png")));
    

    diffimg = uint8(abs(double(cutImgBW)-double(cutRefimgBW)));
    
    imwrite(diffimg, fullfile(workfolder,strcat(imgname,"_06_diffimg.png")));

    % diffimg(BW) = 0;
    diffimg = imgaussfilt(diffimg);
    
    diffbin = diffimg >= 60; %max(diffimg,[],"all")*0.3;
    % diffbin(BW) = 0;
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
    regions = regionprops(diffbin,"All");
    [~,idx] = sort([regions.Area],"descend");
    diffbin(:,:) = 0;
    diffbin(regions(1).PixelIdxList) = 1;
    
    rgbOverlay_ = uint8(diffbin .* carInParkingSpotColorMultiplier);
    imobj_ = imshowpair(cutImg, rgbOverlay_,"blend");
    imwrite(imobj_.CData, fullfile(workfolder,strcat(imgname,"_99_debug.png")));


    imwrite(diffbin, fullfile(workfolder,strcat(imgname,"_08_diffimg_binarized.png")));

    imshow(cutImg);
    carregion = regionprops(diffbin,"all");
    [boundingBoxPoints,angle] = getAngleAndTrueBoundingBox(carregion,true);
    
    carBoxMask = poly2mask(boundingBoxPoints(:,1),boundingBoxPoints(:,2),size(cutRefimgBW,1),size(cutRefimgBW,2));
    carInParkingSpotMask = carBoxMask & parkingSpotMask;
    carInParkingSpotAreaProportion = sum(carInParkingSpotMask,"all")/sum(carBoxMask,"all");
    
    carNotInParkingSpotMask = carBoxMask & ~parkingSpotMask;
    parkingSpotMaskNotCar = parkingSpotMask & ~carBoxMask;
    
    
    
    rgbOverlay = uint8(carInParkingSpotMask .* carInParkingSpotColorMultiplier) + ...
                   uint8(carNotInParkingSpotMask .*  carColorMultiplier) + ...
                   uint8(parkingSpotMaskNotCar .* parkingSpotColorMultiplier);
    
    

    imobj = imshowpair(cutImg, rgbOverlay,"blend");
    identifiedRGB = imobj.CData;
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
    % histogram(diffimg);
    
    % imshowpair(cutRefimg, cutImg, 'montage'); % You can use 'diff', 'montage', etc. for different viewing options
    % title('Overlay of the two images');

    % [newX,newY] = RB.worldToIntrinsic(refPoints1(:,1),refPoints1(:,2))
    
    
    % positions = [positions(:,2), positions(:,1)];
    % texts = {'topLeftQR';'topRightQR';'bottomLeftQR';'bottomRightQR'};
    % RGB = insertText(BW,positions,texts,'FontSize',25);
    % imshow(RGB);
            
 
  
end


% [x,y] = find(localizersV == 1);
% scatter(y,x,'Marker','.','Color',[155 155 0]);

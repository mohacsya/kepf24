 image = imread("photos2\IMG_2342.JPEG");
  
    
    [binaryIMG,BW] = preprocessing(image);
    

    

    [topLeftQR,topRightQR,bottomLeftQR,bottomRightQR] = findLocalizers(binaryIMG);
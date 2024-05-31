function [boundingBoxPoints,angle] = getAngleAndTrueBoundingBox(careaprops,drawIt)
angle = -careaprops.Orientation;
center = careaprops.Centroid;
anglevector = [cos(deg2rad(angle)) sin(deg2rad(angle))];
longvecstart = center + (anglevector*(careaprops.MajorAxisLength/2));
longvecend = center - (anglevector*(careaprops.MajorAxisLength/2));
longvec = longvecend - longvecstart;

anglevector2 = [-sin(deg2rad(angle)) cos(deg2rad(angle)) ];
shortvecstart = center + (anglevector2*(careaprops.MinorAxisLength/2));
shortvecend = center - (anglevector2*(careaprops.MinorAxisLength/2));
shortvec = shortvecend-shortvecstart;

longedge1start = longvecstart+(shortvec/2);
longedge1end = longvecend+(shortvec/2);
longedge2start = longvecstart-(shortvec/2);
longedge2end = longvecend-(shortvec/2);


shortedge1start = shortvecstart+(longvec/2);
shortedge1end = shortvecend+(longvec/2);
shortedge2start = shortvecstart-(longvec/2);
shortedge2end = shortvecend-(longvec/2);

boundingBoxPoints = [
    longedge1start;
    longedge1end;
    shortedge1start;
    % shortedge1end;
    % longedge2end;
    longedge2start;
    % shortedge2end;
    % shortedge2start;
    ];
if(drawIt)
    line([longedge1start(1);longedge1end(1)],[longedge1start(2);longedge1end(2)], "Color", "blue");
    line([longedge1end(1);shortedge1start(1)],[longedge1end(2);shortedge1start(2)], "Color", "blue");
    line([shortedge1start(1);longedge2start(1)],[shortedge1start(2);longedge2start(2)], "Color", "blue");
    line([longedge2start(1);longedge1start(1)],[longedge2start(2);longedge1start(2)], "Color", "blue");
end
end


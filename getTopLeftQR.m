function [topLeftQR] = getTopLeftQR(qrCodes)

for ii = 1:length(qrCodes)
    couldBeTopLeft = true;
    for jj = 1:length(qrCodes)
        if(ii~=jj)
            refpoint = qrCodes(ii).LocTopLeft;
            point1 = qrCodes(ii).Centroid;
            point2 = qrCodes(jj).Centroid;
            % point1= [point1(2) point1(1)];
            % point2= [point2(2) point2(1)];
            % refpoint= [refpoint(2) refpoint(1)];
            if(~isInSameHalfspace(refpoint,point1,point2))
                couldBeTopLeft=false;
            end
        end
    end
    if(couldBeTopLeft)
        topLeftQR = qrCodes(ii);
        return;
    end
end
end


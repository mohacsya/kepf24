function [topLeftQR,topRightQR,bottomLeftQR,bottomRightQR] = findLocalizers(binaryIMG)
toleranceMin = 0.1; %arbitrary
toleranceMax = 0.6; %0.5 coming from standard QR code docu
iteration = 1;
x = double.empty;
y = double.empty;
while (length(x)~=12 && iteration<12)
    tolerance = (toleranceMin + toleranceMax) / 2;
    localizers = findProbableLocalizers(binaryIMG,tolerance);
    localizersV = findProbableLocalizers(binaryIMG',tolerance)';
    both = localizersV & localizers;
    for xx = 2:size(both,1)-1
        for yy = 2:size(both,2)-1
            if(both(xx,yy)==1)
                %squash clusters of probable localizer points into 1
                both(xx-1:xx+1,yy-1:yy+1) = 0;
                both(xx,yy)=1;
            end
        end
    end
    [x,y] = find(both == 1);
    x=x';
    y=y';
    %adjust tolerance
    if(length(x)<12)
        toleranceMin = tolerance;
        iteration = iteration+1;
    elseif(length(x)>12)
        toleranceMax = tolerance;
        iteration = iteration+1;
    end
end
if(length(x) ~=12)
    error('nem sikerült 12 lokalizert találni :(');
end

%%%debug
% imshow(binaryIMG);
% hold on
% scatter(y,x);
% hold off

%group localizers into groups of 3
D = pdist2([x;y]',[x;y]');
[~,I] = mink(D,3,1);
B = sort(I,1);
groups = unique(B',"rows");
groupXs = x(groups);
groupYs = y(groups);
qrCodes = LocalizedQR.empty;
for ii = 1:size(groupXs,1)
    qrCodes(ii)= LocalizedQR(groupXs(ii,:), groupYs(ii,:));
end
topLeftQR = getTopLeftQR(qrCodes);
qrCodes = qrCodes(find(qrCodes~=topLeftQR));
remainingCentroids = cell2mat({qrCodes.Centroid}')

[x,y,centroidX,centroidY] = LocalizedQR.orderLocalizers(remainingCentroids(:,1), remainingCentroids(:,2));
bottomRightQR = findobj(qrCodes,'Centroid',[x(1) y(1)]);
topRightQR = findobj(qrCodes,'Centroid',[x(2) y(2)]);
bottomLeftQR = findobj(qrCodes,'Centroid',[x(3) y(3)]);




end

function [localizers] =  findProbableLocalizers(binaryIMG, tolerance)
localizers = zeros(size(binaryIMG,1),size(binaryIMG,2));
for ii=1:size(binaryIMG,1)
    localizervector = zeros(1,size(binaryIMG,2));
    d = [true, diff(binaryIMG(ii,:)) ~= 0, true];  % TRUE if values change
    sequences = diff(find(d));               % Number of repetitions
    sequencecumsum = cumsum(sequences);
    sequencebits = binaryIMG(ii,sequencecumsum);
    if(length(sequences)>=5)
        for jj = 3:length(sequences)-2
            if(sequencebits(jj)==0)
                localizersequence = sequences(jj-2:jj++2);
                normlocalizersequence = (localizersequence .* 3)./sequences(jj);
                idx = (normlocalizersequence >= (1-tolerance)  & normlocalizersequence<=(1+tolerance));
                if (idx == [1 1 0 1 1])
                    localizervector(floor(((sequencecumsum(jj-1)+1 +sequencecumsum(jj)))/2)) = 1;
                    localizervector(ceil(((sequencecumsum(jj-1)+1 +sequencecumsum(jj)))/2)) = 1;
                end
            end
        end
    end
    localizers(ii,:) = localizervector;
end
end




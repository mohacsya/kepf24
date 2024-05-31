referenceimg = imread("photos\reference.jpeg");
[binaryIMG,BW] = preprocessing(referenceimg);
binaryIMG = ~binaryIMG;
[refx,refy] = findProbableLocalizerX(binaryIMG);
 imshow(binaryIMG);
hold on;

scatter(y(1),x(1),'Marker','+','Color',[0 155 0],'LineWidth',2);
scatter(y(2),x(2),'Marker','o','Color',[0 155 0],'LineWidth',2);
scatter(y(3),x(3),'Marker','*','Color',[0 155 0],'LineWidth',2);


function [localizers] =  findProbableLocalizerX(binaryIMG, tolerance)
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
                normlocalizersequence = (localizersequence)./sequences(jj);
                idx = (normlocalizersequence >= (1-tolerance)  & normlocalizersequence<=(1+tolerance));
                if (idx == [1 1 1 1 1])
                    localizervector(floor(((sequencecumsum(jj-1)+1 +sequencecumsum(jj)))/2)) = 1;
                end
            end
        end
    end
    localizers(ii,:) = localizervector;
end
end
classdef LocalizedQR < handle
    %LOCALIZEDQR Summary of this class goes here
    %   Detailed explanation goes here

    properties
        LocTopLeft
        LocTopRight
        LocBotLeft
        Centroid
    end

    methods
        function obj = LocalizedQR(x,y)
           [x,y,centroidX,centroidY] = LocalizedQR.orderLocalizers(x,y);
           obj.LocTopLeft = [x(1),y(1)];
           obj.LocBotLeft = [x(2),y(2)];
           obj.LocTopRight = [x(3),y(3)];
           obj.Centroid = [centroidX,centroidY];
        end
    end
    methods(Static)
         function [x,y,centroidX,centroidY] = orderLocalizers(x,y)


            first2secondV = [x(2)-x(1) y(2)-y(1)];
            first2thirdV = [x(3)-x(1) y(3)-y(1)];

            second2firstV = [x(1)-x(2) y(1)-y(2)];
            second2thirdV = [x(3)-x(2) y(3)-y(2)];

            third2firstV = [x(1)-x(3) y(1)-y(3)];
            third2secondV = [x(2)-x(3) y(2)-y(3)];

            centroidX = sum(x)/3;
            centroidY = sum(y)/3;

            for ii=1:length(x)
                distances(ii) = sqrt( (x(ii)-centroidX)^2 + (y(ii)-centroidY)^2 );
            end

            biggestAngleidx = find(distances == min(distances) );
            % angleAtFirst = angleBetween(first2secondV,first2thirdV);
            % angleAtSecond = angleBetween(second2firstV,second2thirdV);
            % angleAtThird = angleBetween(third2firstV,third2secondV);
            %
            % angles = abs([angleAtFirst angleAtSecond angleAtThird]);
            % biggestAngleidx = find(angles == max(angles) );

            if(biggestAngleidx == 1)
                if (angleBetween(first2secondV,first2thirdV) >0)
                    x_=x;
                    y_=y;
                else
                    x_(1) = x(1);
                    y_(1) = y(1);
                    x_(2) = x(3);
                    y_(2) = y(3);
                    x_(3) = x(2);
                    y_(3) = y(2);
                    % third and second has to be swapped
                end
            elseif(biggestAngleidx == 2)
                x_(1) = x(2);
                y_(1) = y(2);
                if (angleBetween(second2firstV,second2thirdV) >0)
                    x_(2) = x(1);
                    y_(2) = y(1);
                    x_(3) = x(3);
                    y_(3) = y(3);
                else
                    x_(2) = x(3);
                    y_(2) = y(3);
                    x_(3) = x(1);
                    y_(3) = y(1);
                    % third and second has to be swapped
                end
            elseif(biggestAngleidx == 3)
                x_(1) = x(3);
                y_(1) = y(3);
                if (angleBetween(third2firstV,third2secondV) >0)
                    x_(2) = x(1);
                    y_(2) = y(1);
                    x_(3) = x(2);
                    y_(3) = y(2);
                else
                    x_(2) = x(2);
                    y_(2) = y(2);
                    x_(3) = x(1);
                    y_(3) = y(1);
                    % third and second has to be swapped
                end
            end
            x = x_;
            y = y_;
        end
    end
end



function [inSame] = isInSameHalfspace(refPoint,point1,point2)
    v1 = point1 - refPoint;
    v2 = point2 - refPoint;
    proj = (dot(v1,v2)/(norm(v2)^2))*v2;
    inSame =  sign(proj(1)) == sign(v2(1)) && sign(proj(2)) == sign(v2(2));
   
end

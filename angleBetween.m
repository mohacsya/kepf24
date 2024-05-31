

function angle = angleBetween(u,v) 
    angle = atan2d(u(1)*v(2)-v(1)*u(2),u(1)*u(2)+v(1)*v(2));
end
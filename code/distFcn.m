function [ dist ] = distFcn( model,points )
x1 = points(:,1:2);
x2 = points(:,3:4);
x1 = [x1 , ones(size(x1,1),1)];
x2 = [x2 , ones(size(x2,1),1)];

%sum((points(:,4:6) - points(:,1:3)*model=).^2,2);

ans = model*x1';
ans_temp = [ans(3,:); ans(3,:) ; ans(3,:)];
ans = ans./ans_temp;

dist = sum((ans'-x2).^2,2);

end
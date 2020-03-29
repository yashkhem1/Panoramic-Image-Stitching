function [ H ] = homography( p1, p2 )
%%%%%%%%%%%%
%imtool('wembley.jpeg');
%%%%%%%%%%%
n = size(p1,2);
x = p2(1, :); y = p2(2,:); X = p1(1,:); Y = p1(2,:);
rows0 = zeros(3, n);
rowsXY = -[X; Y; ones(1,n)];
hx = [rowsXY; rows0; x.*X; x.*Y; x];
hy = [rows0; rowsXY; y.*X; y.*Y; y];
h = [hx hy];
[U, ~, ~] = svd(h);
H = (reshape(U(:,9), 3, 3)).';
end
function [ H ] = ransacHomography( x1, x2, thresh )
%RANSACHOMOGRAPHY Summary of this function goes here
%   Detailed explanation goes here
points = [x1, x2];
fitLineFcn = @(points) homography(points(:,1:2)',points(:,3:4)');
evalLineFcn = @(model, points) distFcn(model,points);

[H, ~] = ransac(points,fitLineFcn,evalLineFcn,4,thresh);

end


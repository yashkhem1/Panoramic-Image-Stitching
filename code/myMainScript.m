I1 = rgb2gray(imread('2.JPG'));
I2 = rgb2gray(imread('3.JPG'));

imageSize = zeros(2,2);
imageSize(1,:) = size(I1);
imageSize(2,:) = size(I2);

points1 = detectSURFFeatures(I1);
points2 = detectSURFFeatures(I2);

[f1,vpts1] = extractFeatures(I1,points1);
[f2,vpts2] = extractFeatures(I2,points2);

indexPairs = matchFeatures(f1,f2) ;
matchedPoints1 = vpts1(indexPairs(:,1));
matchedPoints2 = vpts2(indexPairs(:,2));

%showMatchedFeatures(I1,I2,matchedPoints1,matchedPoints2);

p1 = [961, 1126, 1060, 845 ; 540, 559, 723, 684];
p2 = [0, 18, 18, 0; 0, 0, 44, 44];

%H = findHomography(p1,p2);

pst1 = matchedPoints1.Location;
%pst1 = [pst1 , ones(size(pst1,1),1)];

pst2 = matchedPoints2.Location;
%pst2 = [pst2 , ones(size(pst2,1),1)];

data = [pst1 , pst2];

tforms1 = projective2d(eye(3));

k = ransacHomography(pst2,pst1,0.1);
k = k/k(3,3);
tforms2 = projective2d(k');
%tforms2 = estimateGeometricTransform(matchedPoints2, matchedPoints1,...
%        'projective', 'Confidence', 99.9, 'MaxNumTrials', 2000);

tforms2.T;

        
[xlim(1,:), ylim(1,:)] = outputLimits(tforms1, [1 imageSize(1,2)], [1 imageSize(1,1)]);
[xlim(2,:), ylim(2,:)] = outputLimits(tforms2, [1 imageSize(2,2)], [1 imageSize(2,1)]);


maxImageSize = max(imageSize);

% Find the minimum and maximum output limits
xMin = min([1; xlim(:)]);
xMax = max([maxImageSize(2); xlim(:)]);

yMin = min([1; ylim(:)]);
yMax = max([maxImageSize(1); ylim(:)]);

% Width and height of panorama.
width  = round(xMax - xMin);
height = round(yMax - yMin);

% Initialize the "empty" panorama.



blender = vision.AlphaBlender('Operation', 'Binary mask', ...
    'MaskSource', 'Input port');

% Create a 2-D spatial reference object defining the size of the panorama.
xLimits = [xMin xMax];
yLimits = [yMin yMax];
panoramaView = imref2d([2*height 2*width], xLimits, yLimits);

% Create the panorama.

    I = imread('2.JPG');
panorama = zeros([2*height 2*width 3], 'like', I);
    % Transform I into the panorama.
    warpedImage = imwarp(I, tforms1, 'OutputView', panoramaView);

    % Generate a binary mask.
    mask = imwarp(true(size(I,1),size(I,2)), tforms1, 'OutputView', panoramaView);

    % Overlay the warpedImage onto the panorama.
    panorama = step(blender, panorama, warpedImage, mask);
    
    I = imread('3.JPG');

    % Transform I into the panorama.
    warpedImage = imwarp(I, tforms2, 'OutputView', panoramaView);

    % Generate a binary mask.
    mask = imwarp(true(size(I,1),size(I,2)), tforms2, 'OutputView', panoramaView);

    % Overlay the warpedImage onto the panorama.
    panorama = step(blender, panorama, warpedImage, mask);

figure
imshow(panorama)

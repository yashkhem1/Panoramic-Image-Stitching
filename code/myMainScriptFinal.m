inputs = ['../Published'];

for i=1:size(inputs)
    images = imageDatastore(fullfile('../Published/'));
    num_images = numel(images.Files);
    I1 = rgb2gray(readimage(images,1));
    
    points = detectSURFFeatures(I1);
    imageSize = zeros(num_images,2);
    imageSize(1,:) = size(I1);
    [f,vpts] = extractFeatures(I1,points);
    homographies(num_images) = projective2d(eye(3));
    
    for n=2:num_images
        prevpoints = points;
        prevf = f;
        prevvpts = vpts;
        
        I = rgb2gray(readimage(images,n));
        points = detectSURFFeatures(I);
        [f,vpts] = extractFeatures(I,points);
        
%         indexPairs = matchFeatures(f,prevf) ;
%         matchedPoints = vpts(indexPairs(:,1));
%         prevmatchedPoints = prevvpts(indexPairs(:,2));

        indexPairs = matchFeatures(f, prevf, 'Unique', true);

        matchedPoints = points(indexPairs(:,1), :);
        prevmatchedPoints = prevpoints(indexPairs(:,2), :);
        %showMatchedFeatures(I1,I,prevmatchedPoints,matchedPoints);     
        imageSize(n,:) = size(I);
        
        pst1 = matchedPoints.Location;
        pst2 = prevmatchedPoints.Location;
        
        k = ransacHomography(pst1,pst2,10);
        k = k/k(3,3);
        homographies(n) = projective2d(k');
        
        homographies(n).T = homographies(n).T * homographies(n-1).T;
    end
        
    for i = 1:numel(homographies)
        [xlim(i,:), ylim(i,:)] = outputLimits(homographies(i), [1 imageSize(i,2)], [1 imageSize(i,1)]);
    end
    
    
    maxImageSize = max(imageSize);
    
    I = readimage(images,1);

    % Find the minimum and maximum output limits
    xMin = min([1; xlim(:)]);
    xMax = max([maxImageSize(2); xlim(:)]);
    
    yMin = min([1; ylim(:)]);
    yMax = max([maxImageSize(1); ylim(:)]);
    
    % Width and height of panorama.
    width  = round(xMax - xMin);
    height = round(yMax - yMin);
    
    % Initialize the "empty" panorama.
    panorama = zeros([height width 3], 'like', I);
    
    blender = vision.AlphaBlender('Operation', 'Binary mask', ...
    'MaskSource', 'Input port');

    % Create a 2-D spatial reference object defining the size of the panorama.
    xLimits = [xMin xMax];
    yLimits = [yMin yMax];
    panoramaView = imref2d([height width], xLimits, yLimits);
    
    % Create the panorama.
    for i = 1:num_images
    
        I = readimage(images, i);
    
        % Transform I into the panorama.
        warpedImage = imwarp(I, homographies(i), 'OutputView', panoramaView);
    
        % Generate a binary mask.
        mask = imwarp(true(size(I,1),size(I,2)), homographies(i), 'OutputView', panoramaView);
    
        % Overlay the warpedImage onto the panorama.
        panorama = step(blender, panorama, warpedImage, mask);
    end
    
    figure
    imshow(panorama)
    
    
    
end
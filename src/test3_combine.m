%% Brush effect with rectangles & circles (combined)
clc; clear; close all;

%% Locate this script and the project root
thisFile    = mfilename('fullpath');     % full path to this .m file
thisDir     = fileparts(thisFile);       % folder containing this file
projectRoot = fileparts(thisDir);        % go up one level (repo root)

%% Build paths relative to the repo
imgPath = fullfile(projectRoot, 'images', 'Billie.png');      % same image as others
outDir  = fullfile(projectRoot, 'experiments', 'combined', 'output');

% Make sure the output folder exists
if ~exist(outDir, 'dir')
    mkdir(outDir);
end

%% Read the original image
img = imread(imgPath);  % image in /images/
[rows, cols, channels] = size(img);

% Define the range for random shape sizes
minWidth  = 10;  maxWidth  = 20;  % Rectangle width
minHeight = 20;  maxHeight = 30;  % Rectangle height
minRadius = 5;   maxRadius = 10;  % Circle radius

% Initialize the output image
outputImg = img;

% Detect edges and calculate their direction
edgeMask      = false(rows, cols);
edgeDirection = zeros(rows, cols); % Store edge direction in degrees

for channel = 1:channels
    % Sobel filters for gradient detection
    gradientX = imfilter(double(img(:,:,channel)), [-1 0 1; -2 0 2; -1 0 1]);
    gradientY = imfilter(double(img(:,:,channel)), [-1 -2 -1; 0 0 0; 1 2 1]);
    
    % Edge magnitude
    edgeMagnitude = sqrt(gradientX.^2 + gradientY.^2);
    channelEdge   = edgeMagnitude > 20; % Edge threshold
    
    % Edge direction (degrees)
    channelDirection = atan2d(gradientY, gradientX);
    
    % Update edge mask
    edgeMask = edgeMask | channelEdge;
    
    % Store direction where edges are detected
    edgeDirection(channelEdge) = channelDirection(channelEdge);
end

% Generate grid points across the image
rowStep = min(minWidth,  minRadius * 2);
colStep = min(minWidth,  minRadius * 2);
[Xgrid, Ygrid] = meshgrid(1:colStep:cols, 1:rowStep:rows);
shapeCenters   = [Ygrid(:), Xgrid(:)];

% Transparency level
alpha = 0.5; % 50%

%% Loop to place rectangles and circles
for i = 1:size(shapeCenters, 1)
    row = shapeCenters(i, 1);
    col = shapeCenters(i, 2);
    
    % Bounds check
    if row > rows || col > cols || row < 1 || col < 1
        continue;
    end
    
    % Orientation based on edge direction (if on an edge)
    if edgeMask(row, col)
        theta = edgeDirection(row, col);             % local edge direction
        theta = theta + randi([-10, 10]);            % small random variation
    else
        theta = randi([0, 360]);                     % random elsewhere
    end
    
    % Create mask for either rectangle or circle
    [X, Y] = meshgrid(1:cols, 1:rows);
    
    if rand > 0.5
        % Random oriented rectangle
        shapeWidth  = randi([minWidth,  maxWidth]);
        shapeHeight = randi([minHeight, maxHeight]);
        halfWidth   = floor(shapeWidth  / 2);
        halfHeight  = floor(shapeHeight / 2);
        
        X_rot = (X - col) * cosd(theta) + (Y - row) * sind(theta);
        Y_rot = -(X - col) * sind(theta) + (Y - row) * cosd(theta);
        mask  = (abs(X_rot) <= halfWidth) & (abs(Y_rot) <= halfHeight);
        
    else
        % Random circle
        radius = randi([minRadius, maxRadius]);
        mask   = ((X - col).^2 + (Y - row).^2) <= radius^2;
    end
    
    % Compute the average color inside the shape
    avgColor = zeros(1, 3);
    for channel = 1:channels
        pixelsInside = img(:,:,channel);
        pixelsInside = pixelsInside(mask);
        avgColor(channel) = mean(pixelsInside);
    end
    
    % Blend shape with original image using transparency
    for channel = 1:channels
        tempChannel = double(outputImg(:,:,channel));
        tempChannel(mask) = (1 - alpha) * tempChannel(mask) + ...
                             alpha * avgColor(channel);
        outputImg(:,:,channel) = uint8(tempChannel);
    end
end

% Display the result
imshow(outputImg);
title('Brush Effect with Transparency');

% Save output into the repo structure
outPath = fullfile(outDir, 'Billie_brush_effect.png');
imwrite(outputImg, outPath);

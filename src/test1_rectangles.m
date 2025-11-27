clc; clear; close all;

%% Locate this script and the project root
thisFile = mfilename('fullpath');     % full path to this .m file
thisDir  = fileparts(thisFile);       % folder containing this file
projectRoot = fileparts(thisDir);     % go up one level (repo root)

%% Build paths relative to the repo
imgPath = fullfile(projectRoot, 'images', 'Billie.png');
outDir  = fullfile(projectRoot, 'experiments', 'rectangles', 'output');

% Make sure the output folder exists
if ~exist(outDir, 'dir')
    mkdir(outDir);
end

%% Read the original image
img = imread(imgPath);  % now uses the image in /images/
[rows, cols, channels] = size(img);

% Define the range for random rectangle sizes
minWidth = 24;   % Minimum rectangle width
maxWidth = 40;   % Maximum rectangle width
minHeight = 16;  % Minimum rectangle height
maxHeight = 32;  % Maximum rectangle height

% Create an output image filled with black (same size as original)
outputImg = zeros(size(img), 'uint8');

% Generate a grid of points covering the image
rowStep = maxHeight - 24; % Step size based on max size to ensure coverage
colStep = maxWidth  - 24;
[Xgrid, Ygrid] = meshgrid(1:colStep:cols, 1:rowStep:rows);

% Flatten the grid points into a list
rectangleCenters = [Ygrid(:), Xgrid(:)];

% Loop through and place rectangles
for i = 1:size(rectangleCenters, 1)
    % Extract the center point
    row = rectangleCenters(i, 1);
    col = rectangleCenters(i, 2);

    % Generate random rectangle dimensions within the given range
    rectWidth  = randi([minWidth, maxWidth]);
    rectHeight = randi([minHeight, maxHeight]);
    halfWidth  = floor(rectWidth / 2);
    halfHeight = floor(rectHeight / 2);

    % Define the rectangle boundaries
    rowMin = max(row - halfHeight, 1);
    rowMax = min(row + halfHeight, rows);
    colMin = max(col - halfWidth, 1);
    colMax = min(col + halfWidth, cols);

    % Compute the average color inside this rectangle
    avgColor = zeros(1, 3);
    for channel = 1:channels
        region = img(rowMin:rowMax, colMin:colMax, channel);
        avgColor(channel) = mean(region(:));
    end

    % Fill the rectangle with the average color
    for channel = 1:channels
        outputImg(rowMin:rowMax, colMin:colMax, channel) = avgColor(channel);
    end
end

% Display the final image
imshow(outputImg);
title('Image Filled with Random-Sized Rectangles');

% Save the output image into the repo structure
outPath = fullfile(outDir, 'Billie_rectangles_output.jpg');
imwrite(outputImg, outPath);

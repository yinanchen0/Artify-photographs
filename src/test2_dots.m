clc; clear; close all;

%% Locate this script and the project root
thisFile = mfilename('fullpath');     % full path to this .m file
thisDir  = fileparts(thisFile);       % folder containing this file
projectRoot = fileparts(thisDir);     % go up one level (repo root)

%% Build paths relative to the repo
imgPath = fullfile(projectRoot, 'images', 'Billie.png');   % same image as rectangles
outDir  = fullfile(projectRoot, 'experiments', 'dots', 'output');

% Make sure the output folder exists
if ~exist(outDir, 'dir')
    mkdir(outDir);
end

%% Read the original image
img = imread(imgPath);
[rows, cols, channels] = size(img);

% Define the range for random circle sizes
minRadius = 2;   % Minimum radius
maxRadius = 10;  % Maximum radius

% Create an output image filled with black (same size as original)
outputImg = zeros(size(img), 'uint8');

% Generate a grid of points covering the image
rowStep = maxRadius - 5; % Step size based on max radius
colStep = maxRadius - 5;
[Xgrid, Ygrid] = meshgrid(1:colStep:cols, 1:rowStep:rows);

% Flatten grid into a list of center points
circleCenters = [Ygrid(:), Xgrid(:)];

%% Loop through and draw circles
for i = 1:size(circleCenters, 1)
    row = circleCenters(i, 1);
    col = circleCenters(i, 2);

    % Random radius
    radius = randi([minRadius, maxRadius]);

    % Mask for this circle
    [X, Y] = meshgrid(1:cols, 1:rows);
    mask = ((X - col).^2 + (Y - row).^2) <= radius^2;

    % Compute average color inside the mask
    avgColor = zeros(1, 3);
    for channel = 1:channels
        pixels = img(:,:,channel);
        pixels = pixels(mask);
        avgColor(channel) = mean(pixels);
    end

    % Apply average color to output
    for channel = 1:channels
        temp = outputImg(:,:,channel);
        temp(mask) = avgColor(channel);
        outputImg(:,:,channel) = temp;
    end
end

%% Display the final processed image
imshow(outputImg);
title('Image Filled with Random-Sized Circles (Dots)');

%% Save output image
outPath = fullfile(outDir, 'Billie_dots_output.jpg');
imwrite(outputImg, outPath);

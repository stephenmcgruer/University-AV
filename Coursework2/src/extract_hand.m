function [ result ] = extract_hand(image, bg)
%EXTRACT_HAND Extracts the hand from an image.
%   Does bg sub against an optional bg (loads default otherwise),
%   thresholds, etc. Returns a matrix the same size as the image but
%   1/0 for features.

% Matching on just the red colour spectrum produces better results.
image(:, :, 2) = 0;
image(:, :, 3) = 0;

% Apply background subtraction.
difference = rgb2gray(image - bg);

% Saturate the image (improves the capture of the scissors movement
% and some rock movements.)
difference = imadjust(difference);

% Threshold to a binary image.
threshold = graythresh(difference);
difference = im2bw(difference, threshold);

% Now erode/refill the image to clean it.
struct_elem = strel('octagon', 3);
difference = imerode(difference, struct_elem);
difference = imdilate(difference, struct_elem);
difference = imdilate(difference, struct_elem);
difference = imerode(difference, struct_elem);

% Locate the biggest item.
label = bwlabel(difference, 4);
properties = regionprops(label, 'Area'); %#ok<MRPBW>
biggest_area = max([properties.Area]);
index = find([properties.Area] == biggest_area);

result = ismember(label, index);

end


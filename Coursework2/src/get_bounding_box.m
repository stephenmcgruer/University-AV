function [ xmin, xmax, ymin, ymax, flipped ] = get_bounding_box( sequence )
%GET_BOUNDING_BOX Extracts the average bounding box for a set of images.
%   Returns the bounding box that covers the average detected objects in
%   a sequence of images. Assumes all images in a sequence are the same
%   size. Also determines if an image is left-handed and thus needs to be
%   flipped.

sequence_length = length(sequence);

image_width = size(sequence{1}, 2);

image_middle = image_width / 2;

% 1/5th of the number of images.
x = int8(sequence_length / 5);

flipped = 0;

[ymax, ymin, xmax, xmin, avgxs] = get_bbox(flipped);

% If the entering and exiting x values are to the left of the middle,
% the image likely needs to be flipped.
len = length(avgxs);
first_last = [avgxs(1:x); avgxs(len - x:len)];
flipped = sum(first_last < image_middle) == length(first_last);
if (flipped)
    [ymax, ymin, xmax, xmin] = get_bbox(flipped);
end

    function [ymax, ymin, xmax, xmin, avgxs] = get_bbox(flipped)
        % Finds the maximum and minimum x and y values for every image,
        % and the set of average x values as well.
        sequence_info = zeros(sequence_length, 6);
        for i = 1 : length(sequence)
            image = sequence{i};
            if (flipped),
                image = flipdim(image,2);
            end
            [row, col, ~] = find(image == 1);
            if (length(row) > 1),
                [ymax, ymin, xmax, xmin, avgy, avgx] = ...
                    findmaxmins(row, col);
                sequence_info(i,:) = [ ymax, ymin, xmax, xmin, avgy, avgx ];
            end
        end

        % Ignore any rows whose centre point is too far away from the 
        % average centre point. This is done to ignore the effects of
        % 'noise' frames.
        means = mean(sequence_info);
        avgx = means(6);
        thresh = 200;
        sequence_info(find(abs(sequence_info(:,6) - avgx) > thresh),:) = [];

        % Find the overall maximum and minimum x and y values.
        maxes = max(sequence_info);
        ymax = maxes(1);
        xmax = maxes(3);

        mins = min(sequence_info);
        ymin = mins(2);
        xmin = mins(4);
        
        avgxs = sequence_info(:,6);
        
    end

    function [ymax, ymin, xmax, xmin, avgy, avgx] = findmaxmins(row, col)
        % Finds the maximum, minimums, and averages for a single
        % image.
        ymax = max(row);
        ymin = min(row);
        xmax = max(col);
        xmin = min(col);
        avgy = mean(row);
        avgx = mean(col);
    end
end
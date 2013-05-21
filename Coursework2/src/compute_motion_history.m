function [ output_image ] = compute_motion_history( sequence, tau )
%COMPUTE_MOTION_HISTORY Computes the MHI for a sequence of images.
%   Assumes all images are the same size.
%
% The motion history image is computed as:
%
%   H_tau(x, y, t) = tau if D(x,y,t) = 1, else max(0, H_tau(x,y,t-1) - 1)
%
% D(x,y,t) is the binary image that shows motion - here we assume that
% each frame counts as showing motion.

% By default, tau is the total number of frames.
if nargin < 2
    tau = length(sequence);
end

output_image = zeros(size(sequence{1}));

% For each pixel in the image, tau is the frame number where the
% pixel last appeared as a 1.
pixels_in_frame = find(sequence{tau} == 1);
indices = [pixels_in_frame , ones(size(pixels_in_frame)) * tau ];
for frame = tau - 1 : -1 : 1,
    pixels_in_frame = setdiff(find(sequence{frame} == 1), indices(:,1));
    new_set_indices = ...
        [pixels_in_frame, ones(size(pixels_in_frame)) * frame ];
    indices = [indices ; new_set_indices ]; %#ok<AGROW>
end

output_image(indices(:,1)) = indices(:,2);
output_image = mat2gray(output_image);

end

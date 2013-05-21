function [ features ] = extract_features( prefix, dirs, background, display )
%EXTRACT_FEATURES Extracts the features from a set of image sequences.
%   Given a prefix path and a set of 1+ directories at that location,
%   returns a n-by-7 matrix, where each row i is a set of features for the
%   image sequence in the ith directory.
%
%   The features returned are the compactness and the 6 rotation invariant
%   moments. See www.inf.ed.ac.uk/teaching/courses/ivr/lectures/ivr5.pdf.
%
%   If the display parameter is set to 1, shows the individual hand frames,
%   bounded-box sequences, and motion history images for every sequence.

features = zeros(length(dirs), 7);
for i = 1 : size(dirs,1)
    files = dir(fullfile('..', prefix, dirs(i).name, '*.jpg'));
    num_files = size(files, 1);
   
    % Load each image in and attempt to extract the hand.
    frames = cell(1, num_files);
    for j = 1 : num_files
        tmp = imread(fullfile('..', prefix, dirs(i).name, files(j).name));
        
        frames{j} = extract_hand(tmp, background);
        
        % In debug mode, show the individual extracted-hand frames.
        if display
            imshow(frames{j});
            pause;
        end
    end

    % Find the average bounding box of the sequence, and if the sequence
    % needs to be flipped.
    [xmin xmax ymin ymax should_flip] = get_bounding_box(frames);

    % In debug mode, show a video of the sequence with the bounding box.
    if display
        for j = 1 : length(frames)
            image = frames{j};
            if should_flip
                image = flipdim(image, 2);
            end
            
            imshow(image);
            hold on;
            rectangle('Position', [xmin ymin xmax-xmin ymax-ymin], ...
                'LineWidth', 4, 'EdgeColor', 'r');
            hold off;
            pause(0.1);
        end
        pause
    end

    % Crop the sequence to the bounding box.
    cropped_frames = {};
    k = 1;
    for j = 1 : length(frames)
        image = frames{j};
        
        % All sequences are normalised (via mirroring) to be right-handed.
        if should_flip
            image = flipdim(image,2);
        end

        % Crop each image to the bounding box, and remove empty images.
        found = find(image == 1, 1);
        if (~isempty(found))
            newim = image(ymin:ymax, xmin:xmax);
            cropped_frames{k} = newim; %#ok<AGROW>

            k = k + 1;
        end
    end

    mhi = compute_motion_history(cropped_frames);

    % In debug mode, show the motion history image.
    if display
        imshow(mhi);
        pause;
    end

    features(i,:) = compute_mhi_features(mhi);
end

end


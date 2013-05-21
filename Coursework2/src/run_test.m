% This script tests our system on a set of test sequences found in
% the '../test' folder. The system is trained on sequences found in
% the '../train' folder.

%% Setup

% Debug mode switch.
display_mode = 1;

% Average the backgrounds
bg1 = imread('../backgrounds/background1.jpg');
bg2 = imread('../backgrounds/background2.jpg');
alpha = 0.2;
average_bg = (alpha * bg1) + (1 - alpha) * bg2;

% The training directories.
training_dirs = dir(fullfile('..', 'train', '*-*'));

% The test directories
test_dirs = dir(fullfile('..', 'test', 't*'));

% The training sequence classes: rock = 1, paper = 2, scissors = 3.
class_names = {'Rock', 'Paper', 'Scissors'};
classes = [ 2 2 2 1 1 1 3 3 3 3 2 1 3 2 1 1 1 1 3 3 3 2 2 2 ];

% If the training.mat file already exists, then we have
% pre-trained the features and so do not need to do the 
% extraction and training again.
pre_trained = exist('training.mat', 'file') > 0;

% How many features to use in the classifier.
NUM_FEATURES = 7;

%% Training Set Feature Extraction and Processing

if ~pre_trained
    disp('Beginning training set feature extraction.');

    training_features = extract_features('train', training_dirs, ...
        average_bg, 0); %display_mode);

    disp('Completed feature extraction');

    disp('Pre-processing the training features for the classifier.');

    reduced_training_features = ...
        training_features(1:length(training_dirs), 1:NUM_FEATURES);

    % Tie the training data to their classes, and sort them in order of class.
    reduced_training_features = [reduced_training_features, classes'];
    reduced_training_features = sortrows(reduced_training_features, ...
        NUM_FEATURES + 1);

    disp('Features processed.');
else
    disp('Skipping training feature extraction due to pre-trained data.');
end

%% Test Set Feature Extraction and Processing

disp('Beginning test set feature extraction.');

test_features = extract_features('test', test_dirs, average_bg, ...
    display_mode);
test_features = test_features(:, 1:NUM_FEATURES);

disp('Completed feature extraction');

%% Classification.

disp('Beginning classification.');

confusion_matrix = zeros(3, 3);

% If we have pre_trained, we should load the means and covs in.
if pre_trained
    disp('Using pre-trained classifier data.');
    load training.mat
else
    [means, covs] = train_classifier(reduced_training_features, 3);
    save('training.mat', 'means', 'covs');
end

% Run the classifier on the test data.
[confidence, output_classes] = test_classifier(test_features, means, ...
    covs);

disp('Finished classification.');
disp(' ');

% Display the results.
for j = 1 : size(test_dirs)
    disp(strcat('Class for test data ', test_dirs(j).name, ': '));
    disp(class_names(output_classes(j)));
    disp(' ');
end

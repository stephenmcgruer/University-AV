% This script performs an evaluation of our system, by extracting 
% features from the training data and then performing an 8-fold cross
% validation evaluation on the features.

%% Setup

% Debug mode switch.
display_mode = 0;

% Average the backgrounds
bg1 = imread('../backgrounds/background1.jpg');
bg2 = imread('../backgrounds/background2.jpg');
alpha = 0.2;
average_bg = (alpha * bg1) + (1 - alpha) * bg2;

% The training directories.
dirs = dir(fullfile('..', 'train', '*-*'));

% The sequence classes: rock = 1, paper = 2, scissors = 3.
classes = [ 2 2 2 1 1 1 3 3 3 3 2 1 3 2 1 1 1 1 3 3 3 2 2 2 ];

%% Feature Extraction

disp('Beginning feature extraction.');

features = extract_features('train' , dirs, average_bg, display_mode);

disp('Completed feature extraction');

%% Feature processing

disp('Pre-processing the features for the classifier.');

% How many features to use in the classifier.
NUM_FEATURES = 6;

reduced_features = features(1:24, 1:NUM_FEATURES);

% Tie the training data to their classes, and sort them in order of class.
reduced_features = [reduced_features, classes'];
reduced_features = sortrows(reduced_features, NUM_FEATURES + 1);

disp('Features processed.');

%% Testing on the validation set

disp('Beginning testing.');

% The number of tests to run.
NUM_TESTS = 8;

confusion_matrix = zeros(3, 3);

% Testing using 8-fold cross validation: for each test, three of the
% training sequences are extracted and used to test a classifier trained
% on the remaining twenty-one sequences.
for i = 1 : NUM_TESTS
    % Select one sequence each from the the rock, paper and scissor
    % classes, to use as validation data.
    test_rows = [i, NUM_TESTS + i, (2 * NUM_TESTS) + i];

    % Remove the validation data from the training data.
    feature_train = reduced_features;
    feature_train(test_rows, :) = [];

    % Train a classifier.
    [means, covs] = train_classifier(feature_train, 3);

    validation_data = reduced_features(test_rows, 1:NUM_FEATURES);

    % Test the classifier on the validation data.
    [confidence, output_classes] = test_classifier(validation_data, ...
        means, covs);

    % Update the confusion matrices. The output classes should be
    % [1 2 3] for each iteration.
    for j = 1 : 3
        confusion_matrix(j, output_classes(j)) = ...
            confusion_matrix(j, output_classes(j)) + 1;

        if output_classes(j) == j
            disp(['RIGHT: Confidence ' num2str(confidence(j))]);
        else
            disp(['WRONG: Confidence ' num2str(confidence(j))]);
        end
    end
end

disp('Finished testing.');

disp('Results:');
confusion_matrix %#ok<NOPTS>
disp('Accuracy:')
disp(strcat(num2str(sum(diag(confusion_matrix))), ' / 24'));

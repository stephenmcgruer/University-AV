function [means, covariances] = train_classifier(features, num_classes)
%TRAIN_CLASSIFIER Trains a multivariate gaussian classifier.
%  Computes the means and covariances for a set of features

means = cell(1, num_classes);
covariances = cell(1, num_classes);

% The dimensionality is size - 1, as the last column of the features
% is the class.
dim = size(features, 2) - 1;

num_examples = size(features, 1) / num_classes;

% For each class, compute the means of the features for that
% class.
for i = 1 : num_classes,
    start_point = (num_examples * (i - 1)) + 1;
    class_features = ...
        features(start_point:start_point + (num_examples - 1), 1:dim);

    means{i} = mean(class_features);
    covariances{i} = cov(class_features);
end

end
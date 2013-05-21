function [confidence, classes] = test_classifier(features, means, covs)
%TEST_CLASSIFIER Classifies a set of features via a multivariate gaussian.
%  The gaussian is parameterised by a set of means and covariances, with
%  one parameter set per class.

num_tests = size(features, 1);

num_classes = size(means, 2);
num_features = size(features, 2);

classes = zeros(1, num_tests);
confidence = zeros(1, num_tests);
for j = 1 : num_tests
        probs = zeros(1,3);
        feature = features(j, 1:num_features);

        % For each class, calculate the probability based on a
        % multivariate gaussian.
        for i = 1 : num_classes
            diff = feature - means{i};
            cov = covs{i};
            %invcov = inv(cov);
            prob = 1 / sqrt(det(2 * pi * cov));
            mantissa = -0.5 * (diff * (cov \ diff'));
            prob = prob * exp(mantissa);
            probs(i) = prob;
        end

        % Select the class with the maximum probability.
        [p, class] = max(probs);
        classes(j) = class;
        confidence(j) = p / sum(probs);
end

end

function mid = compute_mhi_features ( image )
%COMPUTE_MHI_FEATURES Computes the features for an MHI.
%   The features returned are the compactness and the 6 rotation invariant
%   moments described in IVR (lecture 5.)

area = sum(sum(image));
perimeter = bwarea(bwperim(image, 8));
compactness = perimeter^2 / (4 * pi * area);

% The centre of mass calculation is weighted with regards to the 
% MHI value at each pixel.
mean_img = [0, 0];
for i = 1 : size(image, 1),
    for j = 1 : size(image, 2),
        mean_img = [ mean_img(1) + (i * image(i, j)) , ...
                     mean_img(2) + (j * image(i, j)) ];
    end
end
mean_img = [mean_img(1) / area, mean_img(2) / area];

% Calculate the complex central moments, adapted for a MHI.

% Compute (r - r_m), for all values of r.
rcs = repmat(1:size(image, 1), size(image, 2), 1)';
rcs = rcs - mean_img(1);

% Compute i(c - c_m), for all values of c.
sqrts = sqrt(-1) * ((1:size(image, 2)) - mean_img(2));
cs = repmat(sqrts, size(image, 1), 1);

% Compute (r - r_m) +- i(c - c_m), for all values of r and c.
% For some reason, using only (r - r_m) + i(c - c_m) makes the
% classifier a lot more accurate.
rcs_p = rcs + cs;
rcs_n = rcs - cs;

% Calculate the scale invariant moments.
s11 = find_c(1,1) / area^2;
s20 = find_c(2,0) / area^2;
s21 = find_c(2,1) / area^2.5;
s12 = find_c(1,2) / area^2.5;
s30 = find_c(3,0) / area^2.5;

% Calculate the rotation invariant moments.
ci = zeros(6, 1);
ci(1) = real(s11);
ci(2) = 1000 * real(s21 * s12);
ci(3) = 10000 * real(s20 * s12 * s12);
ci(4) = 10000 * imag(s20 * s12 * s12);
ci(5) = 1000000 * real(s30 * s12 * s12 * s12);
ci(6) = 1000000 * imag(s30 * s12 * s12 * s12);

mid = [compactness; ci];

    function c0 = find_c(u,v)
        rc_u = rcs_p.^u;
        rc_v = rcs_n.^v;
        rc_uv = rc_u .* rc_v;
        rc_uv = rc_uv .* image;
        c0 = sum(sum(rc_uv));
    end
end
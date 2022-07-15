function Z_fitted = tif_2d_super_gauss(X, Y, t, params)
% Function:
%   Z_fitted = BRFGaussian2D(X, Y, t, params)
% Purpose:
%   2D Gaussian Beam removal function model:
%       Z(X, Y) = tt*A*exp(-((X-u_x)^2/2*sigma_x^2+(Y-u_y)^2/2*sigma_y^2))
% Inputs:
%      X, Y: 2D x, y coordinate grids
%         t: 1D array of scalar of dwell time in seconds [s]
%    params: 1D array of the BRF parameters, e.g 
%            [A, p, sigmax, sigmay, ux1, uy1, ux2, uy2, ...]
% Outputs:
%  z_fitted: 2D matrix or 1D array of the calculated 2D Gaussian 
%            function map [m]
%
% Info:
%   Contact: tianyiwang666@gmail.com (Dr WANG Tianyi)
%   Copyright reserved.
%--------------------------------------------------------------------------
% Get the parameters
A = params(1);
p = params(2);
sigmax = params(3);     sigmay = params(4);
ux = params(5:2:end);   uy = params(6:2:end);

% Feed the result
Z_fitted = zeros(size(X));

for i = 1:length(t)
    Z_fitted(:, :, i) = A*t(i)*exp(-((X(:, :, i)-ux(i)).^2/(2*sigmax.^2) + (Y(:, :, i)-uy(i)).^2/(2*sigmay.^2)).^p);
end

end
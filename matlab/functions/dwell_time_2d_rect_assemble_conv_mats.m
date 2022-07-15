function [Bdg, Bca] = dwell_time_2d_rect_assemble_conv_mats(...
    tif_params, ... tif parameters
    X, Y, ... coordinates of Z_to_remove
    Xp, Yp, ... dwell positions
    Xtif, Ytif, Ztif, ... an existing tif, if provided
    ca_range, ... range of the clear aperture in X, Y
    resampling_method ... use 'model' or 'avg'
)
% Purpose:
%   Assemble the convolution matrices B and Bca for the dwell grid and
%   clear aperture, respectively
%
% Matrix B is assembled as below:
%
%   | z1 |     | b11    b12    ...    b1Nt | | t1 |
%   | z2 |     | b21    b22    ...    b2Nt | | t2 |
%   | .  |     |  .      .      .       .  | | .  |
%   | .  |     |  .      .      .       .  | | .  |
%   | .  |     |  .      .      .       .  | | .  |
%   | zNr|     | b21    b22    ...    b2Nt | | tNt|
%
% Reference:
%   Zhou, L., Dai, Y. F., Xie, X. H., Jiao, C. J., & Li, S. Y. (2007).
%   Model and method to determine dwell time in ion beam figuring.
%   Nanotechnol. Precis. Eng., 5(8–9), 107-112.
%
% Info:
%   Contact: tianyiwang666@gmail.com (Dr WANG Tianyi)
%   Copyright reserved.

%% 1. Obtain & calculate the required parameters
% number of rows for Bca
rows_Bca = (ca_range.ve - ca_range.vs + 1) * (ca_range.ue - ca_range.us + 1);

% get the ca coordinates
Xca = X(ca_range.vs: ca_range.ve, ca_range.us: ca_range.ue);
Yca = Y(ca_range.vs: ca_range.ve, ca_range.us: ca_range.ue);

% Dump X_P, Y_P dwell point positions into a 2D array as
%   |  u1    v1 |   P1
%   |  u2    v2 |   P2
%   | ...   ... |  ...
%   |  uNt   vNt|   PNt
P = [Xp(:), Yp(:)];
Nt = size(P, 1);
Nr = numel(X);

%% 2. Assemble the matrices B and Bca
Bca = zeros(rows_Bca, Nt);
Bdg = zeros(Nr, Nt);

% pre-compute the interpolant for 'avg' tif
if strcmpi(resampling_method, 'interp')
    F = griddedInterpolant(Xtif', (-Ytif)', flipud(Ztif)', 'cubic', 'none');
end

for i = 1: Nt
    Yk = Y - P(i, 2);    % yk - vi
    Xk = X - P(i, 1);    % xk - ui
    
    Yk_ca = Yca - P(i, 2);
    Xk_ca = Xca - P(i, 1);
    
    if strcmpi(resampling_method, 'interp')
        z_tif = F(Xk', Yk');
        z_tif = z_tif';
        z_tif(~isfinite(z_tif))=0;
        
        z_tif_ca = F(Xk_ca', Yk_ca');
        z_tif_ca = z_tif_ca';
        z_tif_ca(~isfinite(z_tif_ca)) = 0;
        
    elseif strcmpi(resampling_method, 'model')
        a = tif_params.a;    % peak removal rate [m/s]
        p = tif_params.p;
        sigma = tif_params.sigma;    % standard deviation [m]
        mu = [0, 0];    % center is at [0, 0] [m]
        
        z_tif = tif_2d_super_gauss(Xk, Yk, 1,[A; p; sigma(:); mu(:)]);
        z_tif_ca = tif_2d_super_gauss(Xk_ca, Yk_ca, 1,[A; p; sigma(:); mu(:)]);
    end
    
    Bdg(:, i) = z_tif(:);
    Bca(:, i) = z_tif_ca(:);
end

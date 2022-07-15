function [t, Zca, Zca_removal, Zca_residual] = dwell_time_2d_rect_udo(...
    Xdg, ... dwell grid x coordinates
    Ydg, ... dwell grid y coordinates
    Zdg, ... dwell grid heights
    tif_params, ... tif parameters
    Xtif, ... tif x coordinates
    Ytif, ... tif y coordinates
    Ztif, ... tif heights
    Xp, ... dwell points x coordinates
    Yp, ... dwell points y coordinates
    ca_range, ... clear aperture range
    resampling_method, ... 'model' or 'interp'
    is_standarized, ... standarization or not
    Bdg, ... tif matrix for the dwell grid
    Bca ... tif matrix for the clear aperture
)
%-------------------------------------------------------------------------%
% Purpose:
%     Implement the Universal Dwell Time Agorithm for rectangular
%     surfaces without iterative refinement
% Reference:
%     Wang, Tianyi, et al. "Universal dwell time optimization for 
%     deterministic optics fabrication." Optics Express 29.23 (2021): 
%     38737-38757.
% Info:
%   Contact: tianyiwang666@gmail.com (Dr WANG Tianyi)
%   Copyright reserved.
%-------------------------------------------------------------------------%

%% 1. Build the matrix B if not provided
Xca = Xdg(ca_range.vs:ca_range.ve, ca_range.us:ca_range.ue);
Yca = Ydg(ca_range.vs:ca_range.ve, ca_range.us:ca_range.ue);
Zca = Zdg(ca_range.vs:ca_range.ve, ca_range.us:ca_range.ue);
Zca = Zca - nanmin(Zca(:));
z_to_remove_ca = Zca(:);

if nargin == 12
    % Assemble the BRF matrix C, size(C) = Nr x Nt and vector d, Cx = d
    [Bdg, Bca] = dwell_time_2d_rect_assemble_conv_mats(...
        tif_params, ...
        Xdg, ...
        Ydg, ...
        Xp, ...
        Yp, ...
        Xtif, ...
        Ytif, ...
        Ztif, ...
        ca_range, ...
        resampling_method...
    );
    
elseif nargin == 13
    error('Both B_dg and B_ca should be input');
    
end

if is_standarized == true
    Zdg = Zdg - nanmean(Zdg(:));
end


%% 2.Optimize t
t = udo_gamma_optimization(z_to_remove_ca, Zdg(:), Bca, Bdg);


%% 3. Results
z_removal_ca = Bca * t;
z_residual_ca = z_to_remove_ca - z_removal_ca;
Zca_removal = reshape(z_removal_ca, size(Zca));
Zca_residual = reshape(z_residual_ca, size(Zca));
Zca_residual = remove_polynomials(Xca, Yca, Zca_residual, 1);

end

function t = udo_gamma_optimization(...
    z_to_remove_ca, ...
    z_to_remove_dg, ...
    Bca, ...
    B_dg ...
)
z_dg_2_dp = B_dg'*z_to_remove_dg;    % transform z_dg to the dwell potions' space
z_dg_2_dp = z_dg_2_dp - nanmin(z_dg_2_dp);    % non-negative adjustment

% initial least squares' guess of gamma
gamma0 = (B_dg * (B_dg' * z_to_remove_dg)) \ z_to_remove_dg;

% optimize gamma via patternsearch or Nelder Mead, both work
gamma_opt = patternsearch(...
    @(gamma)objective_function_for_gamma_optimization(gamma, Bca, z_to_remove_ca, z_dg_2_dp),...
    gamma0...
);

% calculate t based on the optimized gamma
t = gamma_opt * z_dg_2_dp;

end

function fGamma = objective_function_for_gamma_optimization(...
    gamma, ...
    B_ca, ...
    z_to_remove_ca, ...
    z_to_remove_dg...
)
% dwell time based on the current gamma
t = gamma * z_to_remove_dg;

% rms of the residual in the clear aperture
fGamma = rms_std(z_to_remove_ca - B_ca*t);
end
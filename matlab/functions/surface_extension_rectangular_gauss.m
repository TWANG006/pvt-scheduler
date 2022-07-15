function [Xext, Yext, Zext, caRange] = surface_extension_rectangular_gauss(...
    X, Y, Z,...unextended surface error map
    tifParams,...brf parameters [m/pxl]
    Ztif...TIF profile
    )
% Purpose
%   Extend the surface error map using spline interpolation
% Info:
%   Contact: tianyiwang666@gmail.com (Dr WANG Tianyi)
%   Copyright reserved.
%--------------------------------------------------------------------------

%% 0. Obtain required parameters
% Sampling intervals
surfMpp = median(diff(X(1,:)));    % surface sampling interval [m/pxl]
sigma = tifParams.sigma(1);

m = size(Z,1);  % CA height [pixel]
n = size(Z,2);  % CA width [pixel]

m_ext = floor(tifParams.tifMpp*(size(Ztif, 1))*0.5/surfMpp);   % ext size in y [pixel]
n_ext = floor(tifParams.tifMpp*(size(Ztif, 2))*0.5/surfMpp);   % ext size in x [pixel] 

% y start & end ids of CA in FA [pixel]
caRange.vs = m_ext + 1;   
caRange.ve = caRange.vs + m - 1;   

% x start & end ids of CA in FA [pixel]
caRange.us = n_ext + 1;   
caRange.ue = caRange.us + n - 1;   


%% 1. Initial extension matrices
% extension sizes
[Xext, Yext] = meshgrid(-n_ext:n-1+n_ext, -m_ext:m-1+m_ext);  %extension grid
Yext = m - 1 - Yext;
Xext = Xext*surfMpp + X(1, 1);  % adjust X grid add X(1,1)
Yext = Yext*surfMpp + Y(end, end);  ... adjust Y grid add Y(1,1)
Zext = NaN(size(Xext));   ... mark the Z_ext to NaN
Zext(caRange.vs: caRange.ve, caRange.us: caRange.ue) = Z;... fill in the valid data point


%% Finding edge points
id_edg = surface_extension_rectangular_edge_extraction(Zext);
uedg = Xext(id_edg);
vedg = Yext(id_edg);
z_edg = Zext(id_edg);

id_fil = isnan(Zext);  % filled data ids
x_fil = Xext(id_fil);  % x coordinates of filled data
y_fil = Yext(id_fil);  % y coordinates of filled data

%% Calculate the gaussian profile
gaussProfiles = zeros*x_fil;
for k = 1:length(x_fil)
    % min distances from filled points to edge points
    [min_dist, i] = min(sqrt((x_fil(k) - uedg).^2+(y_fil(k) - vedg).^2));
    
    % calculate the fall profile
    gaussProfiles(k) = z_edg(i) * exp(-min_dist.^2/(2*sigma.^2));
end

Zext(id_fil) = gaussProfiles;


end
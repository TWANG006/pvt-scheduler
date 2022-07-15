function [Xext, Yext, Zext, caRange] = surface_extension_rectangular_smooth(...
    X, Y, Z,...unextended surface error map
    tifMpp,...TIF sampling interval [m/pxl]
    Ztif...TIF profile
    )
% Function
%   [X_ext, Y_ext, Z_ext] = Surface_Extenstion_Spline(X, Y, Z, X_tif, Y_tif, Z_tif)
% Purpose
%   Extend the surface error map using spline interpolation

%% 0. Obtain required parameters
% Sampling intervals
surfMpp = median(diff(X(1,:)));  % surface sampling interval [m/pxl]

m = size(Z,1);  % CA height [pixel]
n = size(Z,2);  % CA width [pixel]

m_ext = floor(tifMpp*(size(Ztif, 1))*0.5/surfMpp);  % ext size in y [pixel]
n_ext = floor(tifMpp*(size(Ztif, 2))*0.5/surfMpp);  % ext size in x [pixel] 

caRange.vs = m_ext + 1;   caRange.ve = caRange.vs + m - 1;   ... y start & end ids of CA in FA [pixel]
caRange.us = n_ext + 1;   caRange.ue = caRange.us + n - 1;   ... x start & end ids of CA in FA [pixel]


%% 1. Initial extension matrices
% extension sizes
[Xext, Yext] = meshgrid(-n_ext: n-1+n_ext, -m_ext: m-1+m_ext);  ...extension grid
Yext = m - 1 - Yext;
Xext = Xext*surfMpp + X(1, 1);  ... adjust X grid add X(1,1)
Yext = Yext*surfMpp + Y(end, end);  ... adjust Y grid add Y(1,1)
id = ~isnan(Z);

%% 2. Extension
F = scatteredInterpolant(X(id), Y(id), Z(id), 'natural');
Zext = F(Xext, Yext);




end
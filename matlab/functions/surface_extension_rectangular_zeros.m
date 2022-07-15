function [Xext, Yext, Zext, caRange] = surface_extension_rectangular_zeros(...
    X, Y, Z,...unextended surface error map
    tifMpp,...TIF sampling interval [m/pxl]
    Ztif...TIF profile
    )
% Info:
%   Contact: tianyiwang666@gmail.com (Dr WANG Tianyi)
%   Copyright reserved.
%--------------------------------------------------------------------------

%% 0. Obtain required parameters
% Sampling intervals
surfMpp = median(diff(X(1,:)));    ... surface sampling interval [m/pxl]

m = size(Z,1);  % CA height [pixel]
n = size(Z,2);  % CA width [pixel]

mExt = floor(tifMpp*(size(Ztif, 1))*0.5/surfMpp);  % ext size in y [pixel]
nExt = floor(tifMpp*(size(Ztif, 2))*0.5/surfMpp);  % ext size in x [pixel] 

% y start & end ids of CA in FA [pixel]
caRange.vs = mExt + 1;
caRange.ve = caRange.vs + m - 1;

% x start & end ids of CA in FA [pixel]
caRange.us = nExt + 1;   
caRange.ue = caRange.us + n - 1;


%% 1. Initial extension matrices
% extension sizes
[Xext, Yext] = meshgrid(-nExt: n-1+nExt, -mExt :m-1+mExt);
Yext = m - 1 - Yext;
Xext = Xext*surfMpp + X(1, 1);  % adjust X grid add X(1,1)
Yext = Yext*surfMpp + Y(end, end);  % adjust Y grid add Y(1,1)


%% 2. Extend the surface with 0
Zext = zeros(size(Xext));   % initialize the Zext to zeros

% fill in the valid data point
Zext(caRange.vs: caRange.ve, caRange.us: caRange.ue) = Z;


end
function Zfall = surface_extension_rectangular_fall(...
    Xext, Yext, Zext,...extended surface
    caRange,...ca range in pixels
    tifParams,...brf parameters
    Ztif...tif profile
    )
% Purpose
%   Apply the fall profile to the extended part of the surface
% Info:
%   Contact: tianyiwang666@gmail.com (Dr WANG Tianyi)
%   Copyright reserved.
%--------------------------------------------------------------------------

%% Obtain parameters
r = max(size(Ztif)-1) * tifParams.lat_res_brf * 0.5; ... radius of the TIF

Zfall = NaN(size(Zext));   ... initial extension matrix with NaNs
Zfall(caRange.vs: caRange.ve, caRange.us: caRange.ue) = 1;    ... fill 1 in the valid data point

%% Finding edge points
idEdg = surface_extension_rectangular_edge_extraction(Zfall);
uedg = Xext(idEdg);
vedg = Yext(idEdg);

%% Obtain the filled & original ids
idFil = isnan(Zfall); ... filled data ids
xfil = Xext(idFil);  ... x coordinates of filled data
yfil = Yext(idFil);  ... y coordinates of filled data

%% Calculate fall profiles
fun = @(x, A, sigma) A*exp(-(x).^2/(2*sigma.^2));
B = 1/integral(@(x)fun(x,tifParams.A, tifParams.sigma_xy(1)), -(r), r);

fallProfiles = zeros*xfil;
for k = 1:length(xfil)
     % calculate the fall profile
    fallProfiles(k) = B*integral(@(x)fun(x,tifParams.A, tifParams.sigma_xy(1)), -(r-min(sqrt((xfil(k) - uedg).^2+(yfil(k) - vedg).^2))), r);   
end

Zfall(idFil) = fallProfiles;
Zfall = Zext.*Zfall;


end
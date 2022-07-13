clear;
close all;
clc;

addpath('../../../5-functions/');

%% dirs and files
% initial surface error dir
surfDir = '../../data/';
surfFile = 'initial_map_rectangular_pap_60mm.mat';
outDir = '../../data/sim_data/';

%% clean initial surface map
load([surfDir surfFile]);
n = min(size(Z));
X = X(1: n, 1: n);
Y = Y(1: n, 1: n);
Z = Z(1: n, 1: n);

X = X - nanmean(X(:));
Y = Y - nanmean(Y(:));
Z = RemoveSurface1(X, Y, Z);
Z = Z - nanmin(Z(:));

% display the initial surf
fsfig('');
ShowSurfaceMap(X, Y, Z);


%% clean tifs
% tif radii
r1 = 10e-3; 

% sampling interval
tifMpp = 0.1e-3; 

% PRRs
a1 = 20e-9;

% half sizes
hf1 = fix(r1/tifMpp); 

% sigmas
sigma1 = 2*r1 * 0.167;

% tif 1
[Xtif1, Ytif1] = meshgrid(-hf1: hf1, -hf1: hf1);
Xtif1 = Xtif1 * tifMpp;
Ytif1 = -Ytif1 * tifMpp;
Ztif1 = BRFGaussian2D(Xtif1, Ytif1, 1, [a1, sigma1, sigma1, 0, 0]);
tif1Params.A = a1;
tif1Params.sigma_xy = [sigma1, sigma1];
tif1Params.mu_xy = [0, 0];

% display
fsfig('');
ShowSurfaceMap(Xtif1, Ytif1, Ztif1);


%% generate tool path
% minX = min(min(X));    maxX = max(max(X));
% minY = min(min(Y));    maxY = max(max(Y));
% 
% % genereate dwell positions for tif 1
% i1 = round(r1*2*pi/18*1e3, 1)*1e-3;
% [Xp1, Yp1, xp1, yp1] = Raster_Tool_Path(...
%     (minX - r1),...
%     (maxX + r1),...
%     i1,...
%     (minY - r1),...
%     (maxY + r1),...
%     i1...
% );


[Dx, Dy, xp, yp] = maze_path(10, 0.5)
xp1 = Dx * 1e-3;
yp1 = Dy * 1e-3;

% display
fsfig('');
plot(xp1, yp1, 'r-*');axis xy tight equal;

%% Save the cleaned data
outFile = [outDir mfilename '_rect_60mm_tif_' ...
    num2str(r1*1e3) 'mm' '.mat'];

save(outFile, ...
    'X', 'Y', 'Z', ...
    'Xtif1', 'Ytif1', 'Ztif1', 'tif1Params', ...
    'xp1', 'yp1' ...
);
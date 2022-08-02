clear;
close all;
clc;

addpath('../../../5-functions/');
addpath('../scripts/');

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

Zca = imresize(Z, 1/5);
[Xca, Yca] = meshgrid(0:size(Zca,2)-1, 0:size(Zca,1)-1); 
surf_mpp = median(diff(X(1, :)));
Xca = Xca * surf_mpp;
Yca = (max(Yca(:)) - Yca) * surf_mpp;
Xca = Xca - nanmean(Xca(:));
Yca = Yca - nanmean(Yca(:));
Zca = Zca - nanmin(Zca(:));
r0 = 0.5 * (max(Xca(:)) - min(Xca(:)));

% display the initial surf
fsfig('');
ShowSurfaceMap(Xca, Yca, Zca);

%% clean tifs
% tif radii
r1 = 2e-3; 

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
figure;

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

% [px, py, xp, yp] = maze_path(round(4*(4e-3)*1e3), 0.125); % interval ×0.25
% [px, py, xp, yp] = maze_path(round(2*(r1+r0)*1e3), 0.25); % interval ×0.25
[px, py, xp, yp] = maze_path(round((r1+r0)*1e3), 0.5);
px = px * 1e-3;
py = py * 1e-3;
xp = xp(1:end-1) * 1e-3;
yp = yp(1:end-1) * 1e-3;

i_num = 12;
xp = xp(1:i_num-1);
yp = yp(1:i_num-1);
px = px(1:i_num);
py = py(1:i_num);

% display
fsfig('');
plot(xp, yp, 'r-*');axis xy tight equal;

%% Save the cleaned data
outFile = [outDir mfilename '_rect_60mm_tif_' ...
    num2str(r1*1e3) 'mm' '.mat'];

save(outFile, ...
    'X', 'Y', 'Z', ...
    'Xca', 'Yca', 'Zca', ...
    'Xtif1', 'Ytif1', 'Ztif1', 'tif1Params', ...
    'xp', 'yp', 'px', 'py' ...
);
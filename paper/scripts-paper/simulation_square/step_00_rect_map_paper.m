clear;
% close all;
clc;

addpath('../../../matlab/functions/');

%% dirs and files
% initial surface error dir
surfDir = '../../../data/';
surfFile = 'initial_map_rectangular_pap_60mm.mat';
outDir = '../../../data/paper_data/';

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

Zca = imresize(Z, 1/5); % 1/5
[Xca, Yca] = meshgrid(0:size(Zca,2)-1, 0:size(Zca,1)-1); 
surf_mpp = median(diff(X(1, :)));
Xca = Xca * surf_mpp;
Yca = (max(Yca(:)) - Yca) * surf_mpp;
Xca = Xca - nanmean(Xca(:));
Yca = Yca - nanmean(Yca(:));
Zca = Zca - nanmin(Zca(:));
r0 = 0.5 * (max(Xca(:)) - min(Xca(:)));

Zca = Zca / 12; % reduce dwell time

% % display the initial surf
% fsfig('');
% ShowSurfaceMap(Xca, Yca, Zca);

%% bandpass fitting
W = gauss_regression_bandpass_fft_2d(...
    Zca, ... the vector of dimension n of the profile values before filtering
    median(diff(Xca(1,:))), ... the sampling interval in x
    median(diff(Xca(1,:))), ... the sampling interval in y
    1e-3, ... the low cut-off wavelength
    10e-3, ... the hight cut-off wavelength of 
    1 ... the order 
);

fsfig('');
subplot(2,2,1);
ShowSurfaceMap(Xca, Yca, Zca);

subplot(2,2,3);
ShowSurfaceMap(Xca, Yca, W, 3, true, 1e9, 'nm', 'bandpass fft');

subplot(2,2,4);
Zca = Zca - W;
ShowSurfaceMap(Xca, Yca, Zca, 3, true, 1e9, 'nm', 'after fitting');

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

%% generate tool path - raster path
minX = min(min(Xca));    maxX = max(max(Xca));
minY = min(min(Yca));    maxY = max(max(Yca));
% genereate dwell positions for tif 1
i1 = round(r1*2*pi/18*1e3, 1)*1e-3;
[Xp, Yp, xp, yp] = Raster_Tool_Path(...
    (minX - r1),...
    (maxX + r1),...
    i1,...
    (minY - r1),...
    (maxY + r1),...
    i1...
);

% dwell points
dwell_x = 0.5 * (xp(1 : end-1) + xp(2 : end));
dwell_y = 0.5 * (yp(1 : end-1) + yp(2 : end));
% dwell_x = [dwell_x; xp(end)];
% dwell_y = [dwell_y; yp(end)];

% path points
path_x = xp;
path_y = yp;

dwell_x = dwell_x';
dwell_y = dwell_y';
path_x = path_x';
path_y = path_y';

% display
fsfig('');
plot(dwell_x, dwell_y, 'r-o');axis xy tight equal;
hold on;
plot(path_x, path_y, 'b-*');
hold off;

%% generate tool path - maze path
% figure;
% [px, py, xp, yp] = maze_path(round(2*(r1+r0)*1e3), 0.25); % interval ×0.25
% % [px, py, xp, yp] = maze_path(round((r1+r0)*1e3), 0.5);
% px = px * 1e-3;
% py = py * 1e-3;
% xp = xp(1:end-1) * 1e-3;
% yp = yp(1:end-1) * 1e-3;
% 
% % display
% fsfig('');
% plot(xp, yp, 'r-*');axis xy tight equal;

%% Save the cleaned data
outFile = [outDir mfilename '_square_' num2str(round((max(Xca(:)) - min(Xca(:)))*1e3))  'mm_tif_' ...
    num2str(r1*1e3) 'mm' '.mat'];

save(outFile, ...
    'X', 'Y', 'Z', ...
    'Xca', 'Yca', 'Zca', ...
    'Xtif1', 'Ytif1', 'Ztif1', 'tif1Params', ...
    'dwell_x', 'dwell_y', 'path_x', 'path_y' ...
);
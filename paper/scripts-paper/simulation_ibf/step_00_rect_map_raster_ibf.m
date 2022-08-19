clear;
close all;
clc;

addpath('../../../functions/');

%% dirs and files
% initial surface error dir
surfDir = '../../../data/';
surfFile = 'step_01_multilayer_no1_data.mat';
tifFile = 'step_01_tif_5.0mm_20210604.mat';

outDir = '../../../data/paper_data/';

%% clean initial surface map
load([surfDir surfFile]);
Zca = Z_to_remove_ca;

% display the initial surf
fsfig('');
ShowSurfaceMap(Xca, Yca, Zca);

%% TIF params
load([surfDir tifFile]);
tifParams.A = aOpt;
tifParams.tif_mpp = tifMpp;
tifParams.sigma_xy = sigmaOpt;
tifParams.mu_xy = muOpt;

% radius of tif
r = 0.5 * (max(Xtif(:)) - min(Xtif(:))); 
r = round(r * 10000) / 10000;

% display
fsfig('');
ShowSurfaceMap(Xtif, Ytif, Ztif);

%% generate tool path
minX = min(min(Xca));    maxX = max(max(Xca));
minY = min(min(Yca));    maxY = max(max(Yca));

% genereate dwell positions for tif
i = 1e-3;
[Xp, Yp, xp, yp] = Raster_Tool_Path(...
    (minX - r),...
    (maxX + r),...
    i,...
    (minY - r),...
    (maxY + r),...
    i...
);

% dwell points
dwell_x = 0.5 * (xp(1 : end-1) + xp(2 : end));
dwell_y = 0.5 * (yp(1 : end-1) + yp(2 : end));
dwell_x = [dwell_x; xp(end)];
dwell_y = [dwell_y; yp(end)];

% path points
path_x = xp;
path_y = yp;

% display
fsfig('');
plot(dwell_x, dwell_y, 'r-*');axis xy tight equal;

%% Save the cleaned data
outFile = [outDir mfilename '_tif_' ...
    num2str(r*1e3) 'mm' '.mat'];

save(outFile, ...
    'Xca', 'Yca', 'Zca', ...
    'dwell_x', 'dwell_y',  ...
    'path_x', 'path_y',  ...
    'Xtif', 'Ytif', 'Ztif', 'tifParams' ...
);
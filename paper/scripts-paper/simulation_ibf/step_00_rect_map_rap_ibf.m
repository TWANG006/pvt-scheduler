clear;
% close all;
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
pathDir = '../../../data/paper_data/';
pathFile = 'XYPoint7a.mat';
load([pathDir pathFile]);

% dwell points
xp = xp - min(xp);
yp = yp - min(yp);

dwell_x = 0.5 * (xp(1 : end-1) + xp(2 : end));
dwell_y = 0.5 * (yp(1 : end-1) + yp(2 : end));
dwell_x = [dwell_x, xp(end)];
dwell_y = [dwell_y, yp(end)];

dwell_x = dwell_x + min(min(X_P));
dwell_y = dwell_y + min(min(Y_P));

% path points
path_x = xp + min(min(X_P));
path_y = yp + min(min(Y_P));


% display
% fsfig('');
% plot(dwell_x, dwell_y, 'r-');axis xy tight equal;
% fsfig('');
% plot(path_x, path_y, 'b-');axis xy tight equal;

fsfig('');
plot(dwell_x, dwell_y, 'ro');axis xy tight equal;
hold on;
plot(path_x, path_y, 'b-*');axis xy tight equal;
hold off;
%% Save the cleaned data
outFile = [outDir mfilename '_tif_' ...
    num2str(r*1e3) 'mm' '.mat'];

save(outFile, ...
    'Xca', 'Yca', 'Zca', ...
    'dwell_x', 'dwell_y',  ...
    'path_x', 'path_y',  ...
    'Xtif', 'Ytif', 'Ztif', 'tifParams' ...
);
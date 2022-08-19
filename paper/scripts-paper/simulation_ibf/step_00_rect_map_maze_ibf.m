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
name_path = 'path_1';
pathDir = '../../../data/sim_data/';
pathFile = 'stitch_Maze_1_dp.mat';
load([pathDir pathFile]);
surf_mpp = median(diff(X_P(1, :)));

if name_path == 'path_1'
    % dwell points
    dwell_x = dp_x * surf_mpp;
    dwell_y = dp_y * surf_mpp;
    dwell_x = dwell_x + min(min(X_P));
    dwell_y = dwell_y + min(min(Y_P));
    % path points
    path_x = xp * surf_mpp;
    path_y = yp * surf_mpp;
    path_x = path_x + min(min(X_P));
    path_y = path_y + min(min(Y_P));
end
if name_path == 'path_2'
    % dwell points
    dwell_x = xp * surf_mpp;
    dwell_y = yp * surf_mpp;
    dwell_x = dwell_x + min(min(X_P));
    dwell_y = dwell_y + min(min(Y_P));
    % path points
    path_x = dp_x * surf_mpp;
    path_y = dp_y * surf_mpp;
    path_x = path_x + min(min(X_P));
    path_y = path_y + min(min(Y_P));
end

% % Smooth the corners of the maze path
% dwell_x1 = dwell_x;
% dwell_y1 = dwell_y;
% for i = 2: size(dwell_x1, 2)-1
%     if (dwell_x1(i) == dwell_x1(i-1) && dwell_y1(i) == dwell_y1(i+1)) || (dwell_x1(i) == dwell_x1(i+1) && dwell_y1(i) == dwell_y1(i-1))
%         dwell_x(i) = 0.5*(path_x(i-1) + path_x(i));
%         dwell_y(i) = 0.5*(path_y(i-1) + path_y(i));
%     end        
% end

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
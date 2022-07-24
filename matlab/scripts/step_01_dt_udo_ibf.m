clear;
% close all;
clc;
addpath('../functions/');
addpath('../../../Slope-based-dwell-time/matlab/functions/'); % import rms_std
%% load data
surfDir = '../../data/';
surfFile = 'step_01_multilayer_no1_data.mat';
dataDir = '../../data/sim_data/';
pathFile = 'stitch_Maze_1_dp.mat';
outDir = '../../data/sim_data/';

load([surfDir surfFile]);
Zca = Z_to_remove_ca;
% xp = X_P(:);
% yp = Y_P(:);

load([dataDir pathFile]);
% adjust the maze path
surf_mpp = median(diff(X_P(1, :)));

% xp = dp_x * surf_mpp;
% yp = dp_y * surf_mpp;
% xp = xp + min(min(X_P));
% yp = yp + min(min(Y_P));

xp = xp * surf_mpp;
yp = yp * surf_mpp;
xp = xp + min(min(X_P));
yp = yp + min(min(Y_P));


% figure;
% plot(xp, yp, 'r-o');axis xy tight equal;
% axis equal;
% xlabel('x [mm]');
% ylabel('y [mm]');

precision = 1e-3;
precision_unit = 'nm';
min_t = 10e-2;

a = 20;
tifMpp = median(diff(Xtif(1, :)));
hf = 0.5* (size(Xtif,1)-1);
r = hf * tifMpp;
sigma = 2*r * 0.167;
tifParams.tif_mpp = median(diff(Xtif(1, :)));
tifParams.A = a;
tifParams.sigma_xy = [sigma, sigma];
tifParams.mu_xy = [0, 0];

%% dwell time
[t, Zremoval_ca, Zresidual_ca] = dwell_time_2d_rect_udo_rise(...
    Xca, ...
    Yca, ...
    Zca,...
    xp, ...
    yp, ...
    tifParams, ...
    'interp', ...
    Xtif, ...
    Ytif, ...
    Ztif, ...
    1e-9, ...
    6, 9, 'Chebyshev', ...
    6, 9, 'Chebyshev', ...
    0.5, ...
    10, ...
    min_t, ...
    1, ...
    false ...
);


%% display
fsfig('position mode');
subplot(241);
ShowSurfaceMap(Xca, Yca, Zca, 3, true, 1e9, 'nm', 'initial surface error');
subplot(242);
ShowSurfaceMap(Xtif, Ytif, Ztif, 0, false, 1e9, 'nm', 'TIF');
subplot(245);
ShowDwellTime(xp, yp, t, false, 0, 'jet', 'Dwell Time');  
subplot(246);
ShowSurfaceMap(Xca, Yca, Zca, 3, true, 1e9, 'nm', 'Clear Aperture');
subplot(247);
ShowSurfaceMap(Xca, Yca, Zremoval_ca, 3, true, 1e9, 'nm', 'Removed surface error');
subplot(248);
ShowSurfaceMap(Xca, Yca, Zresidual_ca, 3, true, 1e9, 'nm', 'Residual surface error');


%% save data
save([outDir mfilename '.mat'], ...
    'Xca', 'Yca', 'Zca',  ...
    'Zremoval_ca', ...
    'Zresidual_ca',  ...
    'xp', 'yp',  ...
    't', ...
    'Xtif', 'Ytif', 'Ztif'...
    );
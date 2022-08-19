clear;
% close all;
clc;

addpath('../../../matlab/functions/');
addpath('../../../../Slope-based-dwell-time/matlab/functions/'); % import rms_std

%% load data
surfDir = '../../../data/';
surfFile = 'step_01_multilayer_no1_data.mat';
dataDir = '../../../data/paper_data/';
pathFile = 'XY9.mat';
outDir = '../../../data/paper_data/';

load([surfDir surfFile]);
Zca = Z_to_remove_ca;

load([dataDir pathFile]);

%% tool path

% dwell points
dwell_x = 0.5 * (xp(1 : end-1) + xp(2 : end));
dwell_y = 0.5 * (yp(1 : end-1) + yp(2 : end));
dwell_x = [dwell_x, xp(end)];
dwell_y = [dwell_y, yp(end)];

path_x = xp;
path_y = yp;

interval_x = diff(xp);
interval_y = diff(yp);

% % Smooth the corners of the maze path
% dwell_x1 = dwell_x;
% dwell_y1 = dwell_y;
% for i = 2: size(dwell_x1, 2)-1
%     if (dwell_x1(i) == dwell_x1(i-1) && dwell_y1(i) == dwell_y1(i+1)) || (dwell_x1(i) == dwell_x1(i+1) && dwell_y1(i) == dwell_y1(i-1))
%         dwell_x(i) = 0.5*(path_x(i-1) + path_x(i));
%         dwell_y(i) = 0.5*(path_y(i-1) + path_y(i));
%     end        
% end

% figure;
% plot(dwell_x, dwell_y, 'r-o');axis xy tight equal;
% axis equal;
% xlabel('x [mm]');
% ylabel('y [mm]');

%% TIF params
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
min_t = 10e-2;
% precision = 1e-3;
% precision_unit = 'nm';

[t, Zremoval_ca, Zresidual_ca] = dwell_time_2d_rect_udo_rise(...
    Xca, ...
    Yca, ...
    Zca,...
    dwell_x, ... % dwell point
    dwell_y, ...
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
ShowDwellTime(dwell_x, dwell_y, t, false, 0, 'jet', 'Dwell Time');  
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
    'dwell_x', 'dwell_y',  ...
    'path_x', 'path_y',  ...
    't', ...
    'surf_mpp', ...
    'Xtif', 'Ytif', 'Ztif', ...
    'name_path' ...
    );
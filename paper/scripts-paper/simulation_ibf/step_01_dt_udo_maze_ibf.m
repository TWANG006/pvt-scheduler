clear;
% close all;
clc;
addpath('../../../functions/');
addpath('../../../../Slope-based-dwell-time/matlab/functions/'); % import rms_std

%% load data
surfDir = '../../../data/paper_data/';
surfFile = 'step_00_rect_map_maze_ibf_tif_5mm.mat';
outDir = '../../../data/paper_data/';

load([surfDir surfFile]);

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
% figure;
ShowSurfaceMap(Xca, Yca, Zresidual_ca, 3, true, 1e9, 'nm', 'Residual surface error');
hold on; plot3(dwell_x * 1e3, dwell_y * 1e3, 100 * ones(size(dwell_x)), 'b-', 'LineWidth', 1); hold off;

%% save data
save([outDir mfilename '.mat'], ...
    'Xca', 'Yca', 'Zca',  ...
    'Zremoval_ca', ...
    'Zresidual_ca',  ...
    'dwell_x', 'dwell_y',  ...
    'path_x', 'path_y',  ...
    't', ...
    'Xtif', 'Ytif', 'Ztif' ...
    );
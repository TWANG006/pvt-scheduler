clear;
close all;
clc;
addpath('../functions/');

%% input parameters

n_inter = 5; % number of interpolations. (n_inter = 2, if the path is not to be denser)

%% load data
data_dir = '../../data/sim_data/';
data_file = 'step_00_rect_map_test1_rect_60mm_tif_2mm.mat';
load([data_dir data_file]);

Xtif = Xtif1;
Ytif = Ytif1;
Ztif = Ztif1;

% parameter of kinematics
ax_max = 2; % Maximum acceleration in the x-direction
vx_max = 250e-3; % Maximum velocity in the x-direction
ay_max = 1;
vy_max = 9e-3;

% parameter of dwell time
precision = 1e-3;
precision_unit = 'nm';
tif1Params.tif_mpp = median(diff(Xtif(1, :)));
%% Interpolate path points & dwell points
figure;
subplot(1,2,1)
plot(px, py, 'bo-'); 
hold on
plot(xp, yp, 'r*'); 
hold off;
axis equal;
legend('path points','dwell points');

i_num = size(px,2);
xp1 = [];% dwell points
yp1 = [];
px1 = [];% path points
py1 = [];

for i = 2 : i_num
    px02px1 = linspace(px(i-1), px(i), n_inter);
    py02py1 = linspace(py(i-1), py(i), n_inter);
    px1 = [px1, px02px1(1:end-1)]; 
    py1 = [py1, py02py1(1:end-1)];
end

for i = 1: size(px1,2) - 1
    if py1(i) == py1(i+1)
        xp1(i) = (px1(i) + px1(i+1))/2; 
        yp1(i) = py1(i);
    end
    if px1(i) == px1(i+1)
        xp1(i) = px1(i);
        yp1(i) = (py1(i) + py1(i+1))/2;
    end   
end

px = px1;
py = py1;
xp = xp1;
yp = yp1;

subplot(1,2,2)
plot(px, py, 'bo-'); 
hold on
plot(xp, yp, 'r*'); 
hold off;
axis equal;
legend('path points','dwell points');

%%
delta_p = xp(2) - xp(1);
min_t = 2 * delta_p / min(vx_max, vy_max); % 10e-2;
%% dwell time
[t, Zremoval_ca, Zresidual_ca] = dwell_time_2d_rect_udo_rise(...
    Xca, ...
    Yca, ...
    Zca,...
    xp, ...
    yp, ...
    tif1Params, ...
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
ShowSurfaceMap(X, Y, Z, 3, true, 1e9, 'nm', 'initial surface error');
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
hold on; plot3(xp*1e3, yp*1e3, 100*ones(size(xp,2),1), 'b-', 'LineWidth', 1); hold off;

%% save data
save([data_dir mfilename '.mat'], ...
    'X', 'Y', 'Z', ...
    'Xca', 'Yca', 'Zca',  ...
    'Zremoval_ca', ...
    'Zresidual_ca',  ...
    'xp',  ...
    'yp',  ...
    't', ...
    'px', ...
    'py', ...
    'Xtif', 'Ytif', 'Ztif', ...
    'ax_max', 'ay_max', 'vx_max', 'vy_max', ...
    'n_inter' ...
    );
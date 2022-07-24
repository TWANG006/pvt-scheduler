clear;
close all;
clc;
addpath(genpath('../functions'));
addpath('../../../Slope-based-dwell-time/matlab/functions/'); % import viridis
addpath(genpath('../../data/'));
%% l. load data
% calculated pvt
load('step_02_pvt_model_calculation.mat');
pvt_t = t;

% tif & surface
load('step_01_multilayer_no1_data.mat');
X = Xca;
Y = Yca;
Z = Z_to_remove_ca;

% visual verification of the initial conditions
fsfig('Before simulation');
subplot(3, 3, 4);
show_surface_map(Xtif, Ytif, Ztif, 0, 'jet', 'flat', false, 2, 1e9, 'nm', 'TIF');
subplot(3, 3, 2);
show_surface_map(X, Y, Z, 10, 'jet', 'flat', true, 2, 1e9, 'nm', 'Desired removal');
subplot(3, 3, 8);
show_surface_map(X, Y, Z_residual_ca, 0.5, 'jet', 'flat', true, 2, 1e9, 'nm', 'Estimated residual');
subplot(3, 3, 3);
show_pvt_t(x, y, dt, 'jet'); 
subplot(3, 3, 9);
show_pvt_v(p, y, v, 'jet'); 



%% 2. calculate the dt
% c = pvt_coefficients(p, v, pvt_t);

% % calculated 
% dx = 1e-6;  % delta x = 1 um
% v0 = 0e-3;  % assume v0 = 0
% a_max = 2000e-3;  % using the max acceleration
% tau = generate_dt(dx, v0, a_max);

% direct assignment
tau = 1/60;  % 10 ms

[p, v, a] = pvt_sampler_raster_path(...
    tau, ... the time interval for the sampling of caculated PVT
    p, ... positions
    pvt_t, ... times
    c  ... coefficients
);

figure;
show_pvt_v(p, y, v, cividis);

% return;


%% 3. begin simulation
[Zresidual, Zremoval] = feedrate_simulator_raster_path(...
    X, Y, Z, ...
    Xtif, Ytif, Ztif, ...
    p, y, v ...
);


%% 4. Show the result
figure;
subplot(3, 1, 1);
show_surface_map(X, Y, Z, 0, viridis, 'flat', false, 2, 1e9, 'nm', 'Desired');
subplot(3, 1, 2);
show_surface_map(X, Y, Zremoval, 0, viridis, 'flat', false, 2, 1e9, 'nm', 'Removed');
subplot(3, 1, 3);
% figure;
show_surface_map(X, Y, Zresidual, 1, viridis, 'flat', true, 2, 1e9, 'nm', 'Residual');


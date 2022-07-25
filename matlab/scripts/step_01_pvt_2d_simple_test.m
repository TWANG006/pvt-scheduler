clear;
% close all;
clc;
addpath(genpath('../functions'));
data_dir = '../../data/sim_data/';

%% generate a very simple 5-point 2d path
px = [1e-3, 2e-3, 3.5e-3, 5e-3, 1e-3];
py = [1e-3, 2e-3, 2.5e-3, 1.8e-3, 1e-3];
t = [0, 0.1, 0.12, 0.23, 0.3] * 10;


%% parameters
ax_max = 2;
vx_max = 250e-3;

ay_max = 1;
vy_max = 150e-3;

tau = 1/60;


%% calculate pvt for x and y seperately
[vx, ax, cx] = pvt_scheduler(px, t, ax_max, vx_max, true);
[vy, ay, cy] = pvt_scheduler(py, t, ay_max, vy_max, true);


%% simulation
px_s = [];
ax_s = [];
vx_s = [];

py_s = [];
ay_s = [];
vy_s = [];

for n = 1: length(t) - 1
    % 1. generate t's for each segment
    if n == 1
        t0 = t(n);
    else
        t0 = t(n) + tau;
    end
    t1 = t(n + 1);
    t02t1 = linspace(t0, t1, ceil((t1 - t0) / tau));
    
    px_s = [px_s; calculate_pvt_p(t02t1, cx(n, :))];
    vx_s = [vx_s; calculate_pvt_v(t02t1, cx(n, :))];
    ax_s = [ax_s; calculate_pvt_a(t02t1, cx(n, :))];
    
    py_s = [py_s; calculate_pvt_p(t02t1, cy(n, :))];
    vy_s = [vy_s; calculate_pvt_v(t02t1, cy(n, :))];
    ay_s = [ay_s; calculate_pvt_a(t02t1, cy(n, :))];
end


%% plot
figure;
subplot(1, 4, 1);
plot(px(1: end-1), py(1: end-1), 'o', 'MarkerSize', 10, 'MarkerFaceColor', 'r'); hold on;
xlim([0 6e-3]);
ylim([0 4e-3]);
plot(px_s, py_s, 'b-', 'LineWidth', 2); hold off;
title('Trajectory');
axis square;

subplot(1, 4, 2);
plot(px_s + py_s, 'LineWidth', 2);
title('Positions');
axis square;

subplot(1, 4, 3);
plot(vx_s + vy_s, 'LineWidth', 2);
title('Velicities');
axis square;

subplot(1, 4, 4);
plot(ax_s + ay_s, 'LineWidth', 2);
title('Accelerations');
axis square;


%%
h5create([data_dir mfilename '.h5'], '/px', size(px));
h5write([data_dir mfilename '.h5'], '/px', px);
h5create([data_dir mfilename '.h5'], '/py', size(py));
h5write([data_dir mfilename '.h5'], '/py', py);
h5create([data_dir mfilename '.h5'], '/vx', size(vx'));
h5write([data_dir mfilename '.h5'], '/vx', vx');
h5create([data_dir mfilename '.h5'], '/vy', size(vy'));
h5write([data_dir mfilename '.h5'], '/vy', vy');
h5create([data_dir mfilename '.h5'], '/dpx', size(px));
h5write([data_dir mfilename '.h5'], '/dpx', px);
h5create([data_dir mfilename '.h5'], '/dpy', size(py));
h5write([data_dir mfilename '.h5'], '/dpy', py);
h5create([data_dir mfilename '.h5'], '/dt', size(t));
h5write([data_dir mfilename '.h5'], '/dt', t);

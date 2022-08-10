% The simulation results differ from step_02_const_a_2d_from_udo.m,
% because the dwell time interval is slightly different.

clear;
% close all;
clc;
addpath(genpath('../../functions'));

%% generate a very simple 5-point 2d path
data_dir = '../../../data/sim_data/';
data_file = 'step_01_dt_udo.mat';
load([data_dir data_file]);

% cs_t = cumsum([0; t(:)]);
t = t';
cs_t = cumsum([0, t]);
%% parameters
% ax_max = 2; % Maximum acceleration in the x-direction
% vx_max = 250e-3; % Maximum velocity in the x-direction
% 
% ay_max = 1;
% vy_max = 3e-3; % 9e-3

tau = 1/20;

%% calculate pvt for x and y seperately
vx = velocities_with_const_acc_scheduler(px, t, vx_max, ax_max);
vy = velocities_with_const_acc_scheduler(py, t, vy_max, ay_max);

% calculated positions
% sx = velocities_with_const_acc_calculate_s(vx, t, ax_max);
% sy = velocities_with_const_acc_calculate_s(vy, t, ay_max);
[sx, sx_a, sx_c, tx_a, tx_c, ax] = velocities_with_const_acc_calculate_s_t(vx, t, ax_max);
[sy, sy_a, sy_c, ty_a, ty_c, ay] = velocities_with_const_acc_calculate_s_t(vy, t, ay_max);

%% simulation
px_s = px(1);
vx_s = vx(1);
ax_s = 0;% ax(1);

py_s = py(1);
vy_s = vy(1);
ay_s = 0;% ay(1);

for n = 1: length(t)
    % 1. generate t's for each segment
    t0 = cs_t(n);
    t1 = cs_t(n + 1);
    t02t1 = linspace(t0, t1, ceil((t1 - t0) / tau));
    
    % x-axis sampling
    [px_t02t1, vx_t02t1, ax_t02t1] = calculate_const_acc_pva(...
        t02t1,   ... t02t1
        px(n), ... 
        sx_a(n),   ... s1
        tx_a(n),   ... t1
        ax(n), ... acc
        vx(n), ... v_(k-1)
        vx(n+1) ... v_k
        );
%     if n < length(t)
%         ax_t02t1(end) = ax(n+1); % ax_t02t1(end) is the start of the next part.
%     end
    px_s = [px_s, px_t02t1];
    vx_s = [vx_s, vx_t02t1];
    ax_s = [ax_s, ax_t02t1];
    
    % y-axis sampling
    [py_t02t1, vy_t02t1, ay_t02t1] = calculate_const_acc_pva(...
        t02t1,   ... t02t1
        py(n), ...
        sy_a(n),   ... s1
        ty_a(n),   ... t1
        ay(n), ... acc
        vy(n), ... v_(k-1)
        vy(n+1) ... v_k
        );
%     if n < length(t)
%         ay_t02t1(end) = ay(n+1); % ay_t02t1(end) is the start of the next part.
%     end
    py_s = [py_s, py_t02t1];
    vy_s = [vy_s, vy_t02t1];
    ay_s = [ay_s, ay_t02t1];
    
end

%% plot
figure;
subplot(2, 4, 1);
plot(px(1: end-1), py(1: end-1), 'o', 'MarkerSize', 10, 'MarkerFaceColor', 'r'); hold on;
% xlim([0 6e-3]);
% ylim([0 4e-3]);
plot(px_s, py_s, 'b-', 'LineWidth', 2); hold off;
title('Trajectory');
axis square;

subplot(2, 4, 2);
plot(px_s, 'LineWidth', 2);
title('Positions x');
axis square;

subplot(2, 4, 3);
plot(vx_s, 'LineWidth', 2);
hold on;
plot(ones(size(vx_s)) * vx_max, 'r-', 'LineWidth', 2);
plot(-ones(size(vx_s)) * vx_max,'r-', 'LineWidth', 2); hold off;
title('Velicities x');
axis square;

subplot(2, 4, 4);
plot(ax_s, 'LineWidth', 2);
hold on;
plot(ones(size(ax_s)) * ax_max, 'r-', 'LineWidth', 2); hold on;
plot(-ones(size(ax_s)) * ax_max,'r-', 'LineWidth', 2); hold off;
title('Accelerations x');
axis square;

subplot(2, 4, 6);
plot(py_s, 'LineWidth', 2);
title('Positions y');
axis square;

subplot(2, 4, 7);
plot(vy_s, 'LineWidth', 2);
hold on;
plot(ones(size(vy_s)) * vy_max, 'r-', 'LineWidth', 2);
plot(-ones(size(vy_s)) * vy_max,'r-', 'LineWidth', 2); hold off;
title('Velicities y');
axis square;

subplot(2, 4, 8);
plot(ay_s, 'LineWidth', 2);
hold on;
plot(ones(size(ay_s)) * ay_max, 'r-', 'LineWidth', 2); hold on;
plot(-ones(size(ay_s)) * ay_max,'r-', 'LineWidth', 2); hold off;
title('Accelerations y');
axis square;

%% residual error
F = griddedInterpolant(...
    Xtif', ...
    (-Ytif)', ...
    flipud(Ztif)', ...
    'cubic', ...
    'none' ...
);

Zremoval_ca = 0 * Zca;

delta_s = 0 * ones(size(px_s));
delta_v = 0 * ones(size(px_s));
delta_t = 0 * ones(size(px_s));

for i = 1: size(px_s)-1
    delta_s(i) = sqrt((px_s(i + 1) - px_s(i))^2 + (py_s(i + 1) - py_s(i))^2);
    delta_v(i) = sqrt((0.5 * (vx_s(i) + vx_s(i + 1)))^2 + (0.5 * (vy_s(i) + vy_s(i + 1)))^2);
    delta_t(i) = delta_s(i) / delta_v(i);
    
    [Zn, xdg, ydg] = feedrate_simulator_per_segment(...
            Xca, ...
            Yca, ...
            px_s(i), px_s(i + 1), ...
            py_s(i), py_s(i + 1), ...
            vx_s(i), vx_s(i + 1), ...
            vy_s(i), vy_s(i + 1), ...
            delta_t(i), ...
            F ...
        );
    Zremoval_ca = Zremoval_ca + Zn;
    Zresidual_ca = Zca - Zremoval_ca;
    Zresidual_ca = remove_polynomials(Xca, Yca, Zresidual_ca, 1);
    
end

%% display
fsfig('const_acceleration model');
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
figure;
ShowSurfaceMap(Xca, Yca, Zresidual_ca, 3, true, 1e9, 'nm', 'Residual surface error'); 
hold on; plot3(px_s*1e3, py_s*1e3, 100*ones(size(px_s)), 'b-', 'LineWidth', 1); hold off;


%% save data
save([data_dir mfilename '.mat'], ...
    'X', 'Y', 'Z', ...
    'Xca', 'Yca', 'Zca',  ...
    'Zremoval_ca', 'Zresidual_ca',  ...
    'xp', 'yp', 't', 'px', 'py',...
    'cs_t', ...
    'Xtif', 'Ytif', 'Ztif',...
    'px_s', 'py_s', ...
    'vx_s', 'vy_s', ...
    'ax_s', 'ay_s' ...
    );


%% write to hdf5
h5create([data_dir mfilename '.h5'], '/X', size(Xca'));
h5write([data_dir mfilename '.h5'], '/X', Xca');
h5create([data_dir mfilename '.h5'], '/Y', size(Yca'));
h5write([data_dir mfilename '.h5'], '/Y', Yca');
h5create([data_dir mfilename '.h5'], '/Z', size(Zca'));
h5write([data_dir mfilename '.h5'], '/Z', Zca');

h5create([data_dir mfilename '.h5'], '/Xtif', size(Xtif'));
h5write([data_dir mfilename '.h5'], '/Xtif', Xtif');
h5create([data_dir mfilename '.h5'], '/Ytif', size(Ytif'));
h5write([data_dir mfilename '.h5'], '/Ytif', Ytif');
h5create([data_dir mfilename '.h5'], '/Ztif', size(Ztif'));
h5write([data_dir mfilename '.h5'], '/Ztif', Ztif');

h5create([data_dir mfilename '.h5'], '/px', size(px));
h5write([data_dir mfilename '.h5'], '/px', px);
h5create([data_dir mfilename '.h5'], '/py', size(py));
h5write([data_dir mfilename '.h5'], '/py', py);
h5create([data_dir mfilename '.h5'], '/vx', size(vx'));
h5write([data_dir mfilename '.h5'], '/vx', vx');
h5create([data_dir mfilename '.h5'], '/vy', size(vy'));
h5write([data_dir mfilename '.h5'], '/vy', vy');
h5create([data_dir mfilename '.h5'], '/dpx', size(xp));
h5write([data_dir mfilename '.h5'], '/dpx', xp);
h5create([data_dir mfilename '.h5'], '/dpy', size(yp));
h5write([data_dir mfilename '.h5'], '/dpy', yp);
h5create([data_dir mfilename '.h5'], '/dt', size(t'));
h5write([data_dir mfilename '.h5'], '/dt', t');
h5create([data_dir mfilename '.h5'], '/t', size(cs_t'));
h5write([data_dir mfilename '.h5'], '/t', cs_t');
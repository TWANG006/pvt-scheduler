clear;
% close all;
clc;
addpath('../../../matlab/functions/');

%% generate a very simple 5-point 2d path
data_dir = '../../../data/paper_data/';
data_file = 'step_01_dt_udo_paper.mat';
load([data_dir data_file]);

% cs_t = cumsum([0; t(:)]);
t = t';
cs_t = cumsum([0, t]);

xp = dwell_x;
yp = dwell_y;
px = path_x;
py = path_y;

%  % row 12 (central axis, backward)
% xp = dwell_x(254 : 275);
% yp = dwell_y(254 : 275);
% px = path_x(254 : 276);
% py = path_y(254 : 276);
% cs_t = cs_t(254 : 276);
% t = t(254 : 275);

% % row 13 (forward)
% xp = dwell_x(277 : 298);
% yp = dwell_y(277 : 298);
% px = path_x(277 : 299);
% py = path_y(277 : 299);
% cs_t = cs_t(277 : 299);
% t = t(277 : 298);
%% parameters
% ax_max = 2; % Maximum acceleration in the x-direction
% vx_max = 250e-3; % Maximum velocity in the x-direction
% 
% ay_max = 1;
% vy_max = 3e-3; % 9e-3

tau = 1/50;

%% calculate pvt for x and y seperately
% calculate the actual t
[~, tx] = velocities_with_const_acc_scheduler(px, t, vx_max, ax_max);
[~, ty] = velocities_with_const_acc_scheduler(py, t, vy_max, ay_max);
t = max(tx, ty);

% calculate vx & vy using the actual t
[vx, ~] = velocities_with_const_acc_scheduler(px, t, vx_max, ax_max);
[vy, ~] = velocities_with_const_acc_scheduler(py, t, vy_max, ay_max);

% calculated positions
[sx, sxa, ~] = velocities_with_const_acc_calculate_s(vx, t, ax_max);
[sy, sya, ~] = velocities_with_const_acc_calculate_s(vy, t, ay_max);

px_calc = cumsum([px(1) sx]);
py_calc = cumsum([py(1) sy]);

figure;
plot(px(1: end), py(1: end), 'o', 'MarkerSize', 10, 'MarkerFaceColor', 'r'); hold on;
plot(px_calc, py_calc, 'b-', 'LineWidth', 2); hold off;

%% simulation
[px_s, vx_s, tx_s, ax_s] = velocities_with_const_acc_sampler(px, vx, cs_t, ax_max, tau);
[py_s, vy_s, ty_s, ay_s] = velocities_with_const_acc_sampler(py, vy, cs_t, ay_max, tau);

%% plot
figure;
subplot(2, 4, 1);
plot(px(1: end), py(1: end), 'o', 'MarkerSize', 10, 'MarkerFaceColor', 'r'); hold on;
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
% hold on;
% plot(ones(size(vx_s)) * vx_max, 'r-', 'LineWidth', 2); hold on;
% plot(-ones(size(vx_s)) * vx_max,'r-', 'LineWidth', 2); hold off;
title('Velicities x');
axis square;

subplot(2, 4, 4);
plot(ax_s, 'LineWidth', 2); 
% hold on;
% plot(ones(size(ax_s)) * ax_max, 'r-', 'LineWidth', 2); hold on;
% plot(-ones(size(ax_s)) * ax_max,'r-', 'LineWidth', 2); hold off;
title('Accelerations x');
axis square;

subplot(2, 4, 6);
plot(py_s, 'LineWidth', 2);
title('Positions y');
axis square;

subplot(2, 4, 7);
plot(vy_s, 'LineWidth', 2); 
% hold on;
% plot(ones(size(vy_s)) * vy_max, 'r-', 'LineWidth', 2); hold on;
% plot(-ones(size(vy_s)) * vy_max,'r-', 'LineWidth', 2); hold off;
title('Velicities y');
axis square;

subplot(2, 4, 8);
plot(ay_s, 'LineWidth', 2); 
% hold on;
% plot(ones(size(ay_s)) * ay_max, 'r-', 'LineWidth', 2); hold on;
% plot(-ones(size(ay_s)) * ay_max,'r-', 'LineWidth', 2); hold off;
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
% subplot(245);
% ShowDwellTime(xp, yp, t, false, 0, 'jet', 'Dwell Time');  
subplot(246);
ShowSurfaceMap(Xca, Yca, Zca, 3, true, 1e9, 'nm', 'Clear Aperture');
subplot(247);
ShowSurfaceMap(Xca, Yca, Zremoval_ca, 3, true, 1e9, 'nm', 'Removed surface error');
subplot(248);
ShowSurfaceMap(Xca, Yca, Zresidual_ca, 3, true, 1e9, 'nm', 'Residual surface error'); 
hold on; plot3(px_s*1e3, py_s*1e3, 100*ones(size(px_s)), 'b-', 'LineWidth', 1); hold off;

figure;
ShowSurfaceMap(Xca, Yca, Zresidual_ca, 3, true, 1e9, 'nm', ''); 
c = colorbar;
set(c, 'YTick', []);
set(gca,'xcolor', 'none');
set(gca,'ycolor', 'none');
set(gcf,'position',[600,300,400,250]);
hold on; plot3(px_s*1e3, py_s*1e3, 100*ones(size(px_s)), 'color', '[0 0.690 0.941]', 'linestyle', '-', 'LineWidth', 1); hold off;

%% save data
dtx_s = [0; diff(tx_s)];
dty_s = [0; diff(ty_s)];
save([data_dir mfilename '.mat'], ...
    'px_s', 'py_s', ...
    'vx_s', 'vy_s', ...
    'dtx_s', 'dty_s', ...
    'ax_s', 'ay_s', ...
    'px', 'vx', 't' ...
    );


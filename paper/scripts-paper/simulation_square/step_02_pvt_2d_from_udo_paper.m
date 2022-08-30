clear;
% close all;
clc;
addpath('../../../matlab/functions/');

%% generate a very simple 5-point 2d path
data_dir = '../../../data/paper_data/';
data_file = 'step_01_dt_udo_paper.mat';
load([data_dir data_file]);

cs_t = cumsum([0;t(:)]);

xp = dwell_x;
yp = dwell_y;
px = path_x;
py = path_y;

% % row 12 (central axis, backward)
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
[vx, ax, cx] = pvt_scheduler(px, cs_t, ax_max, vx_max, false);
[vy, ay, cy] = pvt_scheduler(py, cs_t, ay_max, vy_max, false);

% %%
% pxx = zeros(size(px,1), size(px,2)) * NaN;
% pyy = zeros(size(py,1), size(py,2)) * NaN;
% vxx = zeros(size(vx,1), size(vx,2)) * NaN;
% vyy = zeros(size(vy,1), size(vy,2)) * NaN;
% for i= 1: length(px) - 1
% pxx(i) = calculate_pvt_p(cs_t(i), cx(i, :));
% pyy(i) = calculate_pvt_p(cs_t(i), cy(i, :));
% vxx(i) = calculate_pvt_v(cs_t(i), cx(i, :));
% vyy(i) = calculate_pvt_v(cs_t(i), cy(i, :));
% end
% max(vxx)
% max(vyy)
% figure;
% plot(px, py, 'o'); hold on;
% plot(pxx, pyy, '-'); hold off;
% % return;

%% simulation
px_s = [];
ax_s = [];
vx_s = [];

py_s = [];
ay_s = [];
vy_s = [];
t_s = [];
for n = 1: length(cs_t) - 1
    % 1. generate t's for each segment
    if n == 1
        t0 = cs_t(n);
    else
        t0 = cs_t(n) + tau;
    end
    t1 = cs_t(n + 1);
    t02t1 = linspace(t0, t1, ceil((t1 - t0) / tau));
    t_s = [t_s; t02t1(:)];
    px_s = [px_s; calculate_pvt_p(t02t1, cx(n, :))];
    vx_s = [vx_s; calculate_pvt_v(t02t1, cx(n, :))];
    ax_s = [ax_s; calculate_pvt_a(t02t1, cx(n, :))];
    
    py_s = [py_s; calculate_pvt_p(t02t1, cy(n, :))];
    vy_s = [vy_s; calculate_pvt_v(t02t1, cy(n, :))];
    ay_s = [ay_s; calculate_pvt_a(t02t1, cy(n, :))];
end

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
title('Velicities x');
axis square;

subplot(2, 4, 4);
plot(ax_s, 'LineWidth', 2);
title('Accelerations x');
axis square;

subplot(2, 4, 6);
plot(py_s, 'LineWidth', 2);
title('Positions y');
axis square;

subplot(2, 4, 7);
plot(vy_s, 'LineWidth', 2);
title('Velicities y');
axis square;

subplot(2, 4, 8);
plot(ay_s, 'LineWidth', 2);
title('Accelerations y');
axis square;

%% residual error
% % compare dwell time in x- and y- direction
% for i = 1: size(px_s)-1
%     tx(i) = abs(px_s(i+1) - px_s(i)) / (0.5 * abs(vx_s(i+1) + vx_s(i)));
%     ty(i) = abs(py_s(i+1) - py_s(i)) / (0.5 * abs(vy_s(i+1) + vy_s(i)));
%     delta_t(i) = tx(i) - ty(i);
% end
% total_tx = sum(tx);
% total_ty = sum(ty);
% % return

F = griddedInterpolant(...
    Xtif', ...
    (-Ytif)', ...
    flipud(Ztif)', ...
    'cubic', ...
    'none' ...
);

Zremoval_ca = 0 * Zca;

for i = 1: size(px_s)-1
    [Zn, xdg, ydg] = feedrate_simulator_per_segment(...
            Xca, ...
            Yca, ...
            px_s(i), px_s(i + 1), ...
            py_s(i), py_s(i + 1), ...
            vx_s(i), vx_s(i + 1), ...
            vy_s(i), vy_s(i + 1), ...
            t_s(i + 1) - t_s(i), ...
            F ...
        );
    Zremoval_ca = Zremoval_ca + Zn;
    Zresidual_ca = Zca - Zremoval_ca;
    Zresidual_ca = remove_polynomials(Xca, Yca, Zresidual_ca, 1);
    
end

%% display
fsfig('pvt model');
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
hold on; plot3(px_s*1e3, py_s*1e3, 100*ones(size(px_s,1),1), 'b-', 'LineWidth', 1); hold off;

figure;
ShowSurfaceMap(Xca, Yca, Zresidual_ca, 3, true, 1e9, 'nm', ''); 
c = colorbar;
set(c, 'YTick', []);
set(gca,'xcolor', 'none');
set(gca,'ycolor', 'none');
set(gcf,'position',[600,300,400,250]);
hold on; plot3(px_s*1e3, py_s*1e3, 100*ones(size(px_s,1),1), 'color', '[1 0.6 0.4]', 'linestyle', '-', 'LineWidth', 1); hold off;

%% save data
dt_s = [0; diff(t_s)];
save([data_dir mfilename '.mat'], ...
    'px_s', 'py_s', ...
    'vx_s', 'vy_s', ...
    'dt_s',  ...
    'ax_s', 'ay_s', ...
    'px', 'vx', 't' ...
    );

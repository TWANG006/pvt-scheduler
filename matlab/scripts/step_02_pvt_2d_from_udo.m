clear;
% close all;
clc;
addpath(genpath('../functions'));

%% generate a very simple 5-point 2d path
data_dir = '../../data/sim_data/';
data_file = 'step_01_dt_udo.mat';
load([data_dir data_file]);

cs_t = cumsum([0;t(:)]);

%% parameters
ax_max = 2; % Maximum acceleration in the x-direction
vx_max = 250e-3; % Maximum velocity in the x-direction

ay_max = 1;
vy_max = 150e-3;

tau = 1/20;

%% calculate pvt for x and y seperately
[vx, ax, cx] = pvt_scheduler(px, cs_t, ax_max, vx_max, false);
[vy, ay, cy] = pvt_scheduler(py, cs_t, ay_max, vy_max, false);

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
    [Zn, xdg, ydg] = feedrate_simulator_maze_path_per_segment(...
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
subplot(245);
ShowDwellTime(xp, yp, t, false, 0, 'jet', 'Dwell Time');  
subplot(246);
ShowSurfaceMap(Xca, Yca, Zca, 3, true, 1e9, 'nm', 'Clear Aperture');
subplot(247);
ShowSurfaceMap(Xca, Yca, Zremoval_ca, 3, true, 1e9, 'nm', 'Removed surface error');
subplot(248);
ShowSurfaceMap(Xca, Yca, Zresidual_ca, 3, true, 1e9, 'nm', 'Residual surface error'); 
hold on; plot3(px_s*1e3, py_s*1e3, 100*ones(size(px_s,1),1), 'b-', 'LineWidth', 1); hold off;

%% save data
save([data_dir mfilename '.mat'], ...
    'X', 'Y', 'Z', ...
    'Xca', 'Yca', 'Zca',  ...
    'Zremoval_ca', 'Zresidual_ca',  ...
    'xp', 'yp', 't', 'px', 'py', 'cx', 'cy',...
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

h5create([data_dir mfilename '.h5'], '/Cx', size(cx'));
h5write([data_dir mfilename '.h5'], '/Cx', cx');
h5create([data_dir mfilename '.h5'], '/Cy', size(cy'));
h5write([data_dir mfilename '.h5'], '/Cy', cy');
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
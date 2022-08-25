clear;
% close all;
clc;
addpath(genpath('../functions'));
outDir = '../../../data/paper_data/';
%% generate a very simple 4-point 1d path
px = [0, 1667, 18333, 20000]; % [pulse]
vx = [0, 6.667, 6.667, 0]; % [mm/s]
t = [0, 750, 2250, 3500]; % [ms]

%% parameters
ax_max = 0.02;
vx_max = 20;

tau = 2;


% calculate coefficients
for n = 1: size(px, 2) - 1
    cx(n, :) = pvt_coefficients(...
        px(n), px(n + 1), ...
        vx(n), vx(n + 1), ...
        t(n), t(n + 1) ...
    );    
end


%% simulation
px_s = [];
ax_s = [];
vx_s = [];

t_s = [];
pa = [];

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
    
    t_s = [t_s; t02t1'];
    pa = [pa, ax_s(end)];
end

pa = [ax_s(1), pa];

%% plot - axis x: time
% figure;
figure('Position', [100, 300, 400, 460]);
subplot(3, 1, 1);
plot(t_s, px_s, 'b', 'linestyle', '-', 'LineWidth', 2); hold on;
plot(t, px, 'ro', 'MarkerSize', 5, 'MarkerFaceColor', 'r'); hold on;
plot(t_s, ones(size(px_s)) * px(end), 'r:', 'LineWidth', 1); hold off;
% title('Position');
ylim([-1000 25000]);
set(gca,'xtick', []); set(gca,'ytick', []);

subplot(3, 1, 2);
plot(t_s, vx_s, 'color', [0.929, 0.694, 0.125], 'LineWidth', 2); hold on;
plot(t, vx, 'ro', 'MarkerSize', 5, 'MarkerFaceColor', 'r'); hold on;
plot(t_s, ones(size(vx_s)) * vx_max, 'r--', 'LineWidth', 1); hold on;
plot(t_s, ones(size(vx_s)) * 0, 'r:', 'LineWidth', 1); hold on;
plot(t_s, -ones(size(vx_s)) * vx_max, 'r--', 'LineWidth', 1); hold off;
% title('Velicities');
ylim([-23 23]);
set(gca,'xtick', []); set(gca,'ytick', []);

subplot(3, 1, 3);
plot(t_s, ax_s, 'm', 'LineWidth', 2); hold on;
plot(t, pa, 'ro', 'MarkerSize', 5, 'MarkerFaceColor', 'r'); hold on;
plot(t_s, ones(size(ax_s)) * ax_max, 'r--', 'LineWidth', 1); hold on;
plot(t_s, -ones(size(ax_s)) * ax_max, 'r--', 'LineWidth', 1); hold off;
% title('Accelerations');
ylim([-0.025 0.025]);
set(gca,'xtick', []); set(gca,'ytick', []);

return;
%% Save the cleaned data
outFile = [outDir mfilename '.mat'];

save(outFile, ...
    't', 'px', ...
    't_s', 'px_s', 'vx_s', 'ax_s', ...
    'vx_max', 'ax_max' ...
);



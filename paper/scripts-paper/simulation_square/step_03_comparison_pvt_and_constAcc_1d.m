clear;
close all;
clc;

%% 
data_dir = '../../../data/paper_data/';
data_file = 'step_02_const_a_2d_from_udo_paper.mat';
load([data_dir data_file]);
const_px_s = px_s;
const_py_s = py_s;
const_vx_s = vx_s;
const_vy_s = vy_s;
const_ax_s = ax_s;
const_ay_s = ay_s;
const_dtx_s = dtx_s;
const_dty_s = dty_s;
const_px = px(1:end-1);
const_vx = vx(1:end-1);
const_t = t;

data_file = 'step_02_pvt_2d_from_udo_paper.mat';
load([data_dir data_file]);
pvt_px_s = px_s;
pvt_py_s = py_s;
pvt_vx_s = vx_s;
pvt_vy_s = vy_s;
pvt_ax_s = ax_s;
pvt_ay_s = ay_s;
pvt_dt_s = dt_s;
pvt_px = px(1:end-1);
pvt_vx = vx(1:end-1);
pvt_t = t;

%% plot 
figure;
subplot(2, 2, 1);
yyaxis left;
plot(const_px, const_t, 'o-', 'color',[0 0.4470 0.7410], 'LineWidth', 1); 
ylabel('[s]');

yyaxis right;
plot(const_px, const_vx, 'ro-', 'LineWidth', 1); 
ylabel('[mm/s]');
title('Dwell time vs. Feedrates : const-acc');
set(0,'defaultfigurecolor','w')

subplot(2, 2, 2);
yyaxis left;
plot(pvt_px, pvt_t, 'o-', 'color',[0 0.4470 0.7410], 'LineWidth', 1); 
ylabel('[s]');

yyaxis right;
plot(pvt_px, pvt_vx, 'ro-', 'LineWidth', 1); 
ylabel('[mm/s]');
title('Dwell time vs. Feedrates : const-acc');

subplot(2, 2, 3);
plot(const_px_s(2:end), const_ax_s(2:end), 'b*-', 'LineWidth', 1); 
% ylim([-0.2 0.25]);
title('Accelerations x : const-acc');

subplot(2, 2, 4);
plot(pvt_px_s, pvt_ax_s, 'r*-', 'LineWidth', 1); 
% ylim([-0.2 0.25]);
title('Accelerations x : pvt');

%% plot (p,v,t)
figure;
subplot(3, 1, 1);
plot(const_px, const_t, 'bo-', 'LineWidth', 1); 
% ylim([-10e-3 10e-3]);
hold on;
plot(const_px, const_vx, 'ro-', 'LineWidth', 1); 
hold off;
legend('const-acc','pvt') 
title('dwell time x');
% axis square;
set(0,'defaultfigurecolor','w')

subplot(3, 1, 2);
plot(const_px_s, const_vx_s, 'bo-', 'LineWidth', 1); 
% ylim([-10e-3 10e-3]);
hold on;
plot(pvt_px_s, pvt_vx_s, 'ro-', 'LineWidth', 1); 
hold off;
legend('const-acc','pvt') 
title('Velicities x');

subplot(3, 1, 3);
plot(const_px_s(2:end), const_ax_s(2:end), 'b*-', 'LineWidth', 1); 
hold on;
plot(pvt_px_s, pvt_ax_s, 'r*-', 'LineWidth', 1); 
hold off;
% ylim([-0.2 0.25]);
legend('const-acc','pvt') 
title('Accelerations x');

%% plot: Dwell time vs. Feedrates  - no scale
figure;
set(gcf,'position',[600,300,500,170]);
yyaxis left;
plot(const_px, const_t, 'o-', 'color',[0.466 0.674 0.188], 'LineWidth', 1);
set(gca,'xticklabel',[]);
set(gca,'yticklabel',[]);
% ylabel('[s]');
yyaxis right;
plot(const_px, const_vx, 'o-', 'color', [0.929, 0.694, 0.125], 'LineWidth', 1); 
% ylabel('[mm/s]');
% title('Dwell time vs. Feedrates : const-acc');
set(0,'defaultfigurecolor','w')
set(gca,'yticklabel',[]);

figure;
set(gcf,'position',[600,300,500,170]);
yyaxis left;
plot(pvt_px, pvt_t, 'o-', 'color',[0.466 0.674 0.188], 'LineWidth', 1); 
set(gca,'xticklabel',[]);
set(gca,'yticklabel',[]);
% ylabel('[s]');
yyaxis right;
plot(pvt_px, pvt_vx, 'o-', 'color', [0.929, 0.694, 0.125], 'LineWidth', 1); 
% ylabel('[mm/s]');
% title('Dwell time vs. Feedrates : const-acc');
set(0,'defaultfigurecolor','w')
set(gca,'yticklabel',[]);

%% plot - no scale
figure;
set(gcf,'position',[600,300,440,360]);
plot(const_px_s, const_vx_s, 'bo-', 'LineWidth', 1); 
xlim([-2e-3 2e-3]);
hold on;
plot(pvt_px_s, pvt_vx_s, 'ro-', 'LineWidth', 1); 
hold off;
legend('const-acc','pvt') 
set(gca,'xticklabel',[]);
set(gca,'yticklabel',[]);
% title('Velicities x');

figure;
set(gcf,'position',[600,300,440,170]);
plot(const_px_s(2:end), const_ax_s(2:end), 'b*-', 'LineWidth', 1); 
xlim([-2e-3 2e-3]);
hold on;
plot(pvt_px_s, pvt_ax_s, 'r*-', 'LineWidth', 1); 
hold off;
% legend('const-acc','pvt') 
% title('Accelerations x');
set(gca,'xticklabel',[]);
set(gca,'yticklabel',[]);

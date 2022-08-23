clear;
% close all;
clc;

%% 
data_dir = '../../../data/paper_data/';
data_file = 'step_01_pvt_2d_simple_test_1d.mat';
load([data_dir data_file]);
pvt_px_s = px_s;
pvt_py_s = py_s;
pvt_vx_s = vx_s;
pvt_vy_s = vy_s;
pvt_ax_s = ax_s;
pvt_ay_s = ay_s;

data_file = 'step_02_const_a_2d_simple_test_1d.mat';
load([data_dir data_file]);
const_px_s = px_s;
const_py_s = py_s;
const_vx_s = vx_s;
const_vy_s = vy_s;
const_ax_s = ax_s;
const_ay_s = ay_s;


%% plot
figure;
subplot(1, 2, 1);
plot(pvt_vx_s, 'bo-', 'LineWidth', 1); 
% ylim([-10e-3 10e-3]);
hold on;
plot(const_vx_s, 'ro-', 'LineWidth', 1); 
hold off;
legend('pvt','const-acc') 
title('Velicities x');
axis square;
set(0,'defaultfigurecolor','w')

subplot(1, 2, 2);
plot(pvt_ax_s, 'b*-', 'LineWidth', 1); 
hold on;
plot(const_ax_s, 'r*-', 'LineWidth', 1); 
hold off;
% ylim([-0.2 0.25]);
legend('pvt','const-acc')
title('Accelerations x');

%% plot (p,v)
figure;
subplot(1, 2, 1);
plot(pvt_px_s, pvt_vx_s, 'bo-', 'LineWidth', 1); 
% ylim([-10e-3 10e-3]);
hold on;
plot(const_px_s, const_vx_s, 'ro-', 'LineWidth', 1); 
hold off;
legend('pvt','const-acc') 
title('Velicities x');
axis square;
set(0,'defaultfigurecolor','w')

subplot(1, 2, 2);
plot(pvt_px_s, pvt_ax_s, 'b*-', 'LineWidth', 1); 
hold on;
plot(const_px_s, const_ax_s, 'r*-', 'LineWidth', 1); 
hold off;
% ylim([-0.2 0.25]);
legend('pvt','const-acc')
title('Accelerations x');
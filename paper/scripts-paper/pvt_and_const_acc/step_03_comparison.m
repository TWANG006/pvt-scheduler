clear;
% close all;
clc;

%% 
data_dir = '../../../data/paper_data/';

data_file = 'step_01_pvt_2d_simple_test_1.mat';
load([data_dir data_file]);
pvt_px_s = px_s;
pvt_vx_s = vx_s;
pvt_ax_s = ax_s;
pvt_tx_s = t_s;

data_file = 'step_02_const_a_2d_simple_test_1.mat';
load([data_dir data_file]);
const_px_s = px_s;
const_vx_s = vx_s;
const_ax_s = ax_s;
const_tx_s = tx_s;

%% plot
figure;
subplot(3, 1, 1);
plot(pvt_tx_s, pvt_px_s, 'b-', 'LineWidth', 1); 
% ylim([-10e-3 10e-3]);
hold on;
plot(const_tx_s, const_px_s, 'r-', 'LineWidth', 1); 
hold off;
legend('pvt','const-p') 
title('p x');
% axis square;
set(0,'defaultfigurecolor','w')

subplot(3, 1, 2);
plot(pvt_tx_s, pvt_vx_s, 'b-', 'LineWidth', 1); 
% ylim([-10e-3 10e-3]);
hold on;
plot(const_tx_s, const_vx_s, 'r-', 'LineWidth', 1); 
hold off;
legend('pvt','const-p') 
title('v x');
% axis square;

subplot(3, 1, 3);
plot(pvt_tx_s, pvt_ax_s, 'b-', 'LineWidth', 1); 
% ylim([-10e-3 10e-3]);
hold on;
plot(const_tx_s, const_ax_s, 'r-', 'LineWidth', 1); 
hold off;
legend('pvt','const-p') 
title('acc x');
% axis square;
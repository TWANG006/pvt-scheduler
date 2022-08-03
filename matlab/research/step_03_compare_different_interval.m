clear; clc;
close all;

%% load data.

data_dir = '../../data/sim_data/';
data_file = 'step_02_pvt_2d_from_udo_test_diff_interval_2.mat';
load([data_dir data_file], 'px', 'py','px_s','py_s');

subplot(1,2,1);
plot(px(1: end-1), py(1: end-1), 'o', 'MarkerSize', 10, 'MarkerFaceColor', 'r'); hold on;
% xlim([0 6e-3]);
% ylim([0 4e-3]);
plot(px_s, py_s, 'b-', 'LineWidth', 2); hold off;
title('Trajectory');
axis square;

%%
data_dir = '../../data/sim_data/';
data_file = 'step_02_pvt_2d_from_udo_test_diff_interval_5.mat';
load([data_dir data_file], 'px', 'py','px_s','py_s');

subplot(1,2,2);
plot(px(1: end-1), py(1: end-1), 'o', 'MarkerSize', 10, 'MarkerFaceColor', 'r'); hold on;
% xlim([0 6e-3]);
% ylim([0 4e-3]);
plot(px_s, py_s, 'b-', 'LineWidth', 2); hold off;
title('Trajectory');
axis square;
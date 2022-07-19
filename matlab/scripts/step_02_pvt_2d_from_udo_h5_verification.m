clear;
% close all;
clc;
addpath(genpath('../functions'));

%% generate a very simple 5-point 2d path
data_dir = '../../data/sim_data/';
data_file = 'step_02_pvt_2d_from_udo.h5';

X = h5read([data_dir data_file], '/X');
X = X';
Y = h5read([data_dir data_file], '/Y');
Y = Y';
Z = h5read([data_dir data_file], '/Z');
Z = Z';
Zrem = h5read([data_dir data_file], '/Zrem');
Zrem = Zrem';

figure;
subplot(1, 2, 1);
ShowSurfaceMap(X, Y, Zrem);
subplot(1, 2, 2);
ShowSurfaceMap(X, Y, Z - Zrem, 3, true, 1e9, 'nm', 'Residual');
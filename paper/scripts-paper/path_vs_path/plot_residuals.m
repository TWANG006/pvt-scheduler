clear;
close all;
clc;

%% load data
data_dir = '../../../data/paper_data/';
maze_file = 'step_02_pvt_2d_from_udo_maze_ibf.mat';
raster_file = 'step_02_pvt_2d_from_udo_raster_ibf.mat';
rap_file = 'step_02_pvt_2d_from_udo_rap_ibf.mat';


%% plot raster
load([data_dir raster_file]);
Xca = Xca * 1e3;
Yca = Yca * 1e3;
Zresidual_ca = Zresidual_ca * 1e9;
px_s = px_s * 1e3;
py_s = py_s * 1e3;

figure;
plot(px_s, py_s, 'Color', [0, 0, 1, 0], 'LineStyle', '-');
hold on;
p = pcolor(Xca, Yca, Zresidual_ca);
c = colorbar('southoutside');
set(c, 'YTick', []);
caxis([-0.5, 0.5]);
colormap jet;
axis image xy;
p.EdgeColor = 'none';
view([0 90]);
hold off;
set(gca, 'XTick', []);
set(gca, 'YTick', []);
grid off;
axis off;
alpha(p, 1); 



%% plot maze
load([data_dir maze_file]);
Xca = Xca * 1e3;
Yca = Yca * 1e3;
Zresidual_ca = Zresidual_ca * 1e9;
px_s = px_s * 1e3;
py_s = py_s * 1e3;

figure;
plot(px_s, py_s, 'Color', [0, 0, 1, 0], 'LineStyle', '-');
hold on;

p = pcolor(Xca, Yca, Zresidual_ca);
c = colorbar('southoutside');
set(c, 'YTick', []);
caxis([-0.5, 0.5]);
colormap jet;
axis image xy;
p.EdgeColor = 'none';
view([0 90]);

hold off;
set(gca, 'XTick', []);
set(gca, 'YTick', []);
grid off;
axis off;
alpha(p, 1); 


%% plot RAP
load([data_dir rap_file]);
Xca = Xca * 1e3;
Yca = Yca * 1e3;
Zresidual_ca = Zresidual_ca * 1e9;
px_s = px_s * 1e3;
py_s = py_s * 1e3;

figure;
plot(px_s, py_s, 'Color', [0, 0, 1, 0], 'LineStyle', '-');
hold on;

p = pcolor(Xca, Yca, Zresidual_ca);
c = colorbar('southoutside');
set(c, 'YTick', []);
caxis([-1, 1]);
colormap jet;
axis image xy;
p.EdgeColor = 'none';
view([0 90]);

hold off;
set(gca, 'XTick', []);
set(gca, 'YTick', []);
grid off;
axis off;
alpha(p, 1); 
clear;
close all;
clc;


%% load data
data_dir = '../../../data/paper_data/';
raster_file = 'step_02_pvt_2d_from_udo_raster_ibf.mat';


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
c = colorbar('eastoutside');
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

%% plot
data_file = 'step_02_pvt_2d_from_udo_raster_ibf.mat';
load([data_dir data_file]);
raster_t = t;
raster_vx_s = vx_s * 1e3;
raster_vy_s = vy_s * 1e3;
raster_ax_s = ax_s * 1e3;
raster_ay_s = ay_s * 1e3;
raster_xp = dwell_x * 1e3;
raster_yp = dwell_y * 1e3;

% dwell time in raster
figure;
s1 = scatter3(raster_xp, raster_yp, raster_t, 5, raster_t);
c = colorbar('eastoutside');
caxis([0.1, 0.3]);
set(c, 'YTick', []);
colormap(parula); 
shading interp;
axis equal;    
view(0,90);
% title(['Raster path, Total dwell time = ' num2str(round(sum(raster_t(:)) / 60, 2)) ' min']);
hold on; 
p1 = plot3(raster_xp, raster_yp, 100 * ones(size(raster_xp)), 'black-', 'LineWidth', 0.5); 
set(gca, 'XTick', []);
set(gca, 'YTick', []);
hold off;


%% residual
res_file = 'after_ibf_surf_ca.mat';
load([data_dir res_file]);
Xca = x1d * 1e3;
Yca = y1d * 1e3;
Zresidual_ca = z2d * 1e9;
px_s = px_s * 1e3;
py_s = py_s * 1e3;

figure;
plot(px_s, py_s, 'Color', [0, 0, 1, 0], 'LineStyle', '-');
hold on;
p = pcolor(Xca, Yca, Zresidual_ca);
c = colorbar('eastoutside');
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

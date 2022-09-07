clear;
close all;
clc;

%% load data
% raster
data_dir = '../../../data/paper_data/';
data_file = 'step_02_pvt_2d_from_udo_raster_ibf.mat';
load([data_dir data_file]);
raster_t = t;
raster_vx_s = vx_s * 1e3;
raster_vy_s = vy_s * 1e3;
raster_ax_s = ax_s * 1e3;
raster_ay_s = ay_s * 1e3;
raster_xp = dwell_x * 1e3;
raster_yp = dwell_y * 1e3;

% maze
data_file = 'step_02_pvt_2d_from_udo_maze_ibf.mat';
load([data_dir data_file]);
maze_t = t;
maze_vx_s = vx_s * 1e3;
maze_vy_s = vy_s * 1e3;
maze_ax_s = ax_s * 1e3;
maze_ay_s = ay_s * 1e3;
maze_xp = dwell_x * 1e3;
maze_yp = dwell_y * 1e3;

% rap
data_file = 'step_02_pvt_2d_from_udo_rap_ibf.mat';
load([data_dir data_file]);
rap_t = t;
rap_vx_s = vx_s * 1e3;
rap_vy_s = vy_s * 1e3;
rap_ax_s = ax_s * 1e3;
rap_ay_s = ay_s * 1e3;
rap_xp = dwell_x * 1e3;
rap_yp = dwell_y * 1e3;

%% plot
% dwell time in raster
figure;
s1 = scatter3(raster_xp, raster_yp, raster_t, 5, raster_t);
c = colorbar('southoutside');
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
% dwell time in maze
figure;
s1 = scatter3(maze_xp, maze_yp, maze_t, 5, maze_t);
c = colorbar('southoutside');
caxis([0.1, 0.3]);
set(c, 'YTick', []);
colormap(parula); 
shading interp;
axis equal;    
view(0,90);
% title(['Maze path, Total dwell time = ' num2str(round(sum(maze_t(:)) / 60, 2)) ' min']);
hold on; 
p1 = plot3(maze_xp, maze_yp, 100 * ones(size(maze_xp)), 'b-', 'LineWidth', 0.5); 
set(gca, 'XTick', []);
set(gca, 'YTick', []);
hold off;
% dwell time in rap
figure;
s1 = scatter3(rap_xp, rap_yp, rap_t, 5, rap_t);
c = colorbar('southoutside');
caxis([0.1, 0.3]);
set(c, 'YTick', []);
colormap(parula); 
shading interp;
axis equal;    
view(0,90);
% title(['Rap path, Total dwell time = ' num2str(round(sum(rap_t(:)) / 60, 2)) ' min']);
hold on; 
p1 = plot3(rap_xp, rap_yp, 100 * ones(size(rap_xp)), 'black-', 'LineWidth', 0.5); 
set(gca, 'XTick', []);
set(gca, 'YTick', []);
hold off;



figure;
plot(rap_vx_s, 'Color', [0.75, 0.75, 0, 0.5], 'LineStyle', '-','LineWidth', 1);
hold on;
plot(maze_vx_s,'Color', [1, 0, 0, 0.5], 'LineStyle', '-','LineWidth', 1);
hold on;
plot(raster_vx_s, 'b-','LineWidth', 1);
hold on;
% plot(1:size(raster_vx_s,1), 0.05*ones(size(raster_vx_s)), 'm-','LineWidth', 0.2);
% plot(1:size(raster_vx_s,1), -0.05*ones(size(raster_vx_s)), 'm-','LineWidth', 0.2);
legend('RAP', 'Maze path', 'Raster path', 'Location', 'north'); 
% title('Velicities x');
xlim([0, size(maze_vx_s, 1)]);
ylim([-60, 60]);
ylabel('[ mm/s ]');
xlabel('# Points');
hold off;
set(gca, 'XTick', []);
set(gca, 'FontSize', 12);

figure;
plot(rap_vy_s, 'Color', [0.75, 0.75, 0], 'LineStyle', '-','LineWidth', 1);
hold on;
plot(maze_vy_s, 'r-','LineWidth', 1);
hold on;
plot(raster_vy_s, 'b-','LineWidth', 1);
hold on;
% plot(1:size(raster_vy_s,1), 0.05*ones(size(raster_vy_s)), 'm-','LineWidth', 0.2);
% plot(1:size(raster_vy_s,1), -0.05*ones(size(raster_vy_s)), 'm-','LineWidth', 0.2);
legend('RAP', 'Maze path', 'Raster path', 'Location', 'north'); 
% title('Velicities x');
xlim([0, size(maze_vy_s, 1)]);
ylim([-60, 60]);
ylabel('[ mm/s ]');
xlabel('# Points');
set(gca, 'XTick', []);
hold off;
set(gca, 'FontSize', 12);



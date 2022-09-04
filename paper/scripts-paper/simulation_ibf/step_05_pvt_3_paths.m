clear;
close all;
clc;

%% load data
% raster
data_dir = '../../../data/paper_data/';
data_file = 'step_02_pvt_2d_from_udo_raster_ibf.mat';
load([data_dir data_file]);
raster_t = t;
raster_vx_s = vx_s;
raster_vy_s = vy_s;
raster_ax_s = ax_s;
raster_ay_s = ay_s;
raster_xp = dwell_x;
raster_yp = dwell_y;

% maze
data_file = 'step_02_pvt_2d_from_udo_maze_ibf.mat';
load([data_dir data_file]);
maze_t = t;
maze_vx_s = vx_s;
maze_vy_s = vy_s;
maze_ax_s = ax_s;
maze_ay_s = ay_s;
maze_xp = dwell_x;
maze_yp = dwell_y;

% rap
data_file = 'step_02_pvt_2d_from_udo_rap_ibf.mat';
load([data_dir data_file]);
rap_t = t;
rap_vx_s = vx_s;
rap_vy_s = vy_s;
rap_ax_s = ax_s;
rap_ay_s = ay_s;
rap_xp = dwell_x;
rap_yp = dwell_y;

%% plot
fsfig('');
% dwell time in raster
subplot(3, 3, 1);
s1 = scatter3(raster_xp * 1e3, raster_yp * 1e3, raster_t, 18, raster_t);
colorbar;
colormap(parula); 
shading interp;
axis equal;    
view(0,90);
title(['Raster path, Total dwell time = ' num2str(round(sum(raster_t(:)) / 60, 2)) ' min']);
hold on; 
p1 = plot3(raster_xp * 1e3, raster_yp * 1e3, 100 * ones(size(raster_xp)), 'b-', 'LineWidth', 0.5); 
alpha(s1, 1.0); 
alpha(p1, 1.0);
hold off;

% dwell time in maze
subplot(3, 3, 2);
s1 = scatter3(maze_xp * 1e3, maze_yp * 1e3, maze_t, 18, maze_t);
colorbar;
colormap(parula); 
shading interp;
axis equal;    
view(0,90);
title(['Maze path, Total dwell time = ' num2str(round(sum(maze_t(:)) / 60, 2)) ' min']);
hold on; 
p1 = plot3(maze_xp * 1e3, maze_yp * 1e3, 100 * ones(size(maze_xp)), 'b-', 'LineWidth', 0.5); 
alpha(s1, 1.0); 
alpha(p1, 1.0);
hold off;

% dwell time in rap
subplot(3, 3, 3);
s1 = scatter3(rap_xp * 1e3, rap_yp * 1e3, rap_t, 18, rap_t);
colorbar;
colormap(parula); 
shading interp;
axis equal;    
view(0,90);
title(['Rap path, Total dwell time = ' num2str(round(sum(rap_t(:)) / 60, 2)) ' min']);
hold on; 
p1 = plot3(rap_xp * 1e3, rap_yp * 1e3, 100 * ones(size(rap_xp)), 'b-', 'LineWidth', 0.5); 
alpha(s1, 1.0); 
alpha(p1, 1.0);
hold off;

subplot(3, 3, 4);
% figure;
plot(raster_vx_s, 'b-','LineWidth', 1);
hold on;
plot(maze_vx_s, 'r-','LineWidth', 1);
plot(rap_vx_s, 'g-','LineWidth', 1);
plot(1:size(raster_vx_s,1), 0.05*ones(size(raster_vx_s)), 'm-','LineWidth', 0.2);
plot(1:size(raster_vx_s,1), -0.05*ones(size(raster_vx_s)), 'm-','LineWidth', 0.2);
legend('raster', 'maze', 'rap'); 
title('Velicities x');
xlim([0,size(maze_vx_s, 1)]);
ylim([-0.06,0.06]);
hold off;

subplot(3, 3, 5);
% figure;
plot(raster_vx_s, 'b-','LineWidth', 1);
hold on;
plot(maze_vx_s, 'r-','LineWidth', 1);
plot(rap_vx_s, 'g-','LineWidth', 1);
plot(1:size(raster_vx_s,1), 0.05*ones(size(raster_vx_s)), 'm-','LineWidth', 0.2);
plot(1:size(raster_vx_s,1), -0.05*ones(size(raster_vx_s)), 'm-','LineWidth', 0.2);
legend('raster', 'maze', 'rap'); 
title('Velicities x');
xlim([0,400]);
ylim([-0.06,0.06]);
hold off;


subplot(3, 3, 7);
% figure;
plot(raster_vy_s, 'b-','LineWidth', 1);
hold on;
plot(maze_vy_s, 'r-','LineWidth', 1);
plot(rap_vy_s, 'g-','LineWidth', 1);
plot(1:size(raster_vy_s,1), 0.05*ones(size(raster_vy_s)), 'm-','LineWidth', 0.2);
plot(1:size(raster_vy_s,1), -0.05*ones(size(raster_vy_s)), 'm-','LineWidth', 0.2);
legend('raster', 'maze', 'rap'); 
title('Velicities x');
xlim([0,size(maze_vy_s, 1)]);
ylim([-0.06,0.06]);
hold off;

subplot(3, 3, 8);
% figure;
plot(raster_vy_s, 'b-','LineWidth', 1);
hold on;
plot(maze_vy_s, 'r-','LineWidth', 1);
plot(rap_vy_s, 'g-','LineWidth', 1);
plot(1:size(raster_vy_s,1), 0.05*ones(size(raster_vy_s)), 'm-','LineWidth', 0.2);
plot(1:size(raster_vy_s,1), -0.05*ones(size(raster_vy_s)), 'm-','LineWidth', 0.2);
legend('raster', 'maze', 'rap'); 
title('Velicities x');
xlim([0,400]);
ylim([-0.06,0.06]);
hold off;






%% plot - no scale
% dwell time
figure;
set(gcf,'position',[600,300,350,130]);
% s1 = scatter3(raster_xp * 1e3, raster_yp * 1e3, raster_t, 18, raster_t);
% s1 = scatter3(maze_xp * 1e3, maze_yp * 1e3, maze_t, 18, maze_t);
s1 = scatter3(rap_xp * 1e3, rap_yp * 1e3, rap_t, 18, rap_t);
h = colorbar;
colormap(parula); 
set(h, 'YTick', []);
shading interp;
axis equal;    
view(0,90);
set(gca,'xcolor', 'none');
set(gca,'ycolor', 'none');
hold on; 
% p1 = plot3(raster_xp * 1e3, raster_yp * 1e3, 100 * ones(size(raster_xp)), 'b-', 'LineWidth', 0.5); 
% p1 = plot3(maze_xp * 1e3, maze_yp * 1e3, 100 * ones(size(maze_xp)), 'b-', 'LineWidth', 0.5); 
p1 = plot3(rap_xp * 1e3, rap_yp * 1e3, 100 * ones(size(rap_xp)), 'b-', 'LineWidth', 0.5); 
alpha(s1, 1.0); 
alpha(p1, 1.0);
hold off;

% velocity
draw_x = true;
figure;
set(gcf,'position',[600,300,350,230]);
if draw_x == true
    plot(raster_vx_s, 'b-','LineWidth', 2); % v_x ==
else
    plot(raster_vy_s, 'b-','LineWidth', 2); % v_y ==
end;
set(gca,'xtick', []);
set(gca,'ytick', []);
hold on;
if draw_x == true
    plot(maze_vx_s, 'r-','LineWidth', 2); %  v_x ==
    plot(rap_vx_s, 'g-','LineWidth', 2);
else
    plot(maze_vy_s, 'r-','LineWidth', 2); %  v_y ==
    plot(rap_vy_s, 'g-','LineWidth', 2);
end;
plot(1:size(raster_vx_s,1), 0.05*ones(size(raster_vx_s)), 'm-','LineWidth', 0.2);
plot(1:size(raster_vx_s,1), -0.05*ones(size(raster_vx_s)), 'm-','LineWidth', 0.2);
% legend('raster', 'maze', 'rap'); 
% title('Velicities x');
xlim([0,size(maze_vx_s, 1)]);
xlim([4000,4050]); % show in [0,400] area
ylim([-0.06,0.06]);
hold off;





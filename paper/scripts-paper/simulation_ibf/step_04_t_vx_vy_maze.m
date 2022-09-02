clear;
close all;
clc;

%% load data
% const_acc model
data_dir = '../../../data/paper_data/';
data_file = 'step_02_const_a_2d_from_udo_maze_ibf.mat';
load([data_dir data_file]);
const_t = t;
const_vx_s = vx_s;
const_vy_s = vy_s;
const_xp = dwell_x;
const_yp = dwell_y;

% pvt model
data_dir = '../../../data/paper_data/';
data_file = 'step_02_pvt_2d_from_udo_maze_ibf.mat';
load([data_dir data_file]);
pvt_t = t;
pvt_vx_s = vx_s;
pvt_vy_s = vy_s;
pvt_xp = dwell_x;
pvt_yp = dwell_y;

%% plot
fsfig('');
subplot(3, 2, 1);
s1 = scatter3(const_xp * 1e3, const_yp * 1e3, const_t, 18, const_t);
colorbar;
colormap(parula); 
shading interp;
axis equal;    
view(0,90);
title(['Const-acc model, Total dwell time = ' num2str(round(sum(const_t(:)) / 60, 2)) ' min']);
hold on; 
p1 = plot3(const_xp * 1e3, const_yp * 1e3, 100 * ones(size(const_xp)), 'b-', 'LineWidth', 0.5); 
alpha(s1, 1.0); 
alpha(p1, 1.0);
hold off;

subplot(3, 2, 2);
s2 = scatter3(pvt_xp * 1e3, pvt_yp * 1e3, pvt_t, 18, pvt_t);
colorbar;
colormap(parula);
shading interp;
axis equal;    
view(0,90);
title(['PVT model, Total dwell time = ' num2str(round(sum(pvt_t(:)) / 60, 2)) ' min']);
hold on; 
p2 = plot3(pvt_xp * 1e3, pvt_yp * 1e3, 100 * ones(size(pvt_xp)), 'b-', 'LineWidth', 0.5); 
alpha(s2, 1.0); 
alpha(p2, 1.0);
hold off;

subplot(3, 2, 3);
plot(const_vx_s, 'b-','LineWidth', 1);
hold on;
plot(pvt_vx_s, 'r-','LineWidth', 1);
legend('const-acc', 'pvt'); 
title('Velicities x');

subplot(3, 2, 4);
plot(const_vx_s, 'b-','LineWidth', 1);
hold on;
plot(pvt_vx_s, 'r-','LineWidth', 1);
xlim([0,300]);
legend('const-acc', 'pvt'); 
title('Velicities x');

subplot(3, 2, 5);
plot(const_vy_s, 'b-','LineWidth', 1);
hold on;
plot(pvt_vy_s, 'r-','LineWidth', 1);
legend('const-acc', 'pvt'); 
title('Velicities y');

subplot(3, 2, 6);
plot(const_vy_s, 'b-','LineWidth', 1);
hold on;
plot(pvt_vy_s, 'r-','LineWidth', 1);
xlim([0,300]);
legend('const-acc', 'pvt'); 
title('Velicities y');

%% plot - no scale
% dewll time map
figure;
set(gcf,'position',[600,300,400,130]);
s1 = scatter3(const_xp * 1e3, const_yp * 1e3, const_t, 18, const_t);
h = colorbar;
colormap(parula); 
set(h, 'YTick', []);
shading interp;
axis equal;    
view(0,90);
set(gca,'xcolor', 'none');
set(gca,'ycolor', 'none');
% title(['Const-acc model, Total dwell time = ' num2str(round(sum(const_t(:)) / 60, 2)) ' min']);
% hold on; 
% p1 = plot3(const_xp * 1e3, const_yp * 1e3, 100 * ones(size(const_xp)), 'b-', 'LineWidth', 0.5); 
% alpha(s1, 1.0); 
% alpha(p1, 1.0);
% hold off;

%% vx - no scale
figure;
set(gcf,'position',[600,300,270,130]);
plot(const_vx_s, 'b-','LineWidth', 2);
xlim([1 size(const_vx_s,1)]);
set(gca,'xtick', []);
set(gca,'ytick', []);
hold on;
plot(pvt_vx_s, 'r-','LineWidth', 0.2);
plot(1:size(pvt_vx_s,1), 3 * max(pvt_vx_s)*ones(size(pvt_vx_s)), 'm-','LineWidth', 0.2);
plot(1:size(pvt_vx_s,1), -3 * max(pvt_vx_s)*ones(size(pvt_vx_s)), 'm-','LineWidth', 0.2);
hold off;
% legend('const-acc', 'pvt'); 
% title('Velicities x');

% vx in points 1~100 area
figure;
set(gcf,'position',[600,300,200,130]);
plot(const_vx_s, 'b-','LineWidth', 1);
% set(gca,'xtick', []);
% set(gca,'ytick', []);
hold on;
plot(pvt_vx_s, 'r-','LineWidth', 1);
xlim([100,250]);
% legend('const-acc', 'pvt'); 
% title('Velicities x');

%% vy - no scale
figure;
set(gcf,'position',[600,300,270,130]);
plot(const_vy_s, 'b-','LineWidth', 2);
xlim([1 size(const_vy_s,1)]);
set(gca,'xtick', []);
set(gca,'ytick', []);
hold on;
plot(pvt_vx_s, 'r-','LineWidth', 0.2);
plot(1:size(pvt_vy_s,1), 3 * max(pvt_vy_s)*ones(size(pvt_vy_s)), 'm-','LineWidth', 0.2);
plot(1:size(pvt_vy_s,1), -3 * max(pvt_vy_s)*ones(size(pvt_vy_s)), 'm-','LineWidth', 0.2);
hold off;
% legend('const-acc', 'pvt'); 
% title('Velicities x');

% vx in points 1~100 area
figure;
set(gcf,'position',[600,300,200,130]);
plot(const_vy_s, 'bo-','LineWidth', 1);
% set(gca,'xtick', []);
% set(gca,'ytick', []);
hold on;
plot(pvt_vy_s, 'ro-','LineWidth', 1);
xlim([6500,6550]);
legend('const-acc', 'pvt'); 
% title('Velicities x');

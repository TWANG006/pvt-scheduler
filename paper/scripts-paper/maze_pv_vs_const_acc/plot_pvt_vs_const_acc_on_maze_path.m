clear;
close all;
clc;

%% load data
% const_acc model
data_dir = '../../../data/paper_data/';
data_file = 'step_02_const_a_2d_from_udo_maze_ibf.mat';
load([data_dir data_file]);
const_t = t;
const_vx_s = vx_s*1e3;
const_vy_s = vy_s*1e3;
const_xp = dwell_x*1e3;
const_yp = dwell_y*1e3;
const_px = px*1e3;
const_py = py*1e3;
const_pxs = px_s * 1e3;
const_pys = py_s * 1e3;

% pvt model
data_dir = '../../../data/paper_data/';
data_file = 'step_02_pvt_2d_from_udo_maze_ibf.mat';
load([data_dir data_file]);
pvt_t = t;
pvt_vx_s = vx_s * 1e3;
pvt_vy_s = vy_s * 1e3;
pvt_xp = dwell_x * 1e3;
pvt_yp = dwell_y * 1e3;
pvt_px = px * 1e3;
pvt_py = py * 1e3;
pvt_pxs = px_s * 1e3;
pvt_pys = py_s * 1e3;

n = 30 + (1: 60);

%% 


%%
% %% plot
% fsfig('');
% subplot(3, 2, 1);
figure;
s1 = scatter3(const_xp, const_yp, const_t, 5, const_t);
c = colorbar('southoutside');
set(c, 'YTick', []);
colormap(parula); 
shading interp;
axis equal;    
view(0,90);
% title(['Const-acc model, Total dwell time = ' num2str(round(sum(const_t(:)) / 60, 2)) ' min']);
hold on; 
p1 = plot3(const_px, const_py, 100 * ones(size(const_py)), 'black-', 'LineWidth', 0.5); 
p3 = plot3(pvt_px(n), pvt_py(n), 100*ones(size(pvt_px(n))), 'blue-', 'LineWidth', 2);
alpha(s1, 1.0); 
alpha(p1, 1.0);
set(gca, 'XTick', []);
set(gca, 'YTick', []);
hold off;
% 
% subplot(3, 2, 2);
figure;
s2 = scatter3(pvt_xp, pvt_yp, pvt_t, 5, pvt_t);
c = colorbar('southoutside');
set(c, 'YTick', []);
colormap(parula);
shading interp;
axis equal;    
view(0,90);
% title(['PVT model, Total dwell time = ' num2str(round(sum(pvt_t(:)) / 60, 2)) ' min']);
hold on; 
p2 = plot3(pvt_px, pvt_py, 100 * ones(size(pvt_py)), 'black-', 'LineWidth', 0.5); hold on;
p3 = plot3(pvt_px(n), pvt_py(n), 100*ones(size(pvt_px(n))), 'red-', 'LineWidth', 2);
alpha(s2, 1.0); 
alpha(p2, 1.0);
set(gca, 'XTick', []);
set(gca, 'YTick', []);
hold off;
% 
figure;
subplot(2,1,1);
plot(n, const_vx_s(n), 'b-','LineWidth', 2);
hold on;
plot(n, pvt_vx_s(n), 'r-','LineWidth', 2);
legend('Constant-acceleration', 'PVT'); 
title('Velicities in the{\it x} direction', 'FontWeight', 'normal');
% xlabel('# Points');
ylabel('[ mm ]');
set(gca, 'XTick', []);
set(gca, 'FontSize', 12);
axis tight;

subplot(2,1,2);
plot(n, const_vy_s(n), 'b-','LineWidth', 2);
hold on;
plot(n, pvt_vy_s(n), 'r-','LineWidth', 2);
legend('Constant-acceleration', 'PVT'); 
title('Velicities in the{\it y} direction', 'FontWeight', 'normal');
xlabel('# Points');
ylabel('[ mm ]');
set(gca, 'FontSize', 12);
axis tight
% 
% subplot(3, 2, 5);
% plot(const_vy_s, 'b-','LineWidth', 1);
% hold on;
% plot(pvt_vy_s, 'r-','LineWidth', 1);
% legend('const-acc', 'pvt'); 
% title('Velicities y');
% 
% subplot(3, 2, 6);
% plot(const_vy_s, 'b-','LineWidth', 1);
% hold on;
% plot(pvt_vy_s, 'r-','LineWidth', 1);
% xlim([0,300]);
% legend('const-acc', 'pvt'); 
% title('Velicities y');
% 
% %% plot - no scale
% % dewll time map
% figure;
% set(gcf,'position',[600,300,400,130]);
% s1 = scatter3(const_xp * 1e3, const_yp * 1e3, const_t, 18, const_t);
% h = colorbar;
% colormap(parula); 
% set(h, 'YTick', []);
% shading interp;
% axis equal;    
% view(0,90);
% set(gca,'xcolor', 'none');
% set(gca,'ycolor', 'none');
% % title(['Const-acc model, Total dwell time = ' num2str(round(sum(const_t(:)) / 60, 2)) ' min']);
% % hold on; 
% % p1 = plot3(const_xp * 1e3, const_yp * 1e3, 100 * ones(size(const_xp)), 'b-', 'LineWidth', 0.5); 
% % alpha(s1, 1.0); 
% % alpha(p1, 1.0);
% % hold off;
% 
% %% vx - no scale
% figure;
% set(gcf,'position',[600,300,270,130]);
% plot(const_vx_s, 'b-','LineWidth', 2);
% xlim([1 size(const_vx_s,1)]);
% set(gca,'xtick', []);
% set(gca,'ytick', []);
% hold on;
% plot(pvt_vx_s, 'r-','LineWidth', 0.2);
% plot(1:size(pvt_vx_s,1), 3 * max(pvt_vx_s)*ones(size(pvt_vx_s)), 'm-','LineWidth', 0.2);
% plot(1:size(pvt_vx_s,1), -3 * max(pvt_vx_s)*ones(size(pvt_vx_s)), 'm-','LineWidth', 0.2);
% hold off;
% % legend('const-acc', 'pvt'); 
% % title('Velicities x');
% 
% % vx in points 1~100 area
% figure;
% set(gcf,'position',[600,300,200,130]);
% plot(const_vx_s, 'b-','LineWidth', 1);
% % set(gca,'xtick', []);
% % set(gca,'ytick', []);
% hold on;
% plot(pvt_vx_s, 'r-','LineWidth', 1);
% xlim([100,250]);
% % legend('const-acc', 'pvt'); 
% % title('Velicities x');
% 
% %% vy - no scale
% figure;
% set(gcf,'position',[600,300,270,130]);
% plot(const_vy_s, 'b-','LineWidth', 2);
% xlim([1 size(const_vy_s,1)]);
% set(gca,'xtick', []);
% set(gca,'ytick', []);
% hold on;
% plot(pvt_vx_s, 'r-','LineWidth', 0.2);
% plot(1:size(pvt_vy_s,1), 3 * max(pvt_vy_s)*ones(size(pvt_vy_s)), 'm-','LineWidth', 0.2);
% plot(1:size(pvt_vy_s,1), -3 * max(pvt_vy_s)*ones(size(pvt_vy_s)), 'm-','LineWidth', 0.2);
% hold off;
% % legend('const-acc', 'pvt'); 
% % title('Velicities x');
% 
% % vx in points 1~100 area
% figure;
% set(gcf,'position',[600,300,200,130]);
% plot(const_vy_s, 'bo-','LineWidth', 1);
% % set(gca,'xtick', []);
% % set(gca,'ytick', []);
% hold on;
% plot(pvt_vy_s, 'ro-','LineWidth', 1);
% xlim([6500,6550]);
% legend('const-acc', 'pvt'); 
% % title('Velicities x');

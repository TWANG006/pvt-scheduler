clear;
% close all;
clc;
addpath('../functions/');
addpath('../../../Slope-based-dwell-time/matlab/functions/'); % import rms_std

%% load data
surfDir = '../../../data/paper_data/';

% surfFile = 'step_00_rect_map_raster_ibf_tif_5mm'; % raster
% surfFile = 'step_00_rect_map_maze_ibf_tif_5mm.mat'; %maze
surfFile = 'step_00_rect_map_rap_ibf_tif_5mm.mat'; %rap

load([surfDir surfFile]);

%% plot
figure;
set(gcf,'position',[600,300,680,150]);
% ShowSurfaceMap(Xca, Yca, Zca, 3, true, 1e9, 'nm', ''); 
p1 = plot(dwell_x * 1e3, dwell_y * 1e3,  'b-', 'LineWidth', 1.2); 

hold on; 
s = pcolor(Xca* 1e3, Yca* 1e3, Zca* 1e3); 
s.EdgeColor = 'none';
view(0,90);
colormap jet;
grid off;
set(gca,'xcolor', 'none');
set(gca,'ycolor', 'none');
set(0,'defaultfigurecolor','w');

alpha(s, 0.3);
% alpha(p1, 0.1);
hold off;

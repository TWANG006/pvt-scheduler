% Generate a stitched maze path.
clear; clc;
close all;

outDir = '../../data/sim_data/';
%% input parameters.
% workpiece.
length = 80; % unit:[mm]. max(length, width) must be even.
width = 26;

% maze module for stitched.
l_module = 20; %must be even
w_module = 14; %must be even.

xp_all = []; % all points
yp_all = [];

i_n = ceil(width/(w_module+1));
for i = 1: i_n
    if mod(i,2) == 1 && i ~= i_n
        [xp, yp] = maze_module(length, l_module, w_module);
        yp = yp + (i-1)* (w_module + 1);
    end
    if mod(i,2) == 0 && i ~= i_n
        [xp, yp] = maze_module(length, l_module, w_module);
        xp = fliplr(xp);
        yp = fliplr(yp);        
        yp = w_module - yp;
        yp = yp + (i-1)* (w_module + 1);
    end
    if mod(i,2) == 1 && i == i_n
        w_res = width - (i-1)* (w_module+1);
        [xp, yp] = maze_module(length, l_module, w_res);
        yp = yp + (i-1)* (w_module + 1);
    end
    if mod(i,2) == 0 && i == i_n
        w_res = width - (i-1)* (w_module+1);
        [xp, yp] = maze_module(length, l_module, w_module);
        xp = fliplr(xp);
        yp = fliplr(yp);        
        yp = w_module - yp;
        yp = yp + (i-1)* (w_module + 1);
    end
    
    xp_all = [xp_all, xp];
    yp_all = [yp_all, yp];
    
end


figure;
plot(xp_all,yp_all,'marker', 'o', 'linestyle', '-','linewidth',2);
axis xy tight equal;
xlabel('x [mm]');
ylabel('y [mm]');


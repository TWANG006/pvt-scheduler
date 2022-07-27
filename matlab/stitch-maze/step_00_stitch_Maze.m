% Generate a stitched maze path.
clear; clc;
close all;

outDir = '../../data/sim_data/';
%% input parameters.
% workpiece.
length = 46; % unit:[mm]. max(length, width) must be even.
width = 8; 

% maze module for stitched.
l_module = 6; %must be even
w_module = 4; %must be even.

% [xp, yp, order_dp] = rectangular_maze_stitch(l_module, w_module);
% [m,n] = size(order_dp);

coArray = ['b','r','m','c','g','y','k'];
%% path 1: Several complete maze modules
xp_a = []; % all points in path
yp_a = [];

for i = 1: fix(length/l_module)
    [xp, yp, order_dp] = rectangular_maze_stitch(l_module, w_module);
    [m,n] = size(order_dp);
    xp = xp+(i-1)*n;
    [xp_1, yp_1] = x_module_maze( xp, yp, order_dp);
%     [xp_1, yp_1] = x_module_maze( xp+(i-1)*n, yp, order_dp);
    
    plot(xp_1,yp_1,'marker', 'o', 'linestyle', '-', 'color', coArray(i),'linewidth',2); 
    axis xy tight equal;
    xlabel('x [mm]');
    ylabel('y [mm]');
    hold on;
    
    xp_a = [xp_a, xp_1];
    yp_a = [yp_a, yp_1];
end
hold off;

% plot(xp_a, yp_a, 'bo-');axis xy tight equal;
% axis equal;
% xlabel('x [mm]');
% ylabel('y [mm]');

%% path 2: Residual modules in x-direction
l_r = mod(length, l_module);
if l_r > w_module
    [xp, yp, order_dp] = rectangular_maze_stitch(l_r, w_module);
    xp = xp+fix(length/l_module)*n;
    [xp_2, yp_2] = x_module_maze(xp, yp, order_dp);

    hold on;
    plot(xp_2,yp_2,'marker', 'o', 'linestyle', '-', 'linewidth',2); 
    % axis xy tight equal;
    % xlabel('x [mm]');
    % ylabel('y [mm]');
    hold off;

    xp_a = [xp_a, xp_2];
    yp_a = [yp_a, yp_2];
end

if (l_r <= w_module) && (l_r >0)    
    x_addline_1 = l_module * fix(length/l_module) + [0: l_r];
    y_addline_1 = zeros(size(x_addline_1));
    hold on;
    plot(x_addline_1,y_addline_1,'marker', 'o', 'linestyle', '-', 'linewidth',2); 
    hold off;
    
    [xp, yp, order_dp] = rectangular_maze_stitch(w_module, l_r);   
    [xp_2, yp_2] = x_module_maze_rotate(xp, yp, order_dp);
    xp_2 = xp_2 + l_module * fix(length/l_module);
    yp_2 = yp_2 + 1;
    
    hold on;
    plot(xp_2,yp_2,'marker', 'o', 'linestyle', '-', 'linewidth',2); 
    hold off;

    xp_a = [xp_a, x_addline_1, xp_2];
    yp_a = [yp_a, y_addline_1, yp_2];
end

%% path 3: 
if l_r > w_module
    yp_addline_2 = 0: w_module;
    xp_addline_2 = length * ones(size(yp_addline_2)); 
    hold on;
    plot(xp_addline_2,yp_addline_2,'marker', 'o', 'linestyle', '-', 'linewidth',2); 
    hold off;
    
    xp_a = [xp_a, xp_addline_2];
    yp_a = [yp_a, yp_addline_2];
end



figure;
plot(xp_a, yp_a, 'r-o');axis xy tight equal;
axis equal;
xlabel('x [mm]');
ylabel('y [mm]');

return

%% dwell point
dp_x = []; % dwell points
dp_y = [];
for i = 1: size(xp_all,2) - 1
    if yp_all(i) == yp_all(i+1)
        dp_x(i) = (xp_all(i) + xp_all(i+1))/2;
        dp_y(i) = yp_all(i);
    end
    if xp_all(i) == xp_all(i+1)
        dp_x(i) = xp_all(i);
        dp_y(i) = (yp_all(i) + yp_all(i+1))/2;
    end   
end

plot(xp_all,yp_all,'b*-','linewidth',2);  
hold on
plot(dp_x,dp_y,'ro','linewidth',2);  
hold off;
axis equal;
set(gca,'xcolor', 'none');
set(gca,'ycolor', 'none');

%% save data
xp = xp_all;
yp = yp_all;

% save([outDir mfilename '_dp.mat'], ...
%     'xp', 'yp', ... % path points
%     'dp_x', 'dp_y'  ... % dwell points
%     );

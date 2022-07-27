clear; clc;
% close all;

tic
%% load data
surfDir = '../../data/sim_data/';
surfFile = 'step_00_rectangular_maze_non_unicursal_dp.mat';
load([surfDir surfFile]);
outDir = '../../data/sim_data/';

[m,n] = size(order_dp);

%% path 1

xp1 = fliplr(xp);
yp1 = fliplr(yp);

order_dp1 = m*n - order_dp + 1;

xp1 = [xp1(1), xp1, xp1(m*n)];
yp1 = [yp1(1)-1, yp1, yp1(m*n)-1];
yp1 = yp1 -min(yp1);

plot(xp1, yp1, 'b-o');axis xy tight equal;
axis equal;
xlabel('x [mm]');
ylabel('y [mm]');

%% add dwell points -1 
xp_add1 = 2: n-1;
yp_add1 = zeros(size(xp_add1));
xp1 = [xp1, xp_add1];
yp1 = [yp1, yp_add1];

figure;
plot(xp1, yp1, 'b-o');axis xy tight equal;
axis equal;
xlabel('x [mm]');
ylabel('y [mm]');

%% path 2
xp2 = xp1 + n;
yp2 = yp1;

hold on;
plot(xp2, yp2, 'r-*');axis xy tight equal;
hold off;

%% path 3
xp3 = xp1 + 2*n;
yp3 = yp1;

hold on;
plot(xp3, yp3, 'm-*');axis xy tight equal;
hold off;

%% add dwell points -2 
yp_add2 = 0: m;
xp_add2 = 3 * n * ones(size(yp_add2)); %%%%

hold on;
plot(xp_add2, yp_add2, 'g-*');axis xy tight equal;
hold off;

%% block 1 & 2
xp_block1 = [xp1, xp2, xp3];
yp_block1 = [yp1, yp2, yp3];

xp_block2 = fliplr(xp_block1) + 1;
yp_block2 = fliplr(yp_block1) + m + 1;

hold on;
plot(xp_block2, yp_block2, 'c-^');axis xy tight equal;
hold off;

%% add dwell points -3 
yp_add3 = m+1: 2*m+1;
xp_add3 = zeros(size(yp_add3)); %%%%

hold on;
plot(xp_add3, yp_add3, 'g-*');axis xy tight equal;
hold off;

%% All points
xp_all = [xp_block1, xp_add2, xp_block2, xp_add3];
yp_all = [yp_block1, yp_add2, yp_block2, yp_add3];

figure;
plot(xp_all, yp_all, 'r-o');axis xy tight equal;
axis equal;
xlabel('x [mm]');
ylabel('y [mm]');

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

% if xp_all(1) == xp_all(size(xp_all,2))
%     dp_x = [dp_x, xp_all(1)];
%     dp_y = [dp_y, (yp_all(1)+yp_all(size(yp_all,2)))/2];
% end
% if yp_all(1) == yp_all(size(yp_all,2))
%     dp_x = [dp_x, (xp_all(1)+xp_all(size(xp_all,2)))/2];
%     dp_y = [dp_y, yp_all(1)];
% end


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


toc
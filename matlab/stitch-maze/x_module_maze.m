function [xp1, yp1] = x_module_maze(xp, yp, order_dp)

[m,n] = size(order_dp);

xp1 = fliplr(xp);
yp1 = fliplr(yp);

xp1 = [xp1(1), xp1, xp1(m*n)];
yp1 = [yp1(1)-1, yp1, yp1(m*n)-1];
yp1 = yp1 -min(yp1);

% plot(xp1, yp1, 'b-o');axis xy tight equal;
% axis equal;
% xlabel('x [mm]');
% ylabel('y [mm]');

%% add dwell points -1 
seq_xp = sort(xp1);
ss_xp = min(seq_xp(find(seq_xp-min(seq_xp))));% second smallest
xp_add1 = ss_xp: max(xp1);
% xp_add1 = 2: n-1;
yp_add1 = zeros(size(xp_add1));
xp1 = [xp1, xp_add1];
yp1 = [yp1, yp_add1];

% figure;
% plot(xp1, yp1, 'b-o');axis xy tight equal;
% axis equal;
% xlabel('x [mm]');
% ylabel('y [mm]');

end
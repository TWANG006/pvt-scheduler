function [xp_r, yp_r] = x_module_maze_rotate(xp, yp, order_dp)

[m,n] = size(order_dp);

if m ~= n
    xp1 = fliplr(xp);
    yp1 = fliplr(yp);
    xp1 = [xp1(1), xp1, xp1(m*n)];
    yp1 = [yp1(1)-1, yp1, yp1(m*n)-1];
    yp1 = yp1 -min(yp1);

    % Rotate 90° counterclockwise
    xp_r = yp1;
    xp_r = max(xp_r) - xp_r;
    yp_r = xp1;
else
    xp_r = max(xp) - xp;
    yp_r = yp;
    xp_r = [xp_r(1)+1, xp_r, xp_r(end)+1];
    yp_r = [yp_r(1), yp_r, yp_r(end)];
end

% figure;
% plot(xp_r, yp_r, 'b-o');axis xy tight equal;
% axis equal;
% xlabel('x [mm]');
% ylabel('y [mm]');

%% add dwell points -1 
seq_yp = sort(yp_r);
ss_yp = min(seq_yp(find(seq_yp-min(seq_yp))));% second smallest
yp_add1 = ss_yp: max(yp_r);
xp_add1 = max(xp_r)*ones(size(yp_add1));
xp_r = [xp_r, xp_add1];
yp_r = [yp_r, yp_add1];

% hold on;
% plot(xp_r, yp_r, 'r-o');axis xy tight equal;
% axis equal;
% xlabel('x [mm]');
% ylabel('y [mm]');
% hold off;

end
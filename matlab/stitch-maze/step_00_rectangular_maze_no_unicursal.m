% Rectangular maze path.
% No unicursal in Row 1. 

clear; clc;
close all;

outDir = '../../data/sim_data/';
%% input parameters.
length = 14; %unit:[mm]. max(length, width) must be even.
width = 8; 
max_iter = 1; % maximum number of cycles

b_remaze = 1; 
i_iter = 0;

while b_remaze
    half_dp = max(length, width);
    [Dx, Dy, X_dp, Y_dp, S] = maze_path(0.5*half_dp, 0.5); % call square maze algorithm.
    
    % dwell points. (Xp, Yp)
    [Xp, Yp] = meshgrid(0 : 0.5*size(X_dp,2)-1, 0 : 0.5*size(X_dp,1)-1);
    surf_mpp = 2 * median(diff(X_dp(1, :)));
    Xp = Xp * surf_mpp;
    Yp = Yp * surf_mpp;
    Xp = Xp - nanmean(Xp(:));
    Yp = Yp - nanmean(Yp(:));
    
    % sequence number of maze path.
    Sn = zeros(size(Xp,1), size(Xp,2)) * NaN;
    [m,n] = size(Sn);
    for i = 1 : size(Dx,2)
        j_p = (Dx(i) - min(Xp(:))) / median(diff(Xp(1, :))) + 1;
        i_p = (Dy(i) - min(Yp(:))) / (median(diff(Yp(:, 1)))) + 1;
        Sn(i_p, j_p) = i;
    end
    
    % delete several rows or columns.
    Sn1 = Sn;
    Xp1 = Xp;
    Yp1 = Yp;
    
    i_del = abs(length - width);
    if length > width
        for i = 1 : i_del
            Sn1(1, :) = [];
            Xp1(1, :) = [];
            Yp1(1, :) = [];
        end
    end
    if length < width
        for i = 1 : i_del
            Sn1(:, 1) = [];
            Xp1(:, 1) = [];
            Yp1(:, 1) = [];
        end
    end
    
    % re-draw maze path.
    n_entrance = min(Sn1(1, :));
    n_exit = max(Sn1(1, :));
    
    [m1,n1] = size(Sn1);
    re_Sn = zeros(m1, n1) * NaN;
    re_Dx = [];
    re_Dy = [];
    j = 1;
    for i = n_entrance: m*n
        [m2,n2] = find(Sn1 == i);
        if ~isnan(m2)
            re_Sn(m2, n2) = j;
            re_Dx(j) = Xp1(m2, n2);
            re_Dy(j) = Yp1(m2, n2);
            j = j+1;
        end    
    end
    
    u_re_Sn = [-1*ones(1,n1); re_Sn]; % compare with upwards
    u_diff = (abs(diff(u_re_Sn)) == 1);
    
    d_re_Sn = [re_Sn; -1*ones(1,n1)]; % compare with downwards
    d_re_Sn = flipud(d_re_Sn);
    d_diff = (abs(diff(d_re_Sn)) == 1);
    d_diff = flipud(d_diff);
    
    l_re_Sn = [-1*ones(m1,1), re_Sn]; % compare with left
    l_diff = (abs(diff(l_re_Sn , 1, 2)) == 1);
    
    r_re_Sn = [re_Sn, -1*ones(m1,1)]; % compare with right
    r_re_Sn = fliplr(r_re_Sn);
    r_diff = (abs(diff(r_re_Sn, 1, 2)) == 1);
    r_diff = fliplr(r_diff);
    
    i_iter = i_iter + 1; % number of iterations
    
    b_seq = u_diff + d_diff + l_diff + r_diff;
    minus_bseq = (2*m1*n1 - 2) - sum(sum(b_seq))
    if (minus_bseq == 0) || (i_iter == max_iter)
        b_remaze = 0; % out of the while loop
    end
    
end


%% display
figure;
plot(re_Dx * 1e-3, re_Dy * 1e-3, 'r-*');axis xy tight equal;
axis equal;
set(gca,'xcolor', 'none');
set(gca,'ycolor', 'none');
title('Rectangular maze');
xlabel('x [mm]');
ylabel('y [mm]');

if length > width
    % Labeling entrance and exit
    x_entrance = re_Dx(1);
    y_entrance = re_Dy(1) -  median(diff(Yp1(:, 1)));
    x_exit = re_Dx(size(re_Dx,2));
    y_exit = re_Dy(size(re_Dy,2)) -  median(diff(Yp1(:, 1)));
end
if length <= width
    % Labeling entrance and exit
    x_entrance = re_Dx(1) -  median(diff(Xp1(1, :)));
    y_entrance = re_Dy(1);
    x_exit = re_Dx(size(re_Dx,2))  -  median(diff(Xp1(1, :)));
    y_exit = re_Dy(size(re_Dy,2));
end

    hold on;
    plot([x_entrance * 1e-3, re_Dx(1) * 1e-3], [y_entrance * 1e-3, re_Dy(1) * 1e-3], 'bo--');
    plot([x_exit * 1e-3, re_Dx(size(re_Dx,2)) * 1e-3], [y_exit * 1e-3, re_Dy(size(re_Dy,2)) * 1e-3], 'mo--');
    text(x_entrance * 1e-3, y_entrance * 1e-3,'ENT');
    text(x_exit * 1e-3, y_exit * 1e-3,'EX');
    xlabel('x [mm]');
    ylabel('y [mm]');
    hold off;

%% save data
xp = re_Dx;
yp = re_Dy;
xp = xp - min(xp);
yp = yp - min(yp);
order_dp = re_Sn;
% figure;
% plot(xp, yp, 'r-*');axis xy tight equal;
% axis equal;
% xlabel('x [mm]');
% ylabel('y [mm]');

save([outDir mfilename '.mat'], ...
    'xp', 'yp',  ...
    'order_dp' ...
    );
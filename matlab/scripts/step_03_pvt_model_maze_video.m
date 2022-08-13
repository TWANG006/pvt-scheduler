clear;
close all;
clc;
addpath(genpath('../functions'));
addpath('../../../Slope-based-dwell-time/matlab/functions/'); % import viridis
%% l. load data
% calculated pvt
data_dir = '../../data/sim_data/';
% load([data_dir 'step_02_pvt_2d_from_udo.mat']);
load([data_dir 'step_02_pvt_2d_from_udo_ibf.mat']);

pvt_t = cs_t;
X = Xca;
Y = Yca;
Z = Zca;

%% 2. calculate the delta t
% direct assignment
tau = 1/20;  % ms， 1/60

% fsfig('velocity map');
% subplot(121);
% show_pvt_v_maze(px_s, py_s, vx_s, viridis, 'Velocity X');
% subplot(122);
% show_pvt_v_maze(px_s, py_s, vy_s, viridis, 'Velocity Y');

%% 3. TIF schematic
r_tif =  0.5 * (nanmax(Xtif(:)) - nanmin(Xtif(:)));
theta=0: pi/50: 2*pi;

x_tif = r_tif * cos(theta);
y_tif = r_tif * sin(theta);
z_tif = ones(size(x_tif)) * 100000;


%% 4. generate simulation videos
F = griddedInterpolant(...
    Xtif', ...
    (-Ytif)', ...
    flipud(Ztif)', ...
    'cubic', ...
    'none' ...
    );

Zremoval = 0 * Z;

min_x = nanmin(X(:)) - 2 * r_tif;
max_x = nanmax(X(:)) + 2 * r_tif;

min_y = nanmin(Y(:)) - 2 * r_tif;
max_y = nanmax(Y(:)) + 2 * r_tif;

writerObj=VideoWriter('pvt_sim_test.avi');%make a movie
writerObj.FrameRate = 1/tau; %60
open(writerObj);

tmp_Z = remove_polynomials(X, Y, Z, 1);

range_z = 0.5 * (nanmax(tmp_Z(:)) - nanmin(tmp_Z(:)));

delta_s = 0 * ones(size(px_s));
delta_v = 0 * ones(size(px_s));
delta_t = 0 * ones(size(px_s));

figure;
for i = 1: size(px_s)-1
    delta_s(i) = sqrt((px_s(i + 1) - px_s(i))^2 + (py_s(i + 1) - py_s(i))^2);
    delta_v(i) = sqrt((0.5 * (vx_s(i) + vx_s(i + 1)))^2 + (0.5 * (vy_s(i) + vy_s(i + 1)))^2);
    delta_t(i) = delta_s(i) / delta_v(i);
    
    [Zn, xdg, ydg] = feedrate_simulator_per_segment(...
        Xca, ...
        Yca, ...
        px_s(i), px_s(i + 1), ...
        py_s(i), py_s(i + 1), ...
        vx_s(i), vx_s(i + 1), ...
        vy_s(i), vy_s(i + 1), ...
        delta_t(i), ...
        F ...
        );
    Zremoval = Zremoval + Zn;
    Zresidual = Z - Zremoval;
    Zresidual = remove_polynomials(X, Y, Zresidual, 1);
    
    %         subplot(211);
    %         surf(X*1e3, Y*1e3, Zremoval*1e9, 'EdgeColor', 'none');
    %         colormap(viridis);
    %         view([0 0 1]);
    %         axis image xy;
    %         h = colorbar;
    %         set(get(h,'title'),'string','[nm]');
    %         xlabel('[mm]');
    %         ylabel('[mm]');
    %         zlabel('[nm]');
    %         rms_removal = nanstd(Zremoval(:)*1e9, 1);
    %         title(['Removed height, RMS = ' num2str(round(rms_removal, 2)) ' nm']);
    %         set(gca,'XLim',[min_x*1e3 max_x*1e3],'YLim',[min_y*1e3 max_y*1e3])
    %         hold on;
    %
    %         plot3(1e3* (x_tif + xdg), 1e3 * (y_tif + ydg), z_tif,'-','color',[0.686 0.404 0.239],'linewidth',2);
    %         hold off;
    
    %         subplot(212);
    i_vm = 50; % fast-forward magnification of video
    if ( rem(i, i_vm) == 0) || (i == size(px_s, 1) - 1 )
        subplot('position',[0.1,0.26,0.42,0.47]);
        surf(X*1e3, Y*1e3, Zresidual*1e9, 'EdgeColor', 'none');
        view([0 0 1]);
        colormap(jet); % viridis
        axis image xy;
        h = colorbar;
        set(get(h,'title'),'string','[nm]');
        xlabel('[mm]');
        ylabel('[mm]');
        zlabel('[nm]');
        caxis([-range_z*1e9 range_z*1e9]);
        rms_residual = nanstd(Zresidual(:)*1e9, 1);
        dt_s = i / (60 * 20);
        dt_min = round(dt_s  * 100) / 100; 
        title({['Residual height, RMS = ' num2str(round(rms_residual, 2)) ' nm'];['Total dwell time=',num2str(dt_min ),'min']});
        set(gca,'XLim',[min_x*1e3 max_x*1e3],'YLim',[min_y*1e3 max_y*1e3])
        hold on;
        plot3(1e3* (x_tif + xdg), 1e3 * (y_tif + ydg), z_tif,'-','color',[0.737 0.027 0.635],'linewidth',2);
        plot3(1e3* (0.02*x_tif + xdg), 1e3 * (0.02*y_tif + ydg), 0.02*z_tif,'-','color',[0.737 0.027 0.635],'linewidth',4);%center of circle
        plot3(px_s*1e3, py_s*1e3, 1000*ones(size(px_s,1),1), 'b-', 'LineWidth', 0.2); % tool path
        hold off;

        % velocity x
        subplot('position',[0.62,0.78,0.35,0.14]);
        vx_s_mm = vx_s * 1e3; 
        plot(1:size(vx_s_mm,1),vx_s_mm,'-','color',[0.686 0.404 0.239],'linewidth',1);
        hold on; 
        plot(i,vx_s_mm(i),'r*','linewidth',3);
        hold off;
        ylabel('v [mm/s]');
        vx_s_mm(i)=round(vx_s_mm(i)*1000)/1000; 
        title(strcat('velocity x =',num2str(vx_s_mm(i)),' mm/s'));
        xlim([0,i]);

        % velocity y
        subplot('position',[0.62,0.56,0.35,0.14]);
        vy_s_mm = vy_s * 1e3;
        plot(1:size(vy_s_mm,1),vy_s_mm,'-','color',[0.294 0.545 0.749],'linewidth',1);
        hold on; 
        plot(i,vy_s_mm(i),'b*','linewidth',3);
        hold off;
        ylabel('v [mm/s]');
        vy_s_mm(i)=round(vy_s_mm(i)*1000)/1000; 
        title(strcat('velocity y =',num2str(vy_s_mm(i)),' mm/s'));
        xlim([0,i]);

         % acceleration x
        subplot('position',[0.62,0.34,0.35,0.14]);
        ax_s_mm = ax_s * 1e3; 
        plot(1:size(ax_s_mm,1),ax_s_mm,'-','color',[0.686 0.404 0.239],'linewidth',1);
        hold on; 
        plot(i,ax_s_mm(i),'r*','linewidth',3);
        hold off;
        ylabel('acc [mm/s^2]');
        ax_s_mm(i)=round(ax_s_mm(i)*1000)/1000; 
        title(strcat('acceleration x =',num2str(ax_s_mm(i)),' mm/s^2'));
        xlim([0,i]);

        % acceleration y
        subplot('position',[0.62,0.12,0.35,0.14]);
        ay_s_mm = ay_s * 1e3; 
        plot(1:size(ay_s_mm,1),ay_s_mm,'-','color',[0.294 0.545 0.749],'linewidth',1);
        hold on; 
        plot(i,ay_s_mm(i),'b*','linewidth',3);
        hold off;
        ylabel('acc [mm/s^2]');
        ay_s_mm(i)=round(ay_s_mm(i)*1000)/1000; 
        title(strcat('acceleration y =',num2str(ay_s_mm(i)),' mm/s^2'));
        xlim([0,i]);
        xlabel('Index of feed-rate points');

        set(gcf,'position',[200, 200, 720,480]);

        frame = getframe(gcf);
        frame.cdata=imresize(frame.cdata, [480 720]);
        writeVideo(writerObj,frame);
    end
end

close(writerObj);
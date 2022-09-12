clear;
close all;
clc;
addpath('../../../matlab/functions/');
% addpath('../../../Slope-based-dwell-time/matlab/functions/'); % import viridis
%% l. load data
i_vm = 1; % fast-forward magnification of video, 50
run_path = 'maze'; % 'raster', 'maze', 'rap'

data_dir = '../../../data/paper_data/';

load([data_dir 'step_02_pvt_2d_from_udo_maze_ibf.mat']);
video_name = ['pvt_sim_maze_x' int2str(i_vm) '.mp4'];

pvt_t = cs_t;
X = Xca;
Y = Yca;
Z = Zca;


%% 2. calculate the delta t
% direct assignment
tau = 1/20;

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

writerObj=VideoWriter(video_name, 'MPEG-4');%make a movie
writerObj.FrameRate = 1/tau; 
open(writerObj);

tmp_Z = remove_polynomials(X, Y, Z, 1);

range_z = 0.5 * (nanmax(tmp_Z(:)) - nanmin(tmp_Z(:)));

figure;
for i = 1: size(px_s)-1    
    [Zn, xdg, ydg] = feedrate_simulator_per_segment(...
        Xca, ...
        Yca, ...
        px_s(i), px_s(i + 1), ...
        py_s(i), py_s(i + 1), ...
        vx_s(i), vx_s(i + 1), ...
        vy_s(i), vy_s(i + 1), ...
        ts(i+1) - ts(i), ...
        F ...
        );
    Zremoval = Zremoval + Zn;
    Zresidual = Z - Zremoval;
    Zresidual = remove_polynomials(X, Y, Zresidual, 1);
    
      
    if ( rem(i, i_vm) == 0) || (i == size(px_s, 1) - 1 )
        % tool-path map
        subplot('position',[0.1,0.54,0.33,0.27]);
        plot(px_s*1e3, py_s*1e3, 'b-', 'LineWidth', 0.2); % tool path
        axis image xy;
        xlabel('[mm]');
        ylabel('[mm]');
        dt_minute = round(ts(i) / 60  * 100) / 100;
        title({['Position X = ' num2str(round(px_s(i)* 1e3, 3)) ' mm,' '  Y = ' num2str(round(py_s(i)* 1e3, 3)) ' mm'];['Total dwell time = ',num2str(dt_minute ),' min']});
        set(gca,'XLim',[min_x*1e3 max_x*1e3],'YLim',[min_y*1e3 max_y*1e3])
        hold on;
        plot3(1e3* (x_tif + xdg), 1e3 * (y_tif + ydg), z_tif,'-','color',[0.737 0.027 0.635],'linewidth',2);
        plot3(1e3* (0.02*x_tif + xdg), 1e3 * (0.02*y_tif + ydg), 0.02*z_tif,'-','color',[0.737 0.027 0.635],'linewidth',4);%center of circle
        hold off;
        
        % residual map
        subplot('position',[0.1,0.16,0.42,0.37]);
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
        dt_minute = round(ts(i) / 60  * 100) / 100;
        title({['Residual height, RMS = ' num2str(round(rms_residual, 2)) ' nm'];['Total dwell time = ',num2str(dt_minute ),' min']});
        set(gca,'XLim',[min_x*1e3 max_x*1e3],'YLim',[min_y*1e3 max_y*1e3])
        hold on;
        plot3(1e3* (x_tif + xdg), 1e3 * (y_tif + ydg), z_tif,'-','color',[0.737 0.027 0.635],'linewidth',2);
        plot3(1e3* (0.02*x_tif + xdg), 1e3 * (0.02*y_tif + ydg), 0.02*z_tif,'-','color',[0.737 0.027 0.635],'linewidth',4);%center of circle
        hold off;

        % velocity x
        subplot('position',[0.62,0.78,0.35,0.14]);
        ShowAccelerationMap(i, vx_s, [0.686 0.404 0.239], 'r*', 1e3, 'mm/s', 'Velocity x');

        % velocity y
        subplot('position',[0.62,0.56,0.35,0.14]);
        ShowAccelerationMap(i, vy_s, [0.686 0.404 0.239], 'r*', 1e3, 'mm/s', 'Velocity y');

        % acceleration x
        subplot('position',[0.62,0.34,0.35,0.14]);
        ShowAccelerationMap(i, ax_s, [0.294 0.545 0.749], 'b*', 1e3, 'mm/s^2', 'Acceleration x');
        
        % acceleration y
        subplot('position',[0.62,0.12,0.35,0.14]);
        ShowAccelerationMap(i, ay_s, [0.294 0.545 0.749], 'b*', 1e3, 'mm/s^2', 'Acceleration y');
        xlabel('Index of feed-rate points');

        set(gcf,'position',[200, 200, 720,480]);

        frame = getframe(gcf);
        frame.cdata=imresize(frame.cdata, [480 720]);
        writeVideo(writerObj,frame);
    end
end

close(writerObj);

% ShowZresidualMap(X, Y, Zresidual, color_line, color_point, 1e9, unitStr, title_str)


function ShowAccelerationMap(i, ax, color_line, color_point, unit, unitStr, title_str)

if nargin == 2
    color_line = [0.686 0.404 0.239];
    color_point = 'r*';
    unit = 1e3;
    unitStr = 'mm';
    title_str = 'Params';
end
ax_mm = ax * unit;
plot(1:size(ax_mm,1),ax_mm,'-','color',color_line,'linewidth',1);
hold on;
plot(i,ax_mm(i),color_point,'linewidth',3);
hold off;
% ylabel('acc [mm/s^2]');
ylabel([ title_str(1:3) ' [' unitStr ']' ]);
ax_mm(i)=round(ax_mm(i)*1000)/1000;
title([title_str ' = ',num2str(ax_mm(i)),' ' unitStr]);
xlim([0,i]);
end
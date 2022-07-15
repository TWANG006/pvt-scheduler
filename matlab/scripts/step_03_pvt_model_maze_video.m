clear;
% close all;
clc;
addpath(genpath('../functions'));
addpath('../../../Slope-based-dwell-time/matlab/functions/'); % import viridis
%% l. load data
% calculated pvt
data_dir = '../../data/sim_data/';
load([data_dir 'step_02_pvt_2d_from_udo.mat']);

pvt_t = cs_t;
X = Xca;
Y = Yca;
Z = Zca;

%% 2. calculate the delta t
% direct assignment
% tau = 1/20;  % ms， 1/60

fsfig('velocity map');
subplot(121);
show_pvt_v_maze(px_s, py_s, vx_s, viridis, 'Velocity X');
subplot(122);
show_pvt_v_maze(px_s, py_s, vy_s, viridis, 'Velocity Y');

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
writerObj.FrameRate = 20; %60
open(writerObj);

tmp_Z = remove_polynomials(X, Y, Z, 1);

range_z = 0.5 * (nanmax(tmp_Z(:)) - nanmin(tmp_Z(:)));

figure;
for i = 1: size(px_s)-1
    %         [Zn, xdg, ydg] = feedrate_simulator_raster_path_per_segment(...
    %             X, ...
    %             Y, ...
    %             y{m, 1}(1), ...
    %             p{m, 1}(n), p{m, 1}(n + 1), ...
    %             v{m, 1}(n), v{m, 1}(n + 1), ...
    %             F ...
    %         );
    [Zn, xdg, ydg] = feedrate_simulator_maze_path_per_segment(...
        Xca, ...
        Yca, ...
        px_s(i), px_s(i + 1), ...
        py_s(i), py_s(i + 1), ...
        vx_s(i), vx_s(i + 1), ...
        vy_s(i), vy_s(i + 1), ...
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
    surf(X*1e3, Y*1e3, Zresidual*1e9, 'EdgeColor', 'none');
    view([0 0 1]);
    colormap(viridis);
    axis image xy;
    h = colorbar;
    set(get(h,'title'),'string','[nm]');
    xlabel('[mm]');
    ylabel('[mm]');
    zlabel('[nm]');
    caxis([-range_z*1e9 range_z*1e9]);
    rms_residual = nanstd(Zresidual(:)*1e9, 1);
    title(['Residual height, RMS = ' num2str(round(rms_residual, 2)) ' nm']);
    set(gca,'XLim',[min_x*1e3 max_x*1e3],'YLim',[min_y*1e3 max_y*1e3])
    hold on;
    plot3(1e3* (x_tif + xdg), 1e3 * (y_tif + ydg), z_tif,'-','color',[0.686 0.404 0.239],'linewidth',2);
    plot3(1e3* (0.02*x_tif + xdg), 1e3 * (0.02*y_tif + ydg), 0.02*z_tif,'-','color',[0.686 0.404 0.239],'linewidth',4);%center of circle
    plot3(px_s*1e3, py_s*1e3, 1000*ones(size(px_s,1),1), 'b-', 'LineWidth', 1); % maze path
    hold off;
    
    set(gcf,'position',[200, 200, 720,480]);
    
    
    frame = getframe(gcf);
    frame.cdata=imresize(frame.cdata, [480 720]);
    writeVideo(writerObj,frame);
end

close(writerObj);
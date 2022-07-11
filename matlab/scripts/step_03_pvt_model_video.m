clear;
close all;
clc;

%% l. load data
% calculated pvt
load('step_02_pvt_model_calculation.mat');
pvt_t = t;

% tif & surface
load('step_01_multilayer_no1_data.mat');
X = Xca;
Y = Yca;
Z = Z_to_remove_ca;


%% 2. calculate the delta t
% direct assignment
tau = 1/60;  % ms

[p, v, a] = pvt_sampler_raster_path(...
    tau, ... the time interval for the sampling of caculated PVT
    p, ... positions
    pvt_t, ... times
    c  ... coefficients
);

figure;
show_pvt_v(p, y, v, viridis);


%% 3. TIF schematic
r_tif =  0.5 * (nanmax(Xtif(:)) - nanmin(Xtif(:)));
theta=0: pi/50: 2*pi;

x_tif = r_tif * cos(theta);
y_tif = r_tif * sin(theta);
z_tif = ones(size(x_tif)) * 100000;


%% 4. generate simulation videos
n_scans = length(p);

F = griddedInterpolant(...
    Xtif', ...
    (-Ytif)', ...
    flipud(Ztif)', ...
    'cubic', ...
    'none' ...
);

Zremoval = 0 * Z;

min_x = nanmin(X(:)) - r_tif;
max_x = nanmax(X(:)) + r_tif; 

min_y = nanmin(Y(:)) - r_tif;
max_y = nanmax(Y(:)) + r_tif;

writerObj=VideoWriter('pvt_sim_test.avi');%make a movie
writerObj.FrameRate = 60;
open(writerObj);

tmp_Z = remove_polynomials(X, Y, Z, 1);

range_z = 0.5 * (nanmax(tmp_Z(:)) - nanmin(tmp_Z(:)));


for m = 1: n_scans
    n_positions = length(p{m, 1});
    
    for n = 1: n_positions - 1
        [Zn, xdg, ydg] = feedrate_simulator_raster_path_per_segment(...
            X, ...
            Y, ...
            y{m, 1}(1), ...
            p{m, 1}(n), p{m, 1}(n + 1), ...
            v{m, 1}(n), v{m, 1}(n + 1), ...
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
        hold off;

        set(gcf,'position',[200, 200, 720,480]);


        frame = getframe(gcf);
        frame.cdata=imresize(frame.cdata, [480 720]);
        writeVideo(writerObj,frame);
    end
end

close(writerObj);
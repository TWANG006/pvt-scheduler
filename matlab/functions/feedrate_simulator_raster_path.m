function [Zresidual, Zremoval] = feedrate_simulator_raster_path(...
    Xsurf, ... x coordinate of the surface
    Ysurf, ... y coordinate of the surface
    Zsurf, ... heights of the surface
    Xtif, ... x coordinates of TIF
    Ytif, ... y coordinates of TIF
    Ztif, ... height of the TIF 
    p, ... feeding positions
    y, ... scanning positions
    v ... feedrates
)
%
% Simulate the PVT-based scheduling resulted material removal and estimated
% residual using the dwell time interval of `dt`
%
n_scans = length(p);  % number of scans along the sanning direction


%% 1. precompute the TIF interpolation look-up table
F = griddedInterpolant(...
    Xtif', ...
    (-Ytif)', ...
    flipud(Ztif)', ...
    'cubic', ...
    'none' ...
);


%% 2. begin the simulation
Zremoval = 0 * Zsurf;
figure;
for m = 1: n_scans
    n_positions = length(p{m, 1});
    
    for n = 1: n_positions - 1
        Zn = feedrate_simulator_raster_path_per_segment(...
            Xsurf, ...
            Ysurf, ...
            y{m, 1}(1), ...
            p{m, 1}(n), p{m, 1}(n + 1), ...
            v{m, 1}(n), v{m, 1}(n + 1), ...
            F ...
        );
    
        Zremoval = Zremoval + Zn;
    end
    
%     show_surface_map(Xsurf, Ysurf, Zremoval, 0, 'jet', 'flat', 0, 2, 1e9, 'nm', 'Removed');
%     drawnow;
end

Zresidual = Zsurf - Zremoval;


end
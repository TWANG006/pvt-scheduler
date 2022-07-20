function [Zremoval, xdg, ydg] = feedrate_simulator_raster_path_per_segment(...
    Xsurf, ...
    Ysurf, ...
    y, ...
    p0, p1, ...
    v0, v1, ...
    griddedInterpolant_obj ...
)

% get the dwell time
tn = abs(p1 - p0) / (0.5 * abs(v0 + v1));

% get the dwell point from feedrate control positions
xdg = 0.5 * (p0 + p1);
ydg = y;

% calculate the data ponts for TIF
Xk = Xsurf - xdg;
Yk = Ysurf - ydg;

Zremoval = griddedInterpolant_obj(Xk', Yk');
Zremoval = Zremoval' * tn;
Zremoval(~isfinite(Zremoval)) = 0;

end
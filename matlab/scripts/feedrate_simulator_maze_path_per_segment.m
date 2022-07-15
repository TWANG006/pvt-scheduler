function [Zremoval, xdg, ydg] = feedrate_simulator_maze_path_per_segment(...
    Xsurf, ...
    Ysurf, ...
    px0, px1, ...
    py0, py1, ...
    vx0, vx1, ...
    vy0, vy1, ...
    griddedInterpolant_obj ...
)

% get the dwell time
% tn = abs(p1 - p0) / (0.5 * abs(v0 + v1));
if abs(px0 - px1) < abs(py0 - py1)
    tn = abs(py1 - py0) / (0.5 * abs(vy0 + vy1));
end
if abs(px0 - px1) > abs(py0 - py1)
    tn = abs(px1 - px0) / (0.5 * abs(vx0 + vx1));
end

% tn = sqrt((px0 - px1)^2 + (py0 - py1)^2) / (sqrt(0.5 *(vx0 + vx1)^2 + (0.5*(vy0 + vy1))^2));

% get the dwell point from feedrate control positions
if abs(px0 - px1) < abs(py0 - py1)
    xdg = px0;
    ydg = 0.5 * (py0 + py1);
end
if abs(px0 - px1) > abs(py0 - py1)
    xdg = 0.5 * (px0 + px1);
    ydg = py0;
end

% xdg = 0.5 * (px0 + px1);
% ydg = 0.5 * (py0 + py1);

% calculate the data ponts for TIF
Xk = Xsurf - xdg;
Yk = Ysurf - ydg;

Zremoval = griddedInterpolant_obj(Xk', Yk');
Zremoval = Zremoval' * tn;
Zremoval(~isfinite(Zremoval)) = 0;

end
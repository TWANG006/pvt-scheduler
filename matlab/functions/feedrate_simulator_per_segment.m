function [Zremoval, xdg, ydg] = feedrate_simulator_per_segment(...
    Xsurf, ...
    Ysurf, ...
    px0, px1, ...
    py0, py1, ...
    vx0, vx1, ...
    vy0, vy1, ...
    t, ...
    griddedInterpolant_obj ...
)

% get the dwell time
% if abs(px0 - px1) < abs(py0 - py1)
%     tn = abs(py1 - py0) / (0.5 * abs(vy0 + vy1));
% end
% if abs(px0 - px1) > abs(py0 - py1)
%     tn = abs(px1 - px0) / (0.5 * abs(vx0 + vx1));
% end
tn = t;

xdg = 0.5 * (px0 + px1);
ydg = 0.5 * (py0 + py1);

% calculate the data ponts for TIF
Xk = Xsurf - xdg;
Yk = Ysurf - ydg;

Zremoval = griddedInterpolant_obj(Xk', Yk');
Zremoval = Zremoval' * tn;
Zremoval(~isfinite(Zremoval)) = 0;

end
function show_dwell_time(x, y, t, is2d, color_range, colorMap, titleStr)
% Purpose:
%   Display the dwell time map defiend by x, y, and t with title
%
% Inputs:
%        X, Y: meshgrid points of the surface map [m]
%           Z: the surface map [m]
%   title_str: the title string
%
% Info:
%   Contact: tianyiwang666@gmail.com (Dr WANG Tianyi)
%   Copyright reserved.

ratio = (max(x(:)) - min(x(:))) / (max(y(:)) - min(y(:)));

if is2d == false
    % change to mm and nm units
    xmm = x(:)*1e3;
    ymm = y(:)*1e3;
    t = t(:);
    
    % display the map
    scatter3(xmm, ymm, t, 18, t);
else
    surf(x*1e3, y*1e3, t, 'EdgeColor', 'none');
end
view([0 90]);
axis xy tight;
shading interp;

if color_range > 0
    caxis([-1, 1]*color_range*nanstd(t(:),1));
end
colormap(colorMap);
c = colorbar;
c.Label.String = 's';

title({titleStr ...
    [' Total dwell time = ' num2str(round(sum(t(:)) / 60, 2)) ' min']},...
    'FontWeight', 'normal',...
    'FontSize', 12);

xlabel('x [mm]', 'FontSize', 12);
ylabel('y [mm]', 'FontSize', 12);
pbaspect([ratio, 1, 1]);


end
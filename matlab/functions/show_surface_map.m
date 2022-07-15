function show_surface_map(...
    X, ...
    Y, ...
    Z, ...
    color_range, ...
    color_map, ...
    shade, ...
    is_removed, ...
    round_n, ...
    unit, ...
    unit_str, ...
    title_str ...
)
%-------------------------------------------------------------------------%
%
% Purpose:
%   Display the surface map defiend by X, Y, and Z with title
%
% Inputs:
%        X, Y: meshgrid points of the surface map [m]
%           Z: the surface map [m]
%   title_str: the title string
%
% Info:
%   Contact: tianyiwang666@gmail.com (Dr WANG Tianyi)
%   Copyright reserved.
%-------------------------------------------------------------------------%

if nargin == 3
    color_range = 0;
    is_removed = false;
    unit = 1e9;
    unit_str = 'nm';
    title_str = 'Surf';
end

% change to mm and nm units
X_mm = X*1e3;
Y_mm = Y*1e3;
Z_nm = Z*unit;
ratio = (max(X(:)) - min(X(:))) / (max(Y(:)) - min(Y(:)));

if (is_removed == true)
    Z_nm = remove_surface_1st_order(X_mm, Y_mm, Z_nm);
end

% display the map
surf(X_mm, Y_mm, Z_nm, 'EdgeColor', 'none');
view([0 90]);
% axis xy image; 
axis xy tight;
c = colorbar;
c.Label.String = unit_str;
if color_range > 0
    caxis([-1, 1]*color_range);
end
title({title_str,...
      [' PV = ' num2str(round(SmartPTV(Z_nm(:)), round_n)) ' ' unit_str ', RMS = ' num2str(round(nanstd(Z_nm(:),1), round_n)) ' ' unit_str]},...
    'FontWeight', 'normal',...
    'FontSize', 12 ...
);
xlabel('x [mm]', 'FontSize', 12);
ylabel('y [mm]', 'FontSize', 12);
colormap(gca, color_map);
shading(gca, shade);
pbaspect([ratio, 1, 1]);

end
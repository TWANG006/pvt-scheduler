function h = ShowSurfaceMap(X, Y, Z, color_range, isRemoved, unit, unitStr, title_str)
% Function:
%   ShowSurfaceMap(X, Y, Z, title_str)
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

if nargin == 3
    color_range = 0;
    isRemoved = false;
    unit = 1e9;
    unitStr = 'nm';
    title_str = 'Surf';
end


if (isRemoved == true)
    Z = RemoveSurface1(X, Y, Z);
end

X_mm = X*1e3;
Y_mm = Y*1e3;
Z_nm = Z*unit;
ratio = (max(X(:)) - min(X(:))) / (max(Y(:)) - min(Y(:)));

% display the map
%1.show in pcolor.
surf(X_mm, Y_mm, Z_nm, 'EdgeColor', 'none');
% h.EdgeColor = 'none';
view([0 90]);
% axis xy image; 
axis xy tight;

% %2.show in surf.
% surf(X_mm, Y_mm, Z_nm, 'EdgeColor', 'none');
% view([0 90]);
% % axis xy equal;
% grid off;

c = colorbar;
c.Label.String = ['Height ' unitStr];
if color_range > 0
    caxis([-1, 1]*color_range*nanstd(Z_nm(:),1));
end
title({title_str,...
      [' PV = ' num2str(round(SmartPTV(Z_nm(:)), 2)) ' ' unitStr ...
       ', RMS = ' num2str(round(nanstd(Z_nm(:),1), 2)) ' ' unitStr]},...
    'FontWeight', 'normal');
xlabel('x [mm]');
ylabel('y [mm]');
colormap jet;
shading('interp');
pbaspect([ratio, 1, 1]);


end
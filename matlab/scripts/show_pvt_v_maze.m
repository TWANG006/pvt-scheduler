function show_pvt_v_maze(p, y, v, cmap, titleStr)

n_scans = length(p);

% pmm = [];
% smm = [];
% vmm = [];
%
% for i = 1: size(p)
%     pmm = [pmm; 1e3 * p{i, 1}(:)];
%     vmm = [vmm; 1e3 * v{i, 1}(:)];
%     smm = [smm; 1e3 * y{i, 1}(1) * ones(length(p{i, 1}), 1)];
% end

pmm = p * 1e3;
smm = y * 1e3;
vmm = v * 1e3;

scatter3(pmm, smm, abs(vmm), 18, abs(vmm));
view([0 90]);
axis xy image;
colormap(cmap);
c = colorbar;
c.Label.String = 'mm/s';
title({titleStr ...
    ['Max feed = ' num2str(round(nanmax(abs(vmm)), 2)) ' mm/s, ' 'Min feed = ' num2str(round(nanmin(abs(vmm)), 2)) ' mm/s']},...
    'FontWeight', 'normal',...
    'FontSize', 12);
xlabel('x [mm]', 'FontSize', 12);
ylabel('y [mm]', 'FontSize', 12);

end
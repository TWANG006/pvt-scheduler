function show_pvt_v(p, y, v, cmap)

n_scans = length(p);

pmm = [];
smm = [];
vmm = [];

for i = 1: n_scans
    pmm = [pmm; 1e3 * p{i, 1}(:)];
    vmm = [vmm; 1e3 * v{i, 1}(:)];
    smm = [smm; 1e3 * y{i, 1}(1) * ones(length(p{i, 1}), 1)];    
end

scatter3(pmm, smm, abs(vmm), 18, abs(vmm));
view([0 90]);
axis xy image; 
colormap(cmap);
c = colorbar;
c.Label.String = 'mm/s';
title(['Max feed = ' num2str(round(nanmax(abs(vmm)), 2)) ' mm/s, ' 'Min feed = ' num2str(round(nanmin(abs(vmm)), 2)) ' mm/s'],...
    'FontWeight', 'normal',...
    'FontSize', 12);
xlabel('x [mm]', 'FontSize', 12);
ylabel('y [mm]', 'FontSize', 12);

end
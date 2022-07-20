function show_pvt(x, y, t, p, v, cmap)

n_scans = length(p);

xmm = [];
ymm = [];

pmm = [];
smm = [];
vmm = [];
ts = [];

for i = 1: n_scans
    xmm = [xmm; 1e3 * x{i, 1}(:)];
    ymm = [ymm; 1e3 * y{i, 1}(:)];
    ts = [ts; t{i, 1}(:)];
    
    pmm = [pmm; 1e3 * p{i, 1}(:)];
    vmm = [vmm; 1e3 * v{i, 1}(:)];
    smm = [smm; 1e3 * y{i, 1}(1) * ones(length(p{i, 1}), 1)];    
end


figure;
subplot(2, 1, 1);
scatter3(xmm, ymm, ts, 18, ts);
view([0 90]);
axis xy image; 
colormap(cmap);
c = colorbar;
c.Label.String = 's';
title(['Total dwell time = ' num2str(round(sum(ts(:))/60, 2)) ' min'],...
    'FontWeight', 'normal',...
    'FontSize', 12);
xlabel('x [mm]', 'FontSize', 12);
ylabel('y [mm]', 'FontSize', 12);

subplot(2, 1, 2);
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
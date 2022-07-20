function show_pvt_t(x, y, t, cmap)

n_scans = length(t);

xmm = [];
ymm = [];
ts = [];

for i = 1: n_scans
    xmm = [xmm; 1e3 * x{i, 1}(:)];
    ymm = [ymm; 1e3 * y{i, 1}(:)];
    ts = [ts; t{i, 1}(:)];
end


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

end
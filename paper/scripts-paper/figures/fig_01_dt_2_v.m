clear;
close all;
clc;

load([mfilename '_old.mat']);

%% plot v & dt points
figure;
p1 = plot(px, py, 'b*', 'LineWidth', 1.5, 'MarkerSize', 4); hold on;
p2 = plot(xp, yp, 'ro', 'LineWidth', 1.5,  'MarkerSize', 4); hold on;
% p3 = plot(px, py, 'b-', 'LineWidth', 1.5); hold on;
view(0, 90);
title([]);

s = pcolor(Xca, Yca, Zca); 
s.EdgeColor = 'none';
view(0, 90);
colormap jet;
hold on;


alpha(s, 0.7);
alpha(p1, 0.5);
alpha(p2, 0.5);

% legend('', 'Velocity control points', 'Dwell points');
set(gca, 'xtick', []);
set(gca, 'ytick', []);
set(gca, 'FontSize', 20);
grid off;
box off;
axis off;
axis equal;


%% plot dwell time
figure;
scatter3(xp, yp, t, 105, t, 'filled');
view(0, 90);
axis equal;
grid off;
box off;
axis off;
set(gca, 'xticklabel', [], 'xlabel', [], 'xtick', []);
set(gca, 'yticklabel', [], 'ylabel', [], 'ytick', []);
set(gca, 'FontSize', 20);


%% plot feedrates
figure;
scatter3(px, py, sqrt(vx.^2 + vy.^2), 105, sqrt(vx.^2 + vy.^2), 'filled');
view(0, 90);
axis equal;
grid off;
box off;
axis off;
set(gca, 'xticklabel', [], 'xlabel', [], 'xtick', []);
set(gca, 'yticklabel', [], 'ylabel', [], 'ytick', []);
set(gca, 'FontSize', 20);

figure;
subplot(2,1,1);
plot(cs_t, vx, 'b-');
set(gca, 'xticklabel', [], 'xtick', []);
set(gca, 'yticklabel', [], 'ytick', []);
title('{\it x} velocities');
axis tight;
set(gca, 'FontSize', 20);
subplot(2,1,2);
plot(cs_t, vy, 'r-'); hold off;
set(gca, 'xticklabel', [], 'xtick', []);
set(gca, 'yticklabel', [], 'ytick', []);
axis tight;
title('{\it y} velocities');
set(gca, 'FontSize', 20);


%% sampler
figure;
plot(px_s, py_s, 'b-', 'LineWidth', 2);
axis equal;
grid off;
box off;
axis off;


%% estimator
figure;
ShowSurfaceMap(Xca, Yca, Zresidual_ca, 3, true, 1e9, 'nm', '');
set(gca, 'xticklabel', [], 'xtick', [], 'xlabel', []);
set(gca, 'yticklabel', [], 'ytick', [], 'ylabel', []);
set(gca, 'title', []);
colorbar off;
axis tight;
set(gca, 'FontSize', 20);
hold on; plot3(px_s*1e3, py_s*1e3, 100*ones(size(px_s,1),1), 'b-', 'LineWidth', 1); hold off;
axis off;
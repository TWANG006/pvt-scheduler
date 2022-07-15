clear;
close all;
clc;

nx = 10;
ny = 5;

xmin = -1;
xmax = 8;

ymin = -1;
ymax = 3;

dx = (xmax - xmin) / (nx - 1);
dy = (ymax - ymin) / (ny - 1);

[X, Y] = meshgrid(xmin: dx: xmax, ymin: dy: ymax);
Z = X.*Y + 2 * X + 3 * Y;

F = griddedInterpolant(X', Y', Z', 'cubic', 'none');

F(1.5, 2.2)
F(2.1, 2.3)

% figure;
% surf(X, Y, Z, 'EdgeColor', 'none');
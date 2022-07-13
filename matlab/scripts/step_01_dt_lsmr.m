clear;
% close all;
clc;
addpath('../../../5-functions/');

%% load data
data_dir = '../../data/sim_data/';
data_file = 'step_00_rect_tif1_rect_60mm_tif_10mm.mat';
load([data_dir data_file]);

xp = xp1;
yp = yp1;
Xtif = Xtif1;
Ytif = Ytif1;
Ztif = Ztif1;

precision = 1e-3;
precision_unit = 'nm';
min_t = 10e-2;

%% Define the CA range
% r_tif = size(Xtif, 2) * median(diff(Xtif(1, :))) * 0.5;
% ca_range = ((min(X(:)) + r_tif) <= X) & (X <= (max(X(:)) - r_tif)) & ((min(Y(:)) + r_tif) <= Y) & (Y <= (max(Y(:)) - r_tif));

xc = 0.5 * (max(X(:)) + min(X(:)));
yc = 0.5 * (max(Y(:)) + min(Y(:)));
ca_range = ((xc - 6e-3) <= X) & (X <= (xc + 6e-3)) & ((yc - 6e-3) <= Y) & (Y <= (yc + 6e-3));

Z_to_remove_ca = Z;
Z_to_remove_ca(~ca_range) = NaN;

Xca = X;
Yca = Y;
Xca(~ca_range) = NaN;
Yca(~ca_range) = NaN;

% delete the rows and columns which are all NaN
Xca(all(isnan(Xca)'),:) = [];%Delete rows that are all NaN
Xca(:,all(isnan(Xca))) = [];%Delete columns that are all NaN
Yca(all(isnan(Yca)'),:) = [];
Yca(:,all(isnan(Yca))) = [];
Z_to_remove_ca(all(isnan(Z_to_remove_ca)'),:) = [];
Z_to_remove_ca(:,all(isnan(Z_to_remove_ca))) = [];

%% TIF 1
[t, Zremoval_ca, Zresidual_ca, ~] = DwellTime2D_LSMR(...
    Xca, ...
    Yca, ...
    Z_to_remove_ca,...
    Xtif, ...
    Ytif, ...
    Ztif, ...
    [], ...
    'avg', ...
    xp, ...
    yp, ...
    min_t, ...
    precision, ...
    precision_unit ...
    );


%% display
figure;
subplot(131);
ShowSurfaceMap(X, Y, Z, 3, true, 1e9, 'nm', 'initial map');
subplot(132);
ShowSurfaceMap(Xca, Yca, Zremoval_ca, 3, true, 1e9, 'nm', 'Zremoval');
subplot(133);
ShowSurfaceMap(Xca, Yca, Zresidual_ca, 3, true, 1e9, 'nm', 'Zresidual');

%% save data
save([data_dir mfilename '.mat'], ...
    'X', 'Y', 'Z', ...
    'Xca', 'Yca', 'Z_to_remove_ca',  ...
    'Zremoval_ca', ...
    'Zresidual_ca',  ...
    'xp',  ...
    'yp',  ...
    't', ...
    'Xtif', 'Ytif', 'Ztif'...
    );
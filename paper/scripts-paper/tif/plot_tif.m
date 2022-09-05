clear;
% close all;
clc;

addpath('../../../functions/');

%% dirs and files
% initial surface error dir
surfDir = '../../../data/';
surfFile = 'step_01_multilayer_no1_data.mat';
tifFile = 'step_01_tif_5.0mm_20210604.mat';

%% TIF params
load([surfDir tifFile]);
tifParams.A = aOpt;
tifParams.tif_mpp = tifMpp;
tifParams.sigma_xy = sigmaOpt;
tifParams.mu_xy = muOpt;

% radius of tif
r = 0.5 * (max(Xtif(:)) - min(Xtif(:))); 
r = round(r * 10000) / 10000;

% display
fsfig('');
ShowSurfaceMap(Xtif, Ytif, Ztif);
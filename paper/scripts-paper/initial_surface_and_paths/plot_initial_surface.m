clear;
% close all;
clc;

addpath('../../../matlab/functions/');

%% dirs and files
% initial surface error dir
surfDir = '../../../data/';
surfFile = 'step_01_multilayer_no1_data.mat';
tifFile = 'step_01_tif_5.0mm_20210604.mat';

outDir = '../../../data/paper_data/';

%% clean initial surface map
load([surfDir surfFile]);
Zca = Z_to_remove_ca;

% display the initial surf
fsfig('');
ShowSurfaceMap(Xca, Yca, Zca);
%Pressed-lap

close all;
clear;clc;    
    
TD=90;%108
OSR=15;%6
nargin=5;%?
K=1;
PSI=1;
TV=1;

    
if nargin < 6
    res = 0.1; %mm/px
end

TR=TD/2;

D_TIF = TD + OSR*2;

N = round(D_TIF/res);

if mod(N, 2) == 0
    N = N + 1;        
end

x_TIF = linspace(-D_TIF/2,D_TIF/2, N);
y_TIF = x_TIF;

[X_TIF,Y_TIF] = meshgrid(x_TIF,-1*y_TIF');

[~, R] = cart2pol(X_TIF, Y_TIF);

TIF = R*0;

TIF( (R >= (TR - OSR)) & ( R <= (TR + OSR)) ) = ...
    K*PSI*TV*OSR/60 * ( 2*acos( (R( (R >= (TR - OSR)) & ...
    ( R <= (TR + OSR)) ).^2 + OSR^2 - TR^2)./(2*R( (R >= (TR - OSR)) & ...
    ( R <= (TR + OSR)) )*OSR) ) );
TIF( R < (TR - OSR) ) = K*PSI*TV*OSR*2*pi/60;
TIF( R > (TR + OSR) ) = 0;

TIF = -0.6*TIF/1e2;%nm/[psi(mm/sec)sec]
max_TIF=-min(min(TIF));
MRR1=TIF;
mesh(MRR1);
title(strcat('Removal rate=',num2str(max_TIF),'nm/[psi(mm/sec)sec]'));
% set(gca,'xtick',-inf:inf:inf);
% set(gca,'ytick',-inf:inf:inf);
% set(gca,'ztick',-inf:inf:inf);

% MRR1=imresize(MRR1,[49,49]);%change the size of TIF
% mesh(MRR1);
% 
% CX=-24:1:24;
% CY=MRR1(25,:);
% plot(CX,CY,'r-','LineWidth',3);
function [Xext, Yext, Zext, caRange] = surface_extension_rectangular_polyfit(...
    X, Y, Z,...unextended surface error map
    tifMpp,...TIF sampling interval [m/pxl]
    Ztif,...TIF profile
    orderM, orderN,...polynomial orders in y, x
    type,...Chebyshev or Legendre
    B,... boundary condition matrix
    W... weight matrix
    )
% Function
%   [X_ext, Y_ext, Z_ext] = Surface_Extension_Polyfit(X, Y, Z,...
%                           X_tif, Y_tif, Z_tif, order_m, order_n, type)
% Purpose
%   Extend the surface error map using polynomial fitting

%% 0. Obtain required parameters
% Sampling intervals
surfMpp = median(diff(X(1, :)));  % surface sampling interval [m/pxl]
    
m = size(Z, 1);  % CA height [pixel]
n = size(Z, 2);  % CA width [pixel]
    
mext = floor(tifMpp*(size(Ztif, 1))*0.5/surfMpp);  % ext size in y [pixel]
next = floor(tifMpp*(size(Ztif, 2))*0.5/surfMpp);  % ext size in x [pixel]
    
% y start & end ids of CA in FA [pixel]
caRange.vs = mext + 1;   
caRange.ve = caRange.vs + m - 1;  

% x start & end ids of CA in FA [pixel]
caRange.us = next + 1;   
caRange.ue = caRange.us + n - 1;   
    

%% 1. Initial extension matrices
% extension sizes
[Xext, Yext] = meshgrid(-next: n-1+next, -mext: m-1+mext);  %extension grid
Yext = m - 1 - Yext;
Xext = Xext*surfMpp + X(1, 1);  % adjust X grid add X(1,1)
Yext = Yext*surfMpp + Y(end, end);  % adjust Y grid add Y(1,1)
Zext = NaN(size(Xext));   % mark the Z_ext to NaN
Zext(caRange.vs: caRange.ve, caRange.us: caRange.ue) = Z;  % fill in the valid data point
    
%% Fit the edge values
% zero boundary contidion
if nargin==8
    w = 10;
    Zext(:, 1) = 0;
    Zext(1, :) = 0;
    Zext(:, end) = 0;
    Zext(end, :) = 0;
    
    W = ones(size(Zext));
    W(:, 1) = w;
    W(1, :) = w;
    W(:, end) = w;
    W(end, :) = w;
else
    Zext(:, 1) = B(:, 1);
    Zext(1, :) = B(1, :);
    Zext(:, end) = B(:, end);
    Zext(end, :) = B(end, :);
end

%% 2. poly fit
[p, q] = meshgrid(0:orderN, 0:orderM);
X_nor = -1 + 2.*(Xext - min(Xext(:)))./(max(Xext(:)) - min(Xext(:)));
Y_nor = -1 + 2.*(Yext - min(Yext(:)))./(max(Yext(:)) - min(Yext(:)));

if(strcmp(type,'Chebyshev'))
    [z3, ~, ~] = ChebyshevXYnm(X_nor, Y_nor, p(:), q(:));
elseif(strcmp(type,'Legendre'))
    [z3, ~, ~] = LegendreXYnm(X_nor, Y_nor, p(:), q(:));
else
    error('Unkown polynomial type.');
end

z3_res = reshape(z3, [],size(z3,3));

A = z3_res(~isnan(Zext(:)),:);
b = Zext(~isnan(Zext(:)));

c = lscov(A,b, W(~isnan(Zext(:))));

for i = 1:length(c)
    z3(:, :, i) = z3(:, :, i)*c(i);
end

Zext = sum(z3,3);

end
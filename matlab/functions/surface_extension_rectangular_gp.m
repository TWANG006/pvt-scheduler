function [Xext, Yext, Zext, caRange] = surface_extension_rectangular_gp(...
    X, Y, Z,...unextended surface error map
    tifMpp,...TIF sampling interval [m/pxl]
    Ztif,...TIF profile
    fxRange,...
    fyRange...
    )
% Info:
%   Contact: tianyiwang666@gmail.com (Dr WANG Tianyi)
%   Copyright reserved.
%--------------------------------------------------------------------------


%% 0. Obtain required parameters
% Sampling intervals
surfMpp = median(diff(X(1,:)));    % surface sampling interval [m/pxl]

m = size(Z,1);  % CA height [pixel]
n = size(Z,2);  % CA width [pixel]

m_ext = floor(tifMpp*(size(Ztif, 1))*0.5/surfMpp);   % ext size in y [pixel]
n_ext = floor(tifMpp*(size(Ztif, 2))*0.5/surfMpp);   % ext size in x [pixel] 

% y start & end ids of CA in FA [pixel]
caRange.vs = m_ext + 1;   
caRange.ve = caRange.vs + m - 1;   

% x start & end ids of CA in FA [pixel]
caRange.us = n_ext + 1;   
caRange.ue = caRange.us + n - 1;  


%% 1. Initial extension matrices
% extension sizes
[Xext, Yext] = meshgrid(-n_ext: n-1+n_ext, -m_ext: m-1+m_ext);  % extension grid
Yext = m - 1 - Yext;
Xext = Xext*surfMpp + X(1, 1);  % adjust X grid add X(1,1)
Yext = Yext*surfMpp + Y(end, end);  % adjust Y grid add Y(1,1)

Zext = zeros(size(Xext));   % mark the Z_ext to NaN
Zext(caRange.vs: caRange.ve, caRange.us: caRange.ue) = Z;  % fill in the valid data point

G = 8*Zext; Gy = G;
G(caRange.vs: caRange.ve, caRange.us: caRange.ue) = 1;  % fill in the valid data point
Gy(caRange.vs: caRange.ve,:) = 1;
Gox = 0*Zext;
Goy = 0*Zext;
Gox(:, fix(size(Zext,2)/2)+1+fxRange)=1;
Goy(fix(size(Zext,1)/2)+1+fyRange, :)=1;

Zext = surfaceExtension_gerchberg_papoulis(Zext, G, Gy, Gox, Goy);

end

function uk = surfaceExtension_gerchberg_papoulis(...
    u0, ...initial extended signal
    G, ...spatial gate function
    Gy, ...spatial gate function in y direction only
    Gox, ...frequency-domain gate function in horizontal direction
    Goy, ...frequency-domain gate function in vertical direction
    rmsThrd,...the rms threshold between each two consecutive iterations
    maxIter...max number of iterations
    )
% Function to perform the improved 2D Gerchberg-Papoulis bandlimited
% surface extrapolation algorithm. 
%
% Refrence:
%   Marks, R. J. (1981). Gerchberg’s extrapolation algorithm in two 
%   dimensions. Applied optics, 20(10), 1815-1820. 

%% Initialization
if nargin == 5
    rmsThrd = 1e-9;
    maxIter = 500;
end
if nargin == 6
    maxIter = 500;
end

u_pre = u0.*G; v_pre = u_pre; w_pre = u_pre;

%% Iterative update
i=1;
while i <= maxIter
    wk = (1-G).*ifft(ifftshift(Gox.*fftshift(fft(w_pre, [], 2), 2), 2), [], 2);
    vk = (1-Gy).*ifft(ifftshift(Goy.*fftshift(fft(v_pre, [], 1), 1), 1), [], 1) + wk;
    uk = u_pre + vk;
    
    % Early stop when the rms difference is satisfied 
    if(nanstd(uk(:) - u_pre(:), 1) <= rmsThrd)
        break;
    end
   
    u_pre = uk;
    v_pre = vk;
    w_pre = wk;
    i=i+1;
end

end
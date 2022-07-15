function [Xext, Yext, Zext, caRange] = surface_extension_rectangular_8nn(...
    X, Y, Z,...unextended surface error map
    tifMpp,...TIF sampling interval [m/pxl]
    Ztif...TIF profile
    )
% Purpose
%   Extend the surface error map using 8 nearest neighbors
% Info:
%   Contact: tianyiwang666@gmail.com (Dr WANG Tianyi)
%   Copyright reserved.
%--------------------------------------------------------------------------

%% 0. Obtain required parameters
% Sampling intervals
surfMpp = median(diff(X(1,:)));    % surface sampling interval [m/pxl]

m = size(Z,1);  % CA height [pixel]
n = size(Z,2);  % CA width [pixel]

mext = floor(tifMpp*(size(Ztif, 1))*0.5/surfMpp);   % ext size in y [pixel]
next = floor(tifMpp*(size(Ztif, 2))*0.5/surfMpp);   % ext size in x [pixel] 

% y start & end ids of CA in FA [pixel]
caRange.vs = mext + 1;   
caRange.ve = caRange.vs + m - 1;   

% x start & end ids of CA in FA [pixel]
caRange.us = next + 1;   
caRange.ue = caRange.us + n - 1;   


%% 1. Initial extension matrices
[Xext, Yext] = meshgrid(-next: n-1+next, -mext: m-1+mext);  ...extension grid
Yext = m - 1 - Yext;
Xext = Xext*surfMpp + X(1, 1);  ... adjust X grid add X(1,1)
Yext = Yext*surfMpp + Y(end, end);  ... adjust Y grid add Y(1,1)

Zext = NaN(size(Xext));   ... mark the Z_ext to NaN
Zext(caRange.vs: caRange.ve, caRange.us: caRange.ue) = Z;... fill in the valid data points
BW_ini = ~isnan(Zext);   ... obtain the black&white map
BW_prev = BW_ini;
% BW_all=0;
h = size(Zext, 1);
w = size(Zext, 2);

%% 2. Filling the invalid points
r = 1;  ... extension radius (1 ~ max(m_ext, n_ext))
while(r <= max(mext, next))

[u,v] = meshgrid(-2*r:2*r,-2*r:2*r);
[~, rr] = cart2pol(u,v);
se = rr<= 2*r;

BW_curr = imdilate(BW_ini, se);
BW_fill = BW_curr - BW_prev;
[idy, idx] = find(BW_fill==1);

while(~isempty(idy))
    % 8-neighbor averaging
    for k = 1:length(idy)        
        count = 0;
        nn_sum = 0;

        for i = -1:1
            for j = -1:1
                if (~(i==0 && j==0))                    
                    idi = idy(k)+i;    ... neighbor y id
                    idj = idx(k)+j;    ... neighbor x id
                    
                    if (0<idi && idi<=h && 0<idj && idj<=w && ~isnan(Zext(idi, idj)))
                        count = count+1;
                        nn_sum = nn_sum + Zext(idi, idj);
                    end
                end
            end
        end

        if (count >=3)
            Zext(idy(k), idx(k)) = nn_sum/count;
            BW_fill(idy(k), idx(k)) = 0;
        end

    end
    [idy, idx] = find(BW_fill==1);
end

BW_prev = BW_curr;
r = r + 1;

end

Zext(isnan(Zext)) = 0;

end
    
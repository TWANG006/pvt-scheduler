function [Zres,Zf,f] = remove_polynomials(X, Y, Z, p)
% Purpose:
%   This function removes the n-th order polynomial from the input surface 
%   Z and returns the coefficients
%
% Inputs:
%   X: X meshgrid coordinates [m]
%   Y: Y meshgrid coordinates [m]
%   Z: Height error map [m]
%   p: highest power of the polynomials
%
% Outputs:
%   Z: Surface error map after removing tip and tilt
%   Zf: Fitted surface error map 
%   f: the fitting coefficients
%
% Info:
%   Contact: tianyiwang666@gmail.com (Dr WANG Tianyi)
%   Copyright reserved.
%--------------------------------------------------------------------------

% valid data only
idx = isfinite( Z(:) );
z = Z(idx);
x = X(idx);
y = Y(idx);
H = ones(length(z), (p+1)*(p+2)/2);

% build the matrix
k = 0;
for s = 0: p
    for a = s: -1: 0
        b = s - a;
        H(:, k+1) = x.^a.*y.^b;
        k = k + 1;
    end
end

% H = [ones(size(x)), ...
%     x, y, ...
%     ];


% least squares method
f = double(H)\double(z);


% fitting
Zf = 0;
k = 0;
for s = 0: p
    for a = s: -1: 0
        b = s - a;
        Zf = Zf + f(k+1).*X.^a.*Y.^b;
        k = k + 1;
    end
end
% Zf = f(1) ...
%     + f(2)*X + f(3)*Y ...
%     ;

% residual
Zres = Z - Zf; 

end

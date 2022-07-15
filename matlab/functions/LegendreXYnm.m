function [z3, zx3, zy3] = LegendreXYnm(X, Y, n, m)
%LEGENDREXYNM Legendre polynominals in normalized X and Y coordinates 
%   with order vectors (n, m).

%   Copyright since 2020 by Lei Huang. All Rights Reserved.
%   E-mail: huanglei0114@gmail.com
%   2020-01-17 Original Version

% Get the 1D Legendre polynominal and its derivative.......................
[um,~,ind_um] = unique(m);
[un,~,ind_un] = unique(n);

if nargout == 1
    
    Lum = LegendreP1(Y,um);
    Lun = LegendreP1(X,un); 
    
    Lm = Lum(:,:,ind_um);
    Ln = Lun(:,:,ind_un);

    % Convert 1D to 2D polynominals with considering the derivatives.
    z3 = Ln.*Lm;

else
    
    [Lum, Lumy] = LegendreP1(Y,um);
    [Lun, Lunx] = LegendreP1(X,un); 
    
    Lm = Lum(:,:,ind_um);
    Ln = Lun(:,:,ind_un);
    Lmy = Lumy(:,:,ind_um);
    Lnx = Lunx(:,:,ind_un);

    % Convert 1D to 2D polynominals with considering the derivatives.
    z3 = Ln.*Lm;
    zx3 = Lnx.*Lm;
    zy3 = Ln.*Lmy;
end



end


% Subfunction..............................................................
% Get the 1D Legendre polynominal and its derivative.
function [L, Lx] = LegendreP1(X, n)

NUM = length(n);

if nargout == 1
    L = zeros(size(X,1),size(X,2),NUM);
    
    % Calcualte the highest order, becuase anyway we will calculate all the
    % lower orders due to the recursive calculation. 
    n_max = max(n);
    [Lnmax, Lps] = LegendrePolynominal(X, n_max);
    
    for num = 1:NUM
        if n(num)==n_max
            L(:,:,num) = Lnmax; % Legendre polynomial
        else
            L(:,:,num) = Lps(:,:,n(num)+1); % Legendre polynomial
        end
    end
    
else
    
    L = zeros(size(X,1),size(X,2),NUM);
    Lx = zeros(size(X,1),size(X,2),NUM);

    % Calcualte the highest order, becuase anyway we will calculate all the
    % lower orders due to the recursive calculation. 
    n_max = max(n);
    [Lnmax, Lps] = LegendrePolynominal(X, n_max);
    [Lxnmax, Lxps] = dLdx(X, n_max);

    for num = 1:NUM
        if n(num)==n_max
            L(:,:,num) = Lnmax; % Legendre polynomial
            Lx(:,:,num) = Lxnmax; % Derivative dL/dx
        else
            L(:,:,num) = Lps(:,:,n(num)+1); % Legendre polynomial
            Lx(:,:,num) = Lxps(:,:,n(num)+1); % Derivative dL/dx
        end
    end
end

end


% Subfunction..............................................................
% Get the 1D Legendre polynominal.
function [L, Lps] = LegendrePolynominal(x, n)
    if n==0
        L = ones(size(x));
        Lps = zeros(size(x)); % previous orders
    elseif n==1
        L = x;
        Lps = ones(size(x)); % previous orders
    else
        [Lnm1, Lps] = LegendrePolynominal(x, n-1);
        Lnm2 = Lps(:,:,end);
        L = (2.*n-1)./n.*x.*Lnm1 - (n-1)./n.*Lnm2; % current order
        Lps = cat(3, Lps, Lnm1); % previous orders
    end
end


% Get the 1D Legendre polynominal derivative.
function [Lx, Lxps] = dLdx(x, n)
    if n==0
        Lx = zeros(size(x));
        Lxps = zeros(size(x)); % previous orders
    elseif n==1
        Lx = ones(size(x));
        Lxps = zeros(size(x)); % previous orders
    else
        Lnm1 = LegendrePolynominal(x, n-1);        
        [Lxnm1, Lxps] = dLdx(x, n-1);
        Lxnm2 = Lxps(:,:,end);
        Lx = (2.*n-1)./n.*Lnm1 + (2.*n-1)./n.*x.*Lxnm1 - (n-1)./n.*Lxnm2; % current order
        Lxps = cat(3, Lxps, Lxnm1); % previous orders
    end
end

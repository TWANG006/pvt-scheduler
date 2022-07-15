function [z3, zx3, zy3] = ChebyshevXYnm(X, Y, n, m)
%CHEBYSHEVXYNM Chebyshev polynominals in normalized X and Y coordinates 
%   with order vectors (n, m).

%   Copyright since 2016 by Lei Huang. All Rights Reserved.
%   E-mail: huanglei0114@gmail.com
%   2016-11-02 Original Version

if nargout == 1
    % Get the T type 1D Chebyshev polynominal..............................
    Tm = ChebyshevT1(Y,m);
    Tn = ChebyshevT1(X,n);

    % Convert 1D to 2D polynominals with considering the derivatives.......
    z3 = real(Tn.*Tm);
else
    % Get the T type 1D Chebyshev polynominal and its derivative...........
    [Tm, Tmy] = ChebyshevT1(Y,m);
    [Tn, Tnx] = ChebyshevT1(X,n);

    % Convert 1D to 2D polynominals with considering the derivatives.......
    z3 = real(Tn.*Tm);
    zx3 = real(Tnx.*Tm);
    zy3 = real(Tn.*Tmy);
end

end


% Subfunction..............................................................
% Get the T type 1D Chebyshev polynominal and its derivative.
function [T, Tx] = ChebyshevT1(X, n)

if nargout == 1
    NUM = length(n);
    T = zeros(size(X,1),size(X,2),NUM);

    for num = 1:NUM
        % Chebyshev T-type polynomial in 1D. 
        T(:,:,num) = cos(n(num).*acos(X));
    end
    
else
    
    NUM = length(n);
    T = zeros(size(X,1),size(X,2),NUM);
    Tx = zeros(size(X,1),size(X,2),NUM);

    for num = 1:NUM
        % Chebyshev T-type polynomial in 1D. 
        T(:,:,num) = cos(n(num).*acos(X));

        % Derivative dT/dx.
        Tx_temp = n(num).*sin(n(num).*acos(X))./sin(acos(X));
        Tx_temp(sin(acos(X))==0) = n(num).^2; %Condition of sin(acos(x))==0
        Tx(:,:,num) = Tx_temp;
    end

end
end

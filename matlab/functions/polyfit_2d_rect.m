function [Zf, Zfx, Zfy, coeffs] = polyfit_2d_rect(...
    X,... x coordinates [m]
    Y,... y coordinates [m]
    Z,... surface map [m]
    m,... order in y direction 
    n,... order in x direction
    polyType,... 'Chebyshev' or 'Lengendre'
    showResult...
)
% 2D polynomial fitting of the given RECTANGULAR surface error map Z using
% 0~m and 0~n orders in y and x directions, respectively. The supported
% polyType is Chebyshev or Legendre

% got the orders and normalize the coordinates
[p, q] = meshgrid(0:n, 0:m);
X_nor = -1 + 2.*(X - min(X(:)))./(max(X(:)) - min(X(:)));
Y_nor = -1 + 2.*(Y - min(Y(:)))./(max(Y(:)) - min(Y(:)));

% choose the poly type
if(strcmp(polyType,'Chebyshev'))
    [z3, z3x, z3y] = ChebyshevXYnm(X_nor, Y_nor, p(:), q(:));
elseif(strcmp(polyType,'Legendre'))
    [z3, z3x, z3y] = LegendreXYnm(X_nor, Y_nor, p(:), q(:));
else
    error('Unkown polynomial type.');
end
z3_res = reshape(z3, [],size(z3,3));

% fitting
A = z3_res(~isnan(Z(:)),:);
b = Z(~isnan(Z(:)));

coeffs = A\b;

for i = 1:length(coeffs)
    z3(:,:,i) = z3(:,:,i)*coeffs(i);
    z3x(:,:,i) = z3x(:,:,i)*coeffs(i)./(max(X(:)) - min(X(:)))*2;
    z3y(:,:,i) = z3y(:,:,i)*coeffs(i)./(max(Y(:)) - min(Y(:)))*2;
end

Zf = sum(z3, 3);
Zfx = sum(z3x, 3);
Zfy = sum(z3y, 3);

Zf = Zf - nanmin(Zf(:));
Zfx = Zfx - nanmean(Zfx(:));
Zfy = Zfy - nanmean(Zfy(:));

% show the result
if showResult == true
    fsfig('Polynomial fitting result');
    
    subplot(321);
    imagesc(X(:), Y(:), Z );
    view([0 90]);
    axis xy image;
    colormap jet;
    title(['Original imagescace, RMS = ' num2str(round(nanstd(Z(:), 1)*1e9, 2)) ' nm']);
    colorbar;
    
    subplot(323);
    imagesc(X(:), Y(:), Zf );
    view([0 90]);
    axis xy image;
    
    title(['Fitted imagescace, RMS = ' num2str(round(nanstd(Zf(:), 1)*1e9, 2)) ' nm']);
    colorbar;
    
    Zd = Z - Zf;
    Zd = RemoveSurface1(X, Y, Zd);
    subplot(325);
    imagesc(X(:), Y(:), Zd );
    view([0 90]);
    axis xy image;
    
    title(['Fitting residual, RMS = ' num2str(round(nanstd(Zd(:), 1)*1e9, 2)) ' nm']);
    colorbar;
    
    subplot(322);
    imagesc(X(:), Y(:), Zf );
    view([0 90]);
    axis xy image;
    
    title(['Fitted imagescace height, RMS = ' num2str(round(nanstd(Zf(:), 1)*1e9, 2)) ' nm']);
    colorbar;
    
    subplot(324);
    imagesc(X(:), Y(:), Zfx );
    view([0 90]);
    axis xy image;
    
    title(['Fitted slope X, RMS = ' num2str(round(nanstd(Zfx(:), 1)*1e9, 2)) ' nrad']);
    colorbar;
    
    subplot(326);
    imagesc(X(:), Y(:), Zfy );
    view([0 90]);
    axis xy image;
    
    title(['Fitted slope Y, RMS = ' num2str(round(nanstd(Zfy(:), 1)*1e9, 2)) ' nrad']);
    colorbar;
end

end
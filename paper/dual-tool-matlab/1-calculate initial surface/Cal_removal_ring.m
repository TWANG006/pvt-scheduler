%Input:R0(radius of workpiece),R1(radius of tool),sx(spacing), TIF(constant TIF of tool),
%Input:rpm1(velocity matrix),DT1(dwell matrix),P1(Contact pressure).

%Output:H(Final Removal).

function H=Cal_removal_ring(R0,R1,R_h,sx,TIF,DT1,rpm1,P1)
%% 1.Input parameters.

% R0=4200;%radius of workpiece
% sx=40;%spacing
% R1=600;%radius of tool
% R_h=1200;%radius of the hole in the middle of workpiece

%% 2.Calculate TIF
x=-R0:sx:R0;
[X,Y]=meshgrid(x,x);
mx=size(X,1);
my=size(X,2);

x1=-R1:sx:R1;
[X1,Y1]=meshgrid(x1,x1);
mx1=size(X1,1);
my1=size(X1,2);

TIF=imresize(TIF,[mx1,my1]);%change the size of TIF

% load ('data\rpm1.mat');%rpm1
% load ('data\DT1.mat');%DT1
% rpm1(find(isnan(rpm1)==1))=0;
% DT1(find(isnan(DT1)==1))=0;

%% Calculate removal. 

X=padarray(X,[(mx1-1)/2,(my1-1)/2]);%Add zero matrix outside the X. Because the tool may out of the range of X
Y=padarray(Y,[(mx1-1)/2,(my1-1)/2]);%Add zero matrix outside the Y.
rpm1=padarray(rpm1,[(mx1-1)/2,(my1-1)/2]);%Add zero matrix of rpm1 outside the workpiece.
DT1=padarray(DT1,[(mx1-1)/2,(my1-1)/2]);%Add zero matrix of DT1 outside the workpiece.
P1=padarray(P1,[(mx1-1)/2,(my1-1)/2]);%Add zero matrix of DT1 outside the workpiece.

mx=size(X,1);
my=size(X,2);

H_1=zeros(mx,my);
for i=(mx1+1)/2:mx-(mx1-1)/2 %workpiece area
    for j=(my1+1)/2:my-(my1-1)/2   
        if (X(i,j)^2+Y(i,j)^2<=R0^2) && (X(i,j)^2+Y(i,j)^2>=R_h^2)
            Z0_1=zeros(mx,my);
            Z0_1(j,i)=1;
            E=conv2(Z0_1,DT1(j,i)*rpm1(j,i)*P1(j,i)*TIF,'same');
            H_1=H_1+E;%Removal
        end
    end
end

X=X((mx1+1)/2:(mx-(mx1-1)/2),(mx1+1)/2:(mx-(mx1-1)/2));%Delete the data which outside of the workpiece
Y=Y((mx1+1)/2:(mx-(mx1-1)/2),(mx1+1)/2:(mx-(mx1-1)/2));
H=H_1((mx1+1)/2:(mx-(mx1-1)/2),(mx1+1)/2:(mx-(mx1-1)/2));%Final Removal



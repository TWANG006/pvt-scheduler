%1.two tools polishing one by one.
%(1) Calculate the removal of tool 1. (DT1¡Árpm1¡ÁP1), and get the removal_1. 
%(2)  Calculate the removal of tool 2. (DT2¡Árpm2¡ÁP2), and get the removal_2.
%total removal_b= removal_1+removal_2;

%2.two tools polishing at the same time.
%Calculate the removal of tool 1. (DT1_a¡Árpm1_a¡ÁP1), and get the removal_1_a. 
%Calculate the removal of tool 2. (DT2_a¡Árpm2_a¡ÁP2), and get the removal_2_a. 
%total removal_a= removal_1_a+removal_2_a.

%3. Varify total removal_b=total removal_a???

%% 1.Input parameters.
close all;
clear;clc;

R0=4200;%radius of workpiece
sx=40;%spacing
R1=600;%radius of tool 1
R2=160;%radius of tool 2
R_h=1200;%radius of the hole in the middle of workpiece

x=-R0:sx:R0;
[X,Y]=meshgrid(x,x);
mx=size(X,1);
my=size(X,2);
x1=-R1:sx:R1;
[X1,Y1]=meshgrid(x1,x1);

%% Calculate the removal.
load ('data\MRR1.mat');%TIF
TIF1=MRR1;%Change the size of TIF in Function Cal_removal()
load ('data\MRR2.mat');%TIF
TIF2=MRR2;%Change the size of TIF in Function Cal_removal()

% 2-1.Calculate the removal of Tool1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load ('data\rpm1.mat');%rpm1
load ('data\DT1.mat');%DT1
load ('data\P1.mat');%P1
rpm1(find(isnan(rpm1)==1))=0;
DT1(find(isnan(DT1)==1))=0;
P1(find(isnan(P1)==1))=0;
Removal1=Cal_removal_ring(R0,R1,R_h,sx,TIF1,DT1,rpm1,P1);%call Function Cal_removal().
%set the outside points with NaN
for i=1:mx
    for j=1:my
        if X(i,j)^2+Y(i,j)^2>R0^2
            Removal1(i,j)=NaN;
        end
    end
end
for i=1:mx
    for j=1:my
        if X(i,j)^2+Y(i,j)^2<R_h^2
            Removal1(i,j)=NaN;
        end
    end
end

subplot(2,3,1)
surf(X,Y,Removal1);
shading interp;
view([0 0 1]);
h=colorbar;
set(get(h,'title'),'string','[nm]');
title('Removal1');
set(gcf,'Position',[400,300,1000,400]);
set(gca,'FontName','Times New Roman','FontSize',10);
grid off;
box on;
axis tight;
axis equal;

% 2-2.Calculate the removal of Tool2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load ('data\rpm2.mat');%rpm1
load ('data\DT2.mat');%DT1
load ('data\P2.mat');%P2
rpm2(find(isnan(rpm2)==1))=0;
DT2(find(isnan(DT2)==1))=0;
P2(find(isnan(P2)==1))=0;
Removal2=Cal_removal_ring(R0,R2,R_h,sx,TIF2,DT2,rpm2,P2);%call Function Cal_removal().
%set the outside points with NaN
for i=1:mx
    for j=1:my
        if X(i,j)^2+Y(i,j)^2>R0^2
            Removal2(i,j)=NaN;
        end
    end
end
for i=1:mx
    for j=1:my
        if X(i,j)^2+Y(i,j)^2<R_h^2
            Removal2(i,j)=NaN;
        end
    end
end

subplot(2,3,2)
surf(X,Y,Removal2);
shading interp;
view([0 0 1]);
h=colorbar;
set(get(h,'title'),'string','[nm]');
title('Removal2');
grid off;
box on;
axis tight;
axis equal;

% 2-3.Calculate the Total Removal:before %%%%%%%%%%%%%%%%%%%%%%%%%%
removal_b=Removal1+Removal2;

%New_Initial_Map = Current_Initial_Map - (Fig. 6 (b) + Fig. 7 (a) + Fig.7 (b) _Fig. 7 (c))/4
load ('data\H_1.mat');%Fig.6(b)
H(find(isnan(H)==1))=0;
H_1=H;
load ('data\H_2.mat');%Fig.7(a)
H(find(isnan(H)==1))=0;
H_2=H;
load ('data\H_3.mat');%Fig.7(b)
H(find(isnan(H)==1))=0;
H_3=H;
load ('data\H_4.mat');%Fig.7(c)
H(find(isnan(H)==1))=0;
H_4=H;
removal_b=removal_b+(H_1+H_2+H_3+H_4)/4;

%set the outside points with NaN
for i=1:mx
    for j=1:my
        if X(i,j)^2+Y(i,j)^2>R0^2
            removal_b(i,j)=NaN;
        end
    end
end
for i=1:mx
    for j=1:my
        if X(i,j)^2+Y(i,j)^2<R_h^2
            removal_b(i,j)=NaN;
        end
    end
end

subplot(2,3,3)
surf(X,Y,removal_b);
shading interp;
view([0 0 1]);
h=colorbar;
set(get(h,'title'),'string','[nm]');
title('Total Removal:before');
grid off;
box on;
axis tight;
axis equal;

% 2-4.Calculate the removal of Tool1_a %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load ('data\rpm1_a.mat');%rpm1
load ('data\DT1_a.mat');%DT1
load ('data\P1_a.mat');%P1_a
rpm1_a(find(isnan(rpm1_a)==1))=0;
DT1_a(find(isnan(DT1_a)==1))=0;
P1_a(find(isnan(P1_a)==1))=0;
Removal1_a=Cal_removal_ring(R0,R1,R_h,sx,TIF1,DT1_a,rpm1_a,P1_a);%call Function Cal_removal().
%set the outside points with NaN
for i=1:mx
    for j=1:my
        if X(i,j)^2+Y(i,j)^2>R0^2
            Removal1_a(i,j)=NaN;
        end
    end
end
for i=1:mx
    for j=1:my
        if X(i,j)^2+Y(i,j)^2<R_h^2
            Removal1_a(i,j)=NaN;
        end
    end
end

subplot(2,3,4)
surf(X,Y,Removal1_a);
shading interp;
view([0 0 1]);
h=colorbar;
set(get(h,'title'),'string','[nm]');
title('Removal1_a');
grid off;
box on;
axis tight;
axis equal;

% 2-5.Calculate the removal of Tool2_a %%%%%%%%%%%%%%%%%%%%%%%%%%
load ('data\rpm2_a.mat');%rpm1
load ('data\DT2_a.mat');%DT1
load ('data\P2_a.mat');%P2_a
rpm2_a(find(isnan(rpm2_a)==1))=0;
DT2_a(find(isnan(DT2_a)==1))=0;
P2_a(find(isnan(P2_a)==1))=0;
Removal2_a=Cal_removal_ring(R0,R2,R_h,sx,TIF2,DT2_a,rpm2_a,P2_a);%call Function Cal_removal().
%set the outside points with NaN
for i=1:mx
    for j=1:my
        if X(i,j)^2+Y(i,j)^2>R0^2
            Removal2_a(i,j)=NaN;
        end
    end
end
for i=1:mx
    for j=1:my
        if X(i,j)^2+Y(i,j)^2<R_h^2
            Removal2_a(i,j)=NaN;
        end
    end
end

subplot(2,3,5)
surf(X,Y,Removal2_a);
shading interp;
view([0 0 1]);
h=colorbar;
set(get(h,'title'),'string','[nm]');
title('Removal2_a');
grid off;
box on;
axis tight;
axis equal;

% 2-6.Calculate the Total Removal:after %%%%%%%%%%%%%%%%%%%%%%%%%%
removal_a=Removal1_a+Removal2_a;

%New_Initial_Map = Current_Initial_Map - (Fig. 6 (b) + Fig. 7 (a) + Fig.7 (b) _Fig. 7 (c))/4
load ('data\H_1.mat');%Fig.6(b)
H(find(isnan(H)==1))=0;
H_1=H;
load ('data\H_2.mat');%Fig.7(a)
H(find(isnan(H)==1))=0;
H_2=H;
load ('data\H_3.mat');%Fig.7(b)
H(find(isnan(H)==1))=0;
H_3=H;
load ('data\H_4.mat');%Fig.7(c)
H(find(isnan(H)==1))=0;
H_4=H;
removal_a=removal_a+(H_1+H_2+H_3+H_4)/4;

%set the outside points with NaN
for i=1:mx
    for j=1:my
        if X(i,j)^2+Y(i,j)^2>R0^2
            removal_a(i,j)=NaN;
        end
    end
end
for i=1:mx
    for j=1:my
        if X(i,j)^2+Y(i,j)^2<R_h^2
            removal_a(i,j)=NaN;
        end
    end
end

subplot(2,3,6)
surf(X,Y,removal_a);
shading interp;
view([0 0 1]);
h=colorbar;
set(get(h,'title'),'string','[nm]');
title('Total Removal:after');
grid off;
box on;
axis tight;
axis equal;

%%%%%%%Calculate PV and RMS.
k=0;
ss_h=0;
nn_removal_b=0;
for i=1:mx
    for j=1:my
        if X(i,j)^2+Y(i,j)^2<=R0^2 &&  X(i,j)^2+Y(i,j)^2>=R_h^2
            k=k+1;
            nn_removal_b(k)=removal_b(i,j);
            ss_h=ss_h+removal_b(i,j)^2;
        end
    end
end 

M_removal_b=nn_removal_b-mean(mean(nn_removal_b));
PV=max(max(M_removal_b))-min(min(M_removal_b));
RMS=sqrt(ss_h/(size(M_removal_b,2)));


figure;
set(gcf,'Position',[400,300,480,350]);
surf(X,Y,removal_b,'EdgeColor','none');
view([0 0 1]);
h=colorbar;
set(get(h,'title'),'string','[nm]');
xlabel('x/mm');
ylabel('y/mm');
zlabel('intial error/nm');
set(gca,'FontName','Times New Roman','FontSize',14);
PV=round(PV*10)/10;%nm
RMS=round(RMS*10)/10;%nm
title(strcat('Initial surface map,RMS=',num2str(RMS),'nm'));
grid off;
box on;
axis tight;
axis equal;
% set(gca,'xtick',-inf:inf:inf);
% set(gca,'ytick',-inf:inf:inf);
% set(gca,'ztick',-inf:inf:inf);

%% save the data

% save('data\Removal1.mat', 'Removal1');
% save('data\Removal2.mat', 'Removal2');
% save('data\Removal1_a.mat', 'Removal1_a');
% save('data\Removal2_a.mat', 'Removal2_a');
% save('data\removal_a.mat', 'removal_a');
% save('data\removal_b.mat', 'removal_b');

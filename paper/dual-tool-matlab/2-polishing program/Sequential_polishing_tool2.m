% workpiece rotate. polishing tool move left and right.
% compare the removal of one-by-one polishing to at-the-same-time polishing.
% there is a hole in the middle of workpiece.

%% 1.Input parameters.
close all;
clear;clc;

R0=4200;%radius of workpiece
sx=40;%spacing
R1=600;%radius of tool 1
R2=160;%radius of tool 2
R_h=1200;%radius of the hole in the middle of workpiece
x_s=R_h;%start point
x_e=R0;%end point
s_s=40;%Spiral spacing
s_ap=0.005*pi;%The angle of two adjacent spiral points

x=-R0:sx:R0;
[X,Y]=meshgrid(x,x);
mx=size(X,1);
my=size(X,2);

x1=-R1:sx:R1;
[X1,Y1]=meshgrid(x1,x1);
mx1=size(X1,1);
my1=size(X1,2);

x2=-R2:sx:R2;
[X2,Y2]=meshgrid(x2,x2);
mx2=size(X2,1);
my2=size(X2,2);

%% 2.Draw an equal angle spiral.

n=(x_e-x_s)/s_s;%How many turns of the spiral
theta=0:s_ap:n*2*pi;
rho=x_s:(x_e-x_s)/(size(theta,2)-1):x_e;
xa=rho.*cos(theta);
ya=rho.*sin(theta);
angle_a=theta;

%Reverse order£¨from outside to inside£©
xa1=fliplr(xa);% X coordinate of the point£¨from outside to inside£©
ya1=fliplr(ya);% Y coordinate of the point
angle_a1=fliplr(angle_a);% Angle value of the point

plot(xa1,ya1,'ro-','LineWidth',1);%draw the spiral

%% 3.load data of DT1,rpm1,P1 and initial error map

load ('data\MRR2.mat');%TIF
TIF2=imresize(MRR2,[mx2,my2]);

load ('data\rpm2.mat');%rpm1
load ('data\DT2.mat');%DT1
load ('data\P2.mat');%P1
rpm2(find(isnan(rpm2)==1))=0;
DT2(find(isnan(DT2)==1))=0;
P2(find(isnan(P2)==1))=0;

[i_sp2,j_sp2,cDT2,crpm2,cP2]=Spiral_Dwell(R0,R_h,sx,xa1,ya1,DT2,rpm2,P2);%Get the parameter value of the spiral points

load ('data\H1_a_T1.mat');%Removal data
H1_a_T1=H;
H1_a_T1(find(isnan(H1_a_T1)==1))=0;
H=H1_a_T1;%initial error map

for i=1:mx
    for j=1:my
        if X(i,j)^2+Y(i,j)^2<=R_h^2
            H(i,j)=0;%there is a hole in the middle of workpiece.
        end
    end
end

%% 4.2D Convolve,and calculate the residual error.

for i=1:size(cDT2,2)%
    Z0=zeros(mx,my);
    Z0((j_sp2(i)),i_sp2(i))=1;
    E=conv2(Z0,cDT2(i)*crpm2(i)*cP2(i)*TIF2,'same');%2D Convolve
    H=H+E;                  
end

for i=1:mx
    for j=1:my
        if X(i,j)^2+Y(i,j)^2<=R_h^2
            H(i,j)=NaN;%there is a hole in the middle of workpiece.
        end
    end
end

for i=1:mx
    for j=1:my
        if X(i,j)^2+Y(i,j)^2>=R0^2
            H(i,j)=NaN;%
        end
    end
end


%%%%%%%Calculate PV and RMS.
k=0;
ss_h=0;
nn_H=0;
for i=1:mx
    for j=1:my
        if (X(i,j)^2+Y(i,j)^2<R0^2) && (X(i,j)^2+Y(i,j)^2>R_h^2)
            k=k+1;
            nn_H(k)=H(i,j);
            ss_h=ss_h+H(i,j)^2;
        end
    end
end 

M_H=nn_H-mean(mean(nn_H));
PV=max(max(M_H))-min(min(M_H));
RMS=sqrt(ss_h/(size(M_H,2)));
RMS=round(RMS*10)/10;%nm

subplot('position',[0.08,0.3,0.3,0.4]);
surf(X,Y,H);
grid off;
shading interp;
view([0 0 1]);
h=colorbar;
set(get(h,'title'),'string','[nm]');
xlabel('x/mm');
ylabel('y/mm');
zlabel('residual error/nm');
title(strcat('residual error-Step 2, RMS=',num2str(RMS),'nm'));
set(gca,'FontName','Times New Roman','FontSize',9);
set(gcf,'position',[600,300,800,400]);
% caxis([-5e-4 5e-4]);
caxis([-10 300]);
%% 5. Drawing the DT, rpm and P graphs on the spiral path.

%dwell time
subplot('position',[0.45,0.65,0.5,0.12]);
% plot(1:size(cDT2,2),cDT2,'g-','linewidth',1);  
plot(1:size(cDT2,2),cDT2,'-','color',[0.294 0.545 0.749],'linewidth',1);
xlabel('Index of dwell point'), ylabel('dwell time/s')
xlim([0,size(xa1,2)]);
title('Dwell time in polishing path after adjustment');
set(gca,'FontName','Times New Roman','FontSize',9);


%rpm
subplot('position',[0.45,0.4,0.5,0.12]);
% plot(1:size(crpm2,2),crpm2,'g-','linewidth',1);
plot(1:size(crpm2,2),crpm2,'-','color',[0.294 0.545 0.749],'linewidth',1);
xlabel('Index of dwell point'), ylabel('speed/rpm')
title('Speed in polishing path after adjustment');
xlim([0,size(xa1,2)]);
ylim([0,350]);
set(gca,'FontName','Times New Roman','FontSize',9);
set(gca,'ytick',[0:100:300]); 


%contact pressure
subplot('position',[0.45,0.15,0.5,0.12]);
% plot(1:size(cP2,2),cP2,'g-','linewidth',1);
plot(1:size(cP2,2),cP2,'-','color',[0.294 0.545 0.749],'linewidth',1);
xlabel('Index of dwell point'), ylabel('comtact pressure/Mpa')
xlim([0,size(xa1,2)]);
title('P values in polishing path after adjustment');
set(gca,'FontName','Times New Roman','FontSize',9);

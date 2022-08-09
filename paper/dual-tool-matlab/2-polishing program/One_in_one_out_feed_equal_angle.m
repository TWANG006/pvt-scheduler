% The workpiece rotate. the tool 1 at the right of workpiece and the tool 2 at the middle of workpiece. 
% Tool 1 move outside to inside, while Tool 2 move inside to outside. (both right to left)
% There is a hole in the middle of workpiece.
% Calculate the residual error map.

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
s_ap=0.005*pi;%The angle of two adjacent spiral points,0.005

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

%Reverse order£¨from outside to inside£©----------------------------TOOL 1
xa1=fliplr(xa);% X coordinate of the point£¨from outside to inside£©
ya1=fliplr(ya);% Y coordinate of the point
angle_a1=fliplr(angle_a);% Angle value of the point
plot(xa1,ya1,'ro-','LineWidth',1);%draw the spiral path of tool 1


%the spiral path of tool 2
%(1)from outside to inside
xa2=-xa1;%X coordinate of the point£¨from outside to inside£©--TOOL 2
ya2=-ya1;
angle_a2=angle_a1-pi;


%(2)Reverse order£¨from inside to outside£©--tool2
axa2=fliplr(xa2);% X coordinate of the point
aya2=fliplr(ya2);% Y coordinate of the point
aangle_a2=fliplr(angle_a2);% Angle value of the point

%(3) Symmetrical along the x axis----------------------------------TOOL 2
axa2=axa2;% X coordinate of the point
aya2=-aya2;% Y coordinate of the point
aangle_a2=-aangle_a2;% Angle value of the point
% hold on;
% plot(axa2,aya2,'g*-','LineWidth',1);%draw the spiral path of tool 2

%% 3.load data of DT1,rpm1,P1 and initial error map

load ('data\MRR1.mat');%TIF
TIF1=imresize(MRR1,[mx1,my1]);
load ('data\MRR2.mat');%TIF
TIF2=imresize(MRR2,[mx2,my2]);

load ('data\DT1_a.mat');%DT1_a
load ('data\rpm1_a.mat');%rpm1_a
load ('data\P1_a.mat');%P1_a
DT1_a(find(isnan(DT1_a)==1))=0;
rpm1_a(find(isnan(rpm1_a)==1))=0;
P1_a(find(isnan(P1_a)==1))=0;

load ('data\DT2_a.mat');%DT2_a
load ('data\rpm2_a.mat');%rpm2_a
load ('data\P2_a.mat');%P2_a
DT2_a(find(isnan(DT2_a)==1))=0;
rpm2_a(find(isnan(rpm2_a)==1))=0;
P2_a(find(isnan(P2_a)==1))=0;

[i_sp1,j_sp1,bDT1_a,brpm1_a,bP1_a,i_sp2,j_sp2,bDT2_a,brpm2_a,bP2_a]=Dwell_Sync(R0,R_h,sx,DT1_a,rpm1_a,P1_a,DT2_a,rpm2_a,P2_a,xa1,ya1,axa2,aya2);

load ('data\removal_a.mat');%Removal data
removal_a(find(isnan(removal_a)==1))=0;
H=-removal_a;%initial error map

for i=1:mx
    for j=1:my
        if X(i,j)^2+Y(i,j)^2<=R_h^2
            H(i,j)=0;%there is a hole in the middle of workpiece.
        end
    end
end

%% 4.2D Convolve,and calculate the residual error.

for i=1:size(xa1,2)%
    Z0=zeros(mx,my);
    Z0((j_sp1(i)),i_sp1(i))=1;%from outside to inside (Tool 1 is at the right of workpiece)
    E1=conv2(Z0,bDT1_a(i)*brpm1_a(i)*bP1_a(i)*TIF1,'same');%2D Convolve for tool 1 %TIF1->donot rotate; TIF_1-> rotate
    H=H+E1; 
    
    Z0=zeros(mx,my);
    Z0((j_sp2(i)),i_sp2(i))=1;%from inside to outside (Tool 2 is at the middle of workpiece) 
    E2=conv2(Z0,bDT2_a(i)*brpm2_a(i)*bP2_a(i)*TIF2,'same');%2D Convolve for tool 2
    H=H+E2; 
end



for i=1:mx
    for j=1:my
        if X(i,j)^2+Y(i,j)^2<=(R_h+0)^2
            H(i,j)=NaN;%there is a hole in the middle of workpiece.
        end
    end
end

for i=1:mx
    for j=1:my
        if X(i,j)^2+Y(i,j)^2>=(R0-0)^2
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
title(strcat('residual error-1-in1-out, RMS=',num2str(RMS),'nm'));
set(gca,'FontName','Times New Roman','FontSize',9);
set(gcf,'position',[600,300,800,400]);
% caxis([-5e-4 5e-4]);
caxis([-10 300]);
%% 5. Drawing the DT, rpm and P graphs on the spiral path.

%dwell time
subplot('position',[0.45,0.65,0.5,0.12]);
plot(1:size(bDT1_a,2),bDT1_a,'-','color',[0.686 0.404 0.239],'linewidth',2); 
hold on;
plot(1:size(bDT2_a,2),bDT2_a,'-','color',[0.294 0.545 0.749],'linewidth',1); 
% legend('too11','too12');
xlabel('Index of dwell point'), ylabel('dwell time/s')
title('Dwell time in polishing path after adjustment');
xlim([0,size(xa1,2)]);
hold off;
set(gca,'FontName','Times New Roman','FontSize',9);

%rpm
subplot('position',[0.45,0.4,0.5,0.12]);
plot(1:size(brpm1_a,2),brpm1_a,'-','color',[0.686 0.404 0.239],'linewidth',1);
hold on;
plot(1:size(brpm2_a,2),brpm2_a,'-','color',[0.294 0.545 0.749],'linewidth',1);
% legend('too11','too12');
xlabel('Index of dwell point'), ylabel('speed/rpm')
title('Speed in polishing path after adjustment');
xlim([0,size(xa1,2)]);
ylim([0,350]);
hold off;
set(gca,'FontName','Times New Roman','FontSize',9);
set(gca,'ytick',[0:100:300]); 


%contact pressure
subplot('position',[0.45,0.15,0.5,0.12]);
plot(1:size(bP1_a,2),bP1_a,'-','color',[0.686 0.404 0.239],'linewidth',1);
hold on;  
plot(1:size(bP2_a,2),bP2_a,'-','color',[0.294 0.545 0.749],'linewidth',1);
% legend('too11','too12');
xlabel('Index of dwell point'), ylabel('comtact pressure/Mpa')
title('P values in polishing path after adjustment');
xlim([0,size(xa1,2)]);
hold off;
set(gca,'FontName','Times New Roman','FontSize',9);

% The workpiece rotate. the tool 1 at the right of workpiece and the tool 2 at the left of workpiece. The both move outside to inside.
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
A_L=40;%arc length

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

%% 2.Calculate Spiral line.
v=1;%linear velocity,mm/s
t_t=(x_e-x_s)/v;%total time. Not equal total dwell time.(Just calculate the spiral points).
w=2*pi*v/s_s; %argular velocity£¬rad/s
delta_t=A_L*(x_s+v*t_t)/(x_e*w*x_s);

t_n=0;%cumulative time.(just use to calculate the spiral line.)
for i=1:1000000
    if t_n(i)<=t_t
        xa(i)=(x_s+v*t_n(i)).*cos(w*t_n(i));% X coordinate of the point
        ya(i)=(x_s+v*t_n(i)).*sin(w*t_n(i));% Y coordinate of the point
        angle_a(i)=w*t_n(i);% Angle value of the point
        t_n(i+1)=t_n(i)+delta_t*(x_s/(x_s+v*t_n(i)));% The larger the radius, the shorter the time interval (equal arc length)
    else
        break;
    end
end;

%Reverse order£¨from outside to inside£©
xa1=fliplr(xa);% X coordinate of the point£¨from outside to inside£©--TOOL 1
ya1=fliplr(ya);% Y coordinate of the point
angle_a1=fliplr(angle_a);% Angle value of the point
% plot(xa1,ya1,'ro-','LineWidth',1);%draw the spiral path of tool 1

%the spiral path of tool 2
xa2=-xa1;%X coordinate of the point£¨from outside to inside£©--TOOL 2
ya2=-ya1;
angle_a2=angle_a1-pi;
% hold on;
% plot(xa2,ya2,'b*-','LineWidth',1);%draw the spiral path of tool 2

%% 3.load data of DT1,rpm1,P1 and initial error map

load ('data\MRR1.mat');%TIF1
TIF1=imresize(MRR1,[mx1,my1]);
load ('data\MRR2.mat');%TIF2
TIF2=imresize(MRR2,[mx2,my2]);

load ('data\rpm1_a.mat');%rpm1_a
load ('data\DT1_a.mat');%DT1_a
load ('data\P1_a.mat');%P1_a
rpm1_a(find(isnan(rpm1_a)==1))=0;
DT1_a(find(isnan(DT1_a)==1))=0;
P1_a(find(isnan(P1_a)==1))=0;

load ('data\rpm2_a.mat');%rpm2_a
load ('data\DT2_a.mat');%DT2_a
load ('data\P2_a.mat');%P2_a
rpm2_a(find(isnan(rpm2_a)==1))=0;
DT2_a(find(isnan(DT2_a)==1))=0;
P2_a(find(isnan(P2_a)==1))=0;


[i_sp1_a,j_sp1_a,cDT1_a,crpm1_a,cP1_a]=Spiral_Dwell(R0,R_h,sx,xa1,ya1,DT1_a,rpm1_a,P1_a);%Get the parameter value of the spiral points

[i_sp2_a,j_sp2_a,cDT2_a,crpm2_a,cP2_a]=Spiral_Dwell(R0,R_h,sx,xa2,ya2,DT2_a,rpm2_a,P2_a);%Get the parameter value of the spiral points


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
for i=1:size(cDT1_a,2)%
    Z0=zeros(mx,my);
    Z0((j_sp1_a(i)),i_sp1_a(i))=1;
    E1=conv2(Z0,cDT1_a(i)*crpm1_a(i)*cP1_a(i)*TIF1,'same');%2D Convolve
    H=H+E1;  
    
    Z0=zeros(mx,my);
    Z0((j_sp2_a(i)),i_sp2_a(i))=1;
    E2=conv2(Z0,cDT2_a(i)*crpm2_a(i)*cP2_a(i)*TIF2,'same');%2D Convolve
    H=H+E2; 
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
shading interp;
view([0 0 1]);
h=colorbar;
set(get(h,'title'),'string','[nm]');
xlabel('x/mm');
ylabel('y/mm');
zlabel('residual error/nm');
title(strcat('residual error-out2in, RMS=',num2str(RMS),'nm'));
set(gca,'FontName','Times New Roman','FontSize',11);
set(gcf,'position',[600,300,800,400]);
caxis([-10 300]);%nm

%% 5. Drawing the DT, rpm and P graphs on the spiral path.

%dwell time
subplot('position',[0.45,0.65,0.5,0.12]);
plot(1:size(cDT1_a,2),cDT1_a,'-','color',[0.686 0.404 0.239],'linewidth',2); 
hold on;
plot(1:size(cDT2_a,2),cDT2_a,'-','color',[0.294 0.545 0.749],'linewidth',1); 
legend('too11','too12');
xlabel('Index of dwell point'), ylabel('dwell time/s')
title('Dwell time in polishing path after adjustment');
hold off;
set(gca,'FontName','Times New Roman','FontSize',11);
xlim([0,size(xa1,2)]);

%rpm
subplot('position',[0.45,0.4,0.5,0.12]);
plot(1:size(crpm1_a,2),crpm1_a,'-','color',[0.686 0.404 0.239],'linewidth',1);
hold on;
plot(1:size(crpm2_a,2),crpm2_a,'-','color',[0.294 0.545 0.749],'linewidth',1);
legend('too11','too12');
xlabel('Index of dwell point'), ylabel('speed/rpm')
title('Speed in polishing path after adjustment');
ylim([0,350]);
hold off;
set(gca,'FontName','Times New Roman','FontSize',11);
set(gca,'ytick',[0:100:300]); 
xlim([0,size(xa1,2)]);

%contact pressure
subplot('position',[0.45,0.15,0.5,0.12]);
plot(1:size(cP1_a,2),cP1_a,'-','color',[0.686 0.404 0.239],'linewidth',1);
hold on;
plot(1:size(cP2_a,2),cP2_a,'-','color',[0.294 0.545 0.749],'linewidth',1);
legend('too11','too12');
xlabel('Index of dwell point'), ylabel('comtact pressure/Mpa')
title('P values in polishing path after adjustment');
hold off;
set(gca,'FontName','Times New Roman','FontSize',11);
xlim([0,size(xa1,2)]);


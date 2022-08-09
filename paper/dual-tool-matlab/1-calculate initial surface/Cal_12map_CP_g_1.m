%simulate all the 12 maps.
% Add:1-4.Make sure the maximum value of rpm1_a is not greater than rpm1_max.(0¡«rpm1_max)
% Add:1-4.Make sure the maximum value of rpm2_a is not greater than rpm2_max.(0¡«rpm2_max)

%Dwell time of primary tool: from Zernike z=-z3+z4+z7+z8-z9.
%Speed of primary tool:from Zernike 100*(Z8-2*z8min).
%Contact pressure of primary tool:from Zernike 0.6*(Z10-2*z10min).

%Dwell time of secondary tool:from Zernike zz=z7-z8+z9.
%Speed of secondary tool:from Zernike 100*(Z7-2*z7min).
%Contact pressure of secondary tool:from Zernike 0.35*(Z7+0.5*z10)-2*(Z7+0.5*z10)min.

%% 1-1.Calculate
close all;
clear;clc;

R0=4200;%radius of workpiece
ssx=20;%
R_h=1200;%radius of the hole in the middle of workpiece
rpm1_max=250;%Maximum speed of rpm1 allowed
rpm2_max=300;%Maximum speed of rpm2 allowed

x = -1.05:0.01:1.05;
[X,Y]=meshgrid(x,x);
X=imresize(X,[R0/ssx+1,R0/ssx+1]);
Y=imresize(Y,[R0/ssx+1,R0/ssx+1]);
[theta,rho]=cart2pol(X,Y);
X=R0*X/1.05;
Y=R0*Y/1.05;
X=round(X*10000)/10000;
Y=round(Y*10000)/10000;

mx=size(X,1);
my=size(X,2);
for i=1:mx
    for j=1:my       
        if (X(i,j)^2+Y(i,j)^2>R0^2)
            rho(i,j)=NaN;
        end
    end
end

%% 1-2. Input random map
z3=-1+2*rho.^2;%Zernike Z3
z4=rho.^2.*cos(2*theta);%Zernike Z4
z7=rho.^2.*sin(2*theta);%Zernike Z7
z8=1-6*rho.^2+6*rho.^4;%Zernike Z8
z9=rho.^3.*cos(3*theta);%Zernike Z9
z10=rho.^3.*sin(3*theta);%Zernik Z10

n3=-1;n4=1;n7=1;n8=1;n9=-1;
z=n3*z3+n4*z4+n7*z7+n8*z8+n9*z9;
z=z-1.1*min(min(z));%if z=z-min(min(z)), there will be divisor equal to 0

DT1=z;%Dwell time of primary tool: from Zernike z=n3*z3+n4*z4+n7*z7+n8*z8+n9*z9.(random between 0.244¡«4.8327)
rpm1=100*(z8-2*min(min(z8)));%Speed of primary tool:from Zernike Z8.(random between 50¡«200)
P1=0.6*(z10-2*min(min(z10)));%Contact pressure of primary tool:from Zernike Z10.(random between 0.05¡«0.15)

zzd=n7*z7-n8*z8-n9*z9;
zzd=zzd-1.1*min(min(zzd));
DT2=zzd;%Dwell time of secondary tool:from Zernike zz=n7*z7-n8*z8-n9*z9.(random between 0.289¡«4.672)
rpm2=100*(z7-2*min(min(z7)));%Speed of secondary tool:from Zernike Z7.(random between 100¡«300)
zzp=z7+0.5*z10;
P2=0.35*(zzp-2*min(min(zzp)));%Contact pressure of secondary tool:from Zernike zzp=z7+0.5*z10.(random between 0.05¡«0.25)

%% 1-3.Calculate the rest map
DT1_a=DT1;
rpm1_a=rpm1;
P1_a=P1;

DT1_a=DT1;
DT2_a=imrotate(DT1_a,180);%Modify DT2_a=imrotate(DT1,180) to DT2_a=imrotate(DT1_a,180)

rpm2_a=rpm2.*(DT2./DT2_a);
P2_a=P2;

%% 1-4.Balance the speed of rpm1 and rpm2
b_rpm1_h=0;%if the speed of rpm1 too high, b_rpm1_h=1
b_rpm2_h=0;%if the speed of rpm2 too high, b_rpm2_h=1

k=0;%Number of iterations
psi=2;%modified coefficient of rotated speed,¦×

delta_rpm1=zeros(mx,my);%adjustment value of rpm1(i,j)(if the speed of rpm1 at this point is too high)
delta_rpm2=zeros(mx,my);%adjustment value of rpm2(i,j)(if the speed of rpm2 at this point is too high)

b_rpm1_f=zeros(mx,my);%if the value=1, it means the speed of rpm1 at this point does not need to be adjusted.
b_rpm2_f=zeros(mx,my);%if the value=1, it means the speed of rpm2 at this point does not need to be adjusted.

for i=1:mx
    for j=1:my       
        if (X(i,j)^2+Y(i,j)^2>R0^2)
            b_rpm1_f(i,j)=1;%No adjustment is required outside the workpiece
            b_rpm2_f(i,j)=1;
        end
    end
end

while 1
    %Judge if the speed of rpm1 or rpm2 is too high
    for i=1:mx
        for j=1:my       
            if rpm1_a(i,j)>rpm1_max 
                b_rpm1_h=1; 
            end
            if rpm2_a(i,j)>rpm1_max 
                b_rpm2_h=1;
            end
        end
    end
    
    if (all(b_rpm1_f(:)==1)&&all(b_rpm2_f(:)==1)) %No adjustment is required of all point in rpm1 and rpm2
        break;
    end
    if (b_rpm1_h==0)&&(b_rpm2_h==0) %if the speed of rpm1 and rpm2 are not too high. (both within certain range)
        break;
    end
    k=k+1;%Number of iterations    
    
    %Make sure the value of rpm2_a is between 0¡«rpm2_max
    for i=1:mx
        for j=1:my      
            if (delta_rpm2(i,j)>=rpm2_max)||(round(rpm2_a(i,j)*1000)/1000<=rpm2_max)%if the speed of rpm2 is between 0¡«rpm2_max
                b_rpm2_f(i,j)=1;%It means the speed at the point do not need to change
            end
            if (b_rpm2_f(i,j)==0)&&(round(rpm2_a(i,j)*1000)/1000>rpm2_max) % make sure the value of rpm2_a is not greater than 300 
                rpm2_a(i,j)=rpm2_max-delta_rpm2(i,j);
                DT2_a(i,j)=DT2(i,j).*(rpm2(i,j)./rpm2_a(i,j));   
%                 delta_rpm2(i,j)=delta_rpm2(i,j)+psi;
            end
        end
    end
    DT1_a=imrotate(DT2_a,180);%rotate 180¡ã
    rpm1_a=rpm1.*(DT1./DT1_a);

    %Make sure the value of rpm1_a is between 50¡«200
    for i=1:mx
        for j=1:my     
            if (delta_rpm1(i,j)>=rpm1_max)||(round(rpm1_a(i,j)*1000)/1000<=rpm1_max)%if the speed of rpm2 is between 0¡«rpm1_max
                b_rpm1_f(i,j)=1;%It means the speed at the point do not need to change
            end
            if (b_rpm1_f(i,j)==0)&&(round(rpm1_a(i,j)*1000)/1000>rpm1_max) % make sure the value of rpm1_a is not greater than 200 
                rpm1_a(i,j)=rpm1_max-delta_rpm1(i,j);
                DT1_a(i,j)=DT1(i,j).*(rpm1(i,j)./rpm1_a(i,j)); 
%                 delta_rpm1(i,j)=delta_rpm1(i,j)+psi;
            end
        end
    end
    DT2_a=imrotate(DT1_a,180);%rotate 180¡ã
    rpm2_a=rpm2.*(DT2./DT2_a);
    
    b_rpm1_h=0;%
    b_rpm2_h=0;%

end;

%% 2.Drawing--12 maps
for i=1:mx
    for j=1:my       
        if (X(i,j)^2+Y(i,j)^2>R0^2) || (X(i,j)^2+Y(i,j)^2<R_h^2)
            DT1(i,j)=0;
            DT2(i,j)=0;
            DT1_a(i,j)=0;
            DT2_a(i,j)=0;
        end
    end
end

t_DT1=sum(sum(DT1));
t_DT1=round(t_DT1/3600*100)/100;

t_DT2=sum(sum(DT2));
t_DT2=round(t_DT2/3600*100)/100;

t_DT1_a=sum(sum(DT1_a));
t_DT1_a=round(t_DT1_a/3600*100)/100;

t_DT2_a=sum(sum(DT2_a));
t_DT2_a=round(t_DT2_a/3600*100)/100;


for i=1:mx
    for j=1:my       
        if (X(i,j)^2+Y(i,j)^2>R0^2) || (X(i,j)^2+Y(i,j)^2<R_h^2)
            DT1(i,j)=NaN;
            rpm1(i,j)=NaN;
            P1(i,j)=NaN;
            DT2(i,j)=NaN;
            rpm2(i,j)=NaN;
            P2(i,j)=NaN;
            DT1_a(i,j)=NaN;
            rpm1_a(i,j)=NaN;
            P1_a(i,j)=NaN;
            DT2_a(i,j)=NaN;
            rpm2_a(i,j)=NaN;
            P2_a(i,j)=NaN;
        end
    end
end

%% 3.drawing--6 maps-before
% 3-1 primary tool:before
subplot(2,3,1)
surf(X,Y,DT1,'EdgeColor','none');
view([0 0 1]);
h=colorbar;
set(get(h,'title'),'string','[s]');
title(strcat('T^s_1, Total dwell time=',num2str(t_DT1),'h'));
% temp1=caxis
temp1=[0  5];
caxis(temp1);
% xlim([-4200 4200]);
% ylim([-4200 4200]);
set(gcf,'position',[400,300,1000,400]);
set(gca,'FontName','Times New Roman','FontSize',11.5);
grid off;
box on;
axis image;

subplot(2,3,2)
surf(X,Y,rpm1,'EdgeColor','none');
view([0 0 1]);
h=colorbar;
set(get(h,'title'),'string','[mm/s]');
title('V^s_1');
temp2=[50 300];
caxis(temp2);
set(gca,'FontName','Times New Roman','FontSize',11.5);
grid off;
box on;
axis image;

subplot(2,3,3)
surf(X,Y,P1,'EdgeColor','none');
view([0 0 1]);
h=colorbar;
set(get(h,'title'),'string','[psi]');
title('P^s_1');
temp3=[0.5 2];
caxis(temp3);
set(gca,'FontName','Times New Roman','FontSize',11.5);
grid off;
box on;
axis image;

%% 3-2 secondary tool:before
subplot(2,3,4)
surf(X,Y,DT2,'EdgeColor','none');
view([0 0 1]);
h=colorbar;
set(get(h,'title'),'string','[s]');
title(strcat('T^s_2, Total dwell time=',num2str(t_DT2),'h'));
caxis(temp1);
set(gca,'FontName','Times New Roman','FontSize',11.5);
grid off;
box on;
axis image;

subplot(2,3,5)
surf(X,Y,rpm2,'EdgeColor','none');
view([0 0 1]);
h=colorbar;
set(get(h,'title'),'string','[mm/s]');
title('V^s_2');
caxis(temp2);
set(gca,'FontName','Times New Roman','FontSize',11.5);
grid off;
box on;
axis image;

subplot(2,3,6)
surf(X,Y,P2,'EdgeColor','none');
view([0 0 1]);
h=colorbar;
set(get(h,'title'),'string','[psi]');
title('P^s_2');
caxis(temp3);
set(gca,'FontName','Times New Roman','FontSize',11.5);
grid off;
box on;
axis image;

%% 4.drawing--6 maps-after
figure;
% 4-1 primary tool:after
subplot(2,3,1)
surf(X,Y,DT1_a,'EdgeColor','none');
view([0 0 1]);
h=colorbar;
set(get(h,'title'),'string','[s]');
% title(strcat('T^d_1, Total dwell time=',num2str(t_DT1_a),'h'));
title(strcat('T^m_1, Total dwell time=',num2str(t_DT1_a),'h'));
% temp1=caxis
temp1=[0  5];
caxis(temp1);
% xlim([-4200 4200]);
% ylim([-4200 4200]);
set(gcf,'position',[400,300,1000,400]);
set(gca,'FontName','Times New Roman','FontSize',11.5);
grid off;
box on;
axis image;

subplot(2,3,2)
surf(X,Y,rpm1_a,'EdgeColor','none');
view([0 0 1]);
h=colorbar;
set(get(h,'title'),'string','[mm/s]');
title('V^m_1');
temp2=[50 300];
caxis(temp2);
set(gca,'FontName','Times New Roman','FontSize',11.5);
grid off;
box on;
axis image;

subplot(2,3,3)
surf(X,Y,P1_a,'EdgeColor','none');
view([0 0 1]);
h=colorbar;
set(get(h,'title'),'string','[psi]');
title('P^m_1');
temp3=[0.5 2.0];
caxis(temp3);
set(gca,'FontName','Times New Roman','FontSize',11.5);
grid off;
box on;
axis image;

%% 4-2 secondary tool:after
subplot(2,3,4)
surf(X,Y,DT2_a,'EdgeColor','none');
view([0 0 1]);
h=colorbar;
set(get(h,'title'),'string','[s]');
title(strcat('T^m_2, Total dwell time=',num2str(t_DT2_a),'h'));
caxis(temp1);
set(gca,'FontName','Times New Roman','FontSize',11.5);
grid off;
box on;
axis image;

subplot(2,3,5)
surf(X,Y,rpm2_a,'EdgeColor','none');
view([0 0 1]);
h=colorbar;
set(get(h,'title'),'string','[mm/s]');
title('V^m_2');
caxis(temp2);
set(gca,'FontName','Times New Roman','FontSize',11.5);
grid off;
box on;
axis image;

subplot(2,3,6)
surf(X,Y,P2_a,'EdgeColor','none');
view([0 0 1]);
h=colorbar;
set(get(h,'title'),'string','[psi]');
title('P^m_2');
caxis(temp3);
set(gca,'FontName','Times New Roman','FontSize',11.5);
grid off;
box on;
axis image;

%% save the data

% save('data\DT1.mat', 'DT1');
% save('data\rpm1.mat', 'rpm1');
% save('data\P1.mat', 'P1');
% save('data\DT2.mat', 'DT2');
% save('data\rpm2.mat', 'rpm2');
% save('data\P2.mat', 'P2');
% save('data\DT1_a.mat', 'DT1_a');
% save('data\rpm1_a.mat', 'rpm1_a');
% save('data\P1_a.mat', 'P1_a');
% save('data\DT2_a.mat', 'DT2_a');
% save('data\rpm2_a.mat', 'rpm2_a');
% save('data\P2_a.mat', 'P2_a');
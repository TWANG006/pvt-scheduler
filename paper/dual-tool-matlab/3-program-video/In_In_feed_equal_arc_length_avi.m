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

%Calculate the DT,V and P at dwell points.

[i_sp1_a,j_sp1_a,cDT1_a,crpm1_a,cP1_a]=Spiral_Dwell(R0,R_h,sx,xa1,ya1,DT1_a,rpm1_a,P1_a);%Get the parameter value of the spiral points
[i_sp2_a,j_sp2_a,cDT2_a,crpm2_a,cP2_a]=Spiral_Dwell(R0,R_h,sx,xa2,ya2,DT2_a,rpm2_a,P2_a);%Get the parameter value of the spiral points


load ('data\removal_a.mat');%Removal data
removal_a(find(isnan(removal_a)==1))=0;
H=-removal_a;%initial error map

%% 4.2D Convolve,and calculate the residual error.

i_t=1;%take a frame every certain number of dewll time
%If the point outside the matrix H is not NaN, an error will occur when rotating.  (H1=imrotate(H,360*angle_a1(i)/(2*pi),'crop');)
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

writerObj=VideoWriter('In-In feed with equal-arc-length path.avi');%make a movie
writerObj.FrameRate=20;
open(writerObj);

d_dt=0;%total Dwell time
for i=1:size(xa1,2)%
    Z0=zeros(mx,my);
    Z0((j_sp1_a(i)),i_sp1_a(i))=1;
    E1=conv2(Z0,cDT1_a(i)*crpm1_a(i)*cP1_a(i)*TIF1,'same');%2D Convolve
    H=H+E1; 
    
    Z0=zeros(mx,my);
    Z0((j_sp2_a(i)),i_sp2_a(i))=1;
    E2=conv2(Z0,cDT2_a(i)*crpm2_a(i)*cP2_a(i)*TIF2,'same');%2D Convolve
    H=H+E2;
    d_dt=d_dt+cDT1_a(i);%total Dwell time
    
    if (d_dt>710*i_t) || (i==size(xa1,2))
        i_t=i_t+1;
        H1=imrotate(H,360*angle_a1(i)/(2*pi),'crop');%rotate the H1(Show it in the video)
        for m_i=1:mx
            for m_j=1:my
                if X(m_i,m_j)^2+Y(m_i,m_j)^2>=(R0-0)^2
                    H1(m_i,m_j)=NaN;%
                end
            end
        end
        
        %residual error
        subplot('position',[0.1,0.26,0.42,0.47]);
        surf(X,Y,H1,'EdgeColor','none');
        box on;
        grid off;
        view([0 0 1]);
        h=colorbar;
        set(get(h,'title'),'string','[nm]');
        xlabel('x(mm)');
        ylabel('y(mm)');
        zlabel('residual error(mm)');
        axis([-4800,4800,-4800,4800]);
        d_dt1=d_dt/3600;%hour
        d_dt1=round(d_dt1*100)/100; 
        title({['In-In feed with equal-arc-length path'];['Total dwell time=',num2str(d_dt1),'h']});
        set(gcf,'position',[600,300,720,480]);
        
        temp1=caxis;
        if temp1(2)<300
            caxis([-10 300]);%nm
        end
        
        
        c_theta=0:pi/50:2*pi;
        x_pt1=sqrt(xa1(i)^2+ya1(i)^2);
        x_dc1=R1*cos(c_theta)+x_pt1;
        y_dc1=R1*sin(c_theta)+0;
        z_dc1=100000*ones(size(x_dc1,2));%Make sure the circle is above the residual error map
        hold on;
        plot3(x_dc1,y_dc1,z_dc1,'-','color',[0.686 0.404 0.239],'linewidth',2);%draw the tool 1 size and location
        
        x_pt2=sqrt(xa2(i)^2+ya2(i)^2);
        x_dc2=R2*cos(c_theta)-x_pt2;
        y_dc2=R2*sin(c_theta)+0;
        z_dc2=100000*ones(size(x_dc2,2));%Make sure the circle is above the residual error map
        plot3(x_dc2,y_dc2,z_dc2,'-','color',[0.294 0.545 0.749],'linewidth',2);%draw the tool 2 size and location
        hold off;
        
        %dwell time
        subplot('position',[0.62,0.74,0.35,0.16]);
        plot(1:size(cDT1_a,2),cDT1_a,'-','color',[0.686 0.404 0.239],'linewidth',2);
        hold on; 
        plot(1:size(cDT2_a,2),cDT2_a,'-','color',[0.294 0.545 0.749],'linewidth',1); 
        plot(i,cDT1_a(i),'r*','linewidth',3);%Point out the value of DT1_a in the dwelling point
        plot(i,cDT2_a(i),'b*','linewidth',1.5);%Point out the value of DT2_a in the dwelling point        
%         leg1=legend('tool_1','tool_2','Location','Best');
        leg1=legend('tool_1','tool_2','Location','North');
        set(leg1,'Orientation','horizon','FontSize',8);
        ylabel('Dwell time(s)');
        cDT1_a(i)=round(cDT1_a(i)*100)/100; 
        cDT2_a(i)=round(cDT2_a(i)*100)/100; 
        title(strcat('T_1^m=',num2str(cDT1_a(i)),'s        T_2^m=',num2str(cDT2_a(i)),'s'));
%         xlim([0,size(xa1,2)]);
        xlim([0,i]);
        hold off;
        
        %rpm
        subplot('position',[0.62,0.43,0.35,0.16]);
        plot(1:size(crpm1_a,2),crpm1_a,'-','color',[0.686 0.404 0.239],'linewidth',1);
        hold on;
        plot(1:size(crpm2_a,2),crpm2_a,'-','color',[0.294 0.545 0.749],'linewidth',1);
        plot(i,crpm1_a(i),'r*','linewidth',1.5);%Point out the value of DT1_a in the dwelling point
        plot(i,crpm2_a(i),'b*','linewidth',1.5);%Point out the value of DT2_a in the dwelling point        
        ylabel('Velocity(mm/s)');
        crpm1_a(i)=round(crpm1_a(i)*10)/10; 
        crpm2_a(i)=round(crpm2_a(i)*10)/10;
        title(strcat('V_1^m=',num2str(crpm1_a(i)),'mm/s        V_2^m=',num2str(crpm2_a(i)),'mm/s'));
%         xlim([0,size(xa1,2)]);
        xlim([0,i]);
        ylim([0,350]);
        hold off;
        set(gca,'ytick',[0:100:300]);
        
        %contact pressure
        subplot('position',[0.62,0.12,0.35,0.16]);
        plot(1:size(cP1_a,2),cP1_a,'-','color',[0.686 0.404 0.239],'linewidth',1);
        hold on;
        plot(1:size(cP2_a,2),cP2_a,'-','color',[0.294 0.545 0.749],'linewidth',1);
        plot(i,cP1_a(i),'r*','linewidth',1.5);%Point out the value of DT1_a in the dwelling point
        plot(i,cP2_a(i),'b*','linewidth',1.5);%Point out the value of DT2_a in the dwelling point        
        xlabel('Index of dwell points');
        ylabel('Contact pressure(psi)');
        cP1_a(i)=round(cP1_a(i)*100)/100; 
        cP2_a(i)=round(cP2_a(i)*100)/100;
        title(strcat('P_1^m=',num2str(cP1_a(i)),'psi        P_2^m=',num2str(cP2_a(i)),'psi'));
%         xlim([0,size(xa1,2)]);
        xlim([0,i]);
        hold off;
        
               
        frame = getframe(gcf);
        frame.cdata=imresize(frame.cdata, [480 720]);
        writeVideo(writerObj,frame); 
        
        if i==size(xa1,2) %repeat 1s at the end
            for i_repeat=1:20
               frame = getframe(gcf);
               frame.cdata=imresize(frame.cdata, [480 720]);
               writeVideo(writerObj,frame); 
            end
        end
        
     end   
    
end

close(writerObj);

% The workpiece rotate. the tool 1 at the right of workpiece and the tool 2 at the middle of workpiece. 
% Tool 1 move outside to inside, while Tool 2 move inside to outside. (both right to left)
% There is a hole in the middle of workpiece.
% Calculate the residual error map.

%You need to use the paused 5s to enlarge the graphic form to avoid the first few frames of the video being too small.
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

%Reverse order£¨from outside to inside£©----------------------------TOOL 1
xa1=fliplr(xa);% X coordinate of the point£¨from outside to inside£©
ya1=fliplr(ya);% Y coordinate of the point
angle_a1=fliplr(angle_a);% Angle value of the point
% plot(xa1,ya1,'ro-','LineWidth',1);%draw the spiral path of tool 1


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
% pause(5);%Pause 5s to enlarge the graphic form, to avoid the first few frames of the video being too small.

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

%Calculate the DT,V and P at dwell points.(Adjust the value if the speed is too high)

[i_sp1,j_sp1,bDT1_a,brpm1_a,bP1_a,i_sp2,j_sp2,bDT2_a,brpm2_a,bP2_a]=Dwell_Sync_s(R0,R_h,sx,DT1_a,rpm1_a,P1_a,DT2_a,rpm2_a,P2_a,xa1,ya1,axa2,aya2);

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

writerObj=VideoWriter('In-Out feed with equal-angle path.avi');%make a movie
writerObj.FrameRate=20;
open(writerObj);

d_dt=0;%total Dwell time
for i=1:size(xa1,2)%
    Z0=zeros(mx,my);
    Z0((j_sp1(i)),i_sp1(i))=1;%from outside to inside (Tool 1 is at the right of workpiece)
    E1=conv2(Z0,bDT1_a(i)*brpm1_a(i)*bP1_a(i)*TIF1,'same');%2D Convolve for tool 1 %TIF1->donot rotate; TIF_1-> rotate
    H=H+E1; 
    
    Z0=zeros(mx,my);
    Z0((j_sp2(i)),i_sp2(i))=1;%from inside to outside (Tool 2 is at the middle of workpiece) 
    E2=conv2(Z0,bDT2_a(i)*brpm2_a(i)*bP2_a(i)*TIF2,'same');%2D Convolve for tool 2
    H=H+E2; 
    
    d_dt=d_dt+bDT1_a(i);%total Dwell time
    
    if (d_dt>710*i_t) || (i==size(xa1,2)) %(d_dt==sum(bDT1_a))
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
        title({['In-Out feed with equal-angle path'];['Total dwell time=',num2str(d_dt1),'h']});
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
        
        x_pt2=sqrt(axa2(i)^2+aya2(i)^2);
        x_dc2=R2*cos(c_theta)-x_pt2;
        y_dc2=R2*sin(c_theta)+0;
        z_dc2=100000*ones(size(x_dc2,2));%Make sure the circle is above the residual error map
        plot3(x_dc2,y_dc2,z_dc2,'-','color',[0.294 0.545 0.749],'linewidth',2);%draw the tool 2 size and location
        hold off;
        
         %dwell time
        subplot('position',[0.62,0.74,0.35,0.16]);
        plot(1:size(bDT1_a,2),bDT1_a,'-','color',[0.686 0.404 0.239],'linewidth',2);
        hold on;
        plot(1:size(bDT2_a,2),bDT2_a,'-','color',[0.294 0.545 0.749],'linewidth',1); 
        plot(i,bDT1_a(i),'r*','linewidth',3);%Point out the value of DT1_a in the dwelling point
        plot(i,bDT2_a(i),'b*','linewidth',1.5);%Point out the value of DT2_a in the dwelling point        
%         leg1=legend('tool_1','tool_2','Location','Best');
        leg1=legend('tool_1','tool_2','Location','North');
        set(leg1,'Orientation','horizon','FontSize',8);
        ylabel('Dwell time(s)');
        bDT1_a(i)=round(bDT1_a(i)*100)/100; 
        bDT2_a(i)=round(bDT2_a(i)*100)/100; 
        title(strcat('T_1^m=',num2str(bDT1_a(i)),'s        T_2^m=',num2str(bDT2_a(i)),'s'));
%         xlim([0,size(xa1,2)]);
        xlim([0,i]);
        hold off;
        
        %rpm
        subplot('position',[0.62,0.43,0.35,0.16]);
        plot(1:size(brpm1_a,2),brpm1_a,'-','color',[0.686 0.404 0.239],'linewidth',1);
        hold on;
        plot(1:size(brpm2_a,2),brpm2_a,'-','color',[0.294 0.545 0.749],'linewidth',1);
        plot(i,brpm1_a(i),'r*','linewidth',1.5);%Point out the value of DT1_a in the dwelling point
        plot(i,brpm2_a(i),'b*','linewidth',1.5);%Point out the value of DT2_a in the dwelling point        
        ylabel('Velocity(mm/s)');
        brpm1_a(i)=round(brpm1_a(i)*10)/10; 
        brpm2_a(i)=round(brpm2_a(i)*10)/10;
        title(strcat('V_1^m=',num2str(brpm1_a(i)),'mm/s        V_2^m=',num2str(brpm2_a(i)),'mm/s'));
%         xlim([0,size(xa1,2)]);
        xlim([0,i]);
        ylim([0,350]);
        hold off;
        set(gca,'ytick',[0:100:300]); 
        
        
        %contact pressure
        subplot('position',[0.62,0.12,0.35,0.16]);
        plot(1:size(bP1_a,2),bP1_a,'-','color',[0.686 0.404 0.239],'linewidth',1);
        hold on;     
        plot(1:size(bP2_a,2),bP2_a,'-','color',[0.294 0.545 0.749],'linewidth',1);
        plot(i,bP1_a(i),'r*','linewidth',1.5);%Point out the value of DT1_a in the dwelling point
        plot(i,bP2_a(i),'b*','linewidth',1.5);%Point out the value of DT2_a in the dwelling point        
        xlabel('Index of dwell points');
        ylabel('Contact pressure(psi)');
        bP1_a(i)=round(bP1_a(i)*100)/100; 
        bP2_a(i)=round(bP2_a(i)*100)/100;
        title(strcat('P_1^m=',num2str(bP1_a(i)),'psi        P_2^m=',num2str(bP2_a(i)),'psi'));
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

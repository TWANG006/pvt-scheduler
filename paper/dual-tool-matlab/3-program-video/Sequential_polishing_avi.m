% workpiece rotate. polishing tool 1 and tool 2 both on the right side of workpiece, and move from outside to inside.
% They polish the workpiece one after another. Tool 1 polish first, and tool 2 polish later.
% there is a hole in the middle of workpiece.

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

%Reverse order£¨from outside to inside£©
xa1=fliplr(xa);% X coordinate of the point£¨from outside to inside£©
ya1=fliplr(ya);% Y coordinate of the point
angle_a1=fliplr(angle_a);% Angle value of the point

% plot(xa1,ya1,'ro-','LineWidth',1);%draw the spiral
% pause(5);%Pause 5s to enlarge the graphic form, to avoid the first few frames of the video being too small.
%% 3.load data of DT1,rpm1,P1 and initial error map

load ('data\MRR1.mat');%TIF1
TIF1=imresize(MRR1,[mx1,my1]);
load ('data\MRR2.mat');%TIF2
TIF2=imresize(MRR2,[mx2,my2]);

load ('data\rpm1.mat');%rpm1
load ('data\DT1.mat');%DT1
load ('data\P1.mat');%P1
rpm1(find(isnan(rpm1)==1))=0;
DT1(find(isnan(DT1)==1))=0;
P1(find(isnan(P1)==1))=0;

load ('data\rpm2.mat');%rpm2
load ('data\DT2.mat');%DT2
load ('data\P2.mat');%P2
rpm2(find(isnan(rpm2)==1))=0;
DT2(find(isnan(DT2)==1))=0;
P2(find(isnan(P2)==1))=0;

%Calculate the DT,V and P at dwell points.

[i_sp1,j_sp1,cDT1,crpm1,cP1]=Spiral_Dwell(R0,R_h,sx,xa1,ya1,DT1,rpm1,P1);%Get the parameter value of the spiral points
[i_sp2,j_sp2,cDT2,crpm2,cP2]=Spiral_Dwell(R0,R_h,sx,xa1,ya1,DT2,rpm2,P2);%Get the parameter value of the spiral points

load ('data\removal_b.mat');%Removal data
removal_b(find(isnan(removal_b)==1))=0;
H=-removal_b;%initial error map

%% 4-1.2D Convolve,and calculate the residual error after tool 1 polished.=======TOOL 1==========

i_t1=1;%take a frame every certain number of dewll time
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

writerObj=VideoWriter('Sequential two single-tool polishing.avi');%make a movie
writerObj.FrameRate=20;
open(writerObj);

d_dt=0;%total Dwell time
for i=1:size(xa1,2)%
    Z0=zeros(mx,my);
    Z0((j_sp1(i)),i_sp1(i))=1;
    E=conv2(Z0,cDT1(i)*crpm1(i)*cP1(i)*TIF1,'same');%2D Convolve
    H=H+E;   
    d_dt=d_dt+cDT1(i);%total Dwell time
    
    if (d_dt>710*i_t1) || (i==size(xa1,2)) %(d_dt==(sum(cDT1)))
        i_t1=i_t1+1;
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
        title({['Sequential two single-tool run: Tool_1'];['Total dwell time=',num2str(d_dt1),'h']});
        set(gcf,'position',[600,300,720,480]);
        
        
        c_theta=0:pi/50:2*pi;
        x_pt1=sqrt(xa1(i)^2+ya1(i)^2);
        x_dc=R1*cos(c_theta)+x_pt1;
        y_dc=R1*sin(c_theta)+0;
        z_dc=100000*ones(size(x_dc,2));%Make sure the circle is above the residual error map
        hold on;
%         plot3(x_dc,y_dc,z_dc,'r:','linewidth',2);
        plot3(x_dc,y_dc,z_dc,'-','color',[0.686 0.404 0.239],'linewidth',2);%draw the tool 1 size and location
        hold off;        
        
        %dwell time
        subplot('position',[0.62,0.74,0.35,0.16]);
        plot(1:size(cDT1,2),cDT1,'-','color',[0.686 0.404 0.239],'linewidth',1);
        hold on;      
        plot(i,cDT1(i),'r*','linewidth',1.5);%Point out the value of DT1_a in the dwelling point       
        ylabel('Dwell time(s)');
        cDT1(i)=round(cDT1(i)*100)/100; 
        title(strcat('T_1^s=',num2str(cDT1(i)),'s'));
%         xlim([0,size(xa1,2)]);
        xlim([0,i]);
        hold off;
        
        %rpm
        subplot('position',[0.62,0.43,0.35,0.16]);
        plot(1:size(crpm1,2),crpm1,'-','color',[0.686 0.404 0.239],'linewidth',1);
        hold on;      
        plot(i,crpm1(i),'r*','linewidth',1.5);%Point out the value of DT1_a in the dwelling point     
        ylabel('Velocity(mm/s)');
        crpm1(i)=round(crpm1(i)*10)/10; 
        title(strcat('V_1^s=',num2str(crpm1(i)),'mm/s'));
%         xlim([0,size(xa1,2)]);
        xlim([0,i]);
        ylim([0,350]);
        hold off;
        set(gca,'ytick',[0:100:300]); 
        
        %contact pressure
        subplot('position',[0.62,0.12,0.35,0.16]);
        plot(1:size(cP1,2),cP1,'-','color',[0.686 0.404 0.239],'linewidth',1);
        hold on;     
        plot(i,cP1(i),'r*','linewidth',1.5);%Point out the value of DT1_a in the dwelling point       
        xlabel('Index of dwell points');
        ylabel('Contact pressure(psi)');
        cP1(i)=round(cP1(i)*100)/100; 
        title(strcat('P_1^s=',num2str(cP1(i)),'psi'));
%         xlim([0,size(xa1,2)]);
        xlim([0,i]);
        hold off;
        
        
        frame = getframe(gcf);
        frame.cdata=imresize(frame.cdata, [480 720]);
        writeVideo(writerObj,frame);
        
        if i==size(xa1,2) %repeat 1s at the end
            for i_repeat=1:15
               frame = getframe(gcf);
               frame.cdata=imresize(frame.cdata, [480 720]);
               writeVideo(writerObj,frame); 
            end
        end
        
    end    
end


%% 4-2.2D Convolve,and calculate the residual error after tool 2 polished.=======TOOL 2==========

i_t2=i_t1;%take a frame every certain number of dewll time
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

HH=H;%Removal data after tool 1 polished
for i=1:size(xa1,2)%
    Z0=zeros(mx,my);
    Z0((j_sp2(i)),i_sp2(i))=1;
    E=conv2(Z0,cDT2(i)*crpm2(i)*cP2(i)*TIF2,'same');%2D Convolve
    HH=HH+E;
    
    d_dt=d_dt+cDT2(i);%total Dwell time
    
    if (d_dt>710*i_t2) || (i==size(xa1,2))
        i_t2=i_t2+1;
        H1=imrotate(HH,360*angle_a1(i)/(2*pi),'crop');%rotate the H1(Show it in the video)
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
        title({['Sequential two single-tool run: Tool_2'];['Total dwell time=',num2str(d_dt1),'h']});
        set(gcf,'position',[600,300,720,480]);
        
        temp1=caxis;
        if temp1(2)<300
            caxis([-10 300]);%nm
        end
                
        c_theta=0:pi/50:2*pi;
        x_pt1=sqrt(xa1(i)^2+ya1(i)^2);
        x_dc=R2*cos(c_theta)+x_pt1;
        y_dc=R2*sin(c_theta)+0;
        z_dc=100000*ones(size(x_dc,2));%Make sure the circle is above the residual error map
        hold on;
        plot3(x_dc,y_dc,z_dc,'-','color',[0.294 0.545 0.749],'linewidth',2);%draw the tool 2 size and location
        hold off;
        
        
        %dwell time
        subplot('position',[0.62,0.74,0.35,0.16]);
        plot(1:size(cDT2,2),cDT2,'-','color',[0.294 0.545 0.749],'linewidth',1); 
        hold on;
        plot(i,cDT2(i),'b*','linewidth',1.5);%Point out the value of DT2_a in the dwelling point        
        ylabel('Dwell time(s)');
        cDT2(i)=round(cDT2(i)*100)/100; 
        title(strcat('T_2^s=',num2str(cDT2(i)),'s'));
%         xlim([0,size(xa1,2)]);
        xlim([0,i]);
        hold off;
        
        %rpm
        subplot('position',[0.62,0.43,0.35,0.16]); 
        plot(1:size(crpm2,2),crpm2,'-','color',[0.294 0.545 0.749],'linewidth',1);
        hold on;
        plot(i,crpm2(i),'b*','linewidth',1.5);%Point out the value of DT2_a in the dwelling point        
        ylabel('Velocity(mm/s)');
        crpm2(i)=round(crpm2(i)*10)/10; 
        title(strcat('V_2^s=',num2str(crpm2(i)),'mm/s'));
%         xlim([0,size(xa1,2)]);
        xlim([0,i]);
        ylim([0,350]);
        hold off;
        set(gca,'ytick',[0:100:300]); 
        
        %contact pressure
        subplot('position',[0.62,0.12,0.35,0.16]);
        plot(1:size(cP2,2),cP2,'-','color',[0.294 0.545 0.749],'linewidth',1);
        hold on;
        plot(i,cP2(i),'b*','linewidth',1.5);%Point out the value of DT2 in the dwelling point        
        xlabel('Index of dwell points');
        ylabel('Contact pressure(psi)');
        cP2(i)=round(cP2(i)*100)/100; 
        title(strcat('P_2^s=',num2str(cP2(i)),'psi'));
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

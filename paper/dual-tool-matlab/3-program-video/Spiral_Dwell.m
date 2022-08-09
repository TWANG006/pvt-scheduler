% Calculate the dwell time distribution of the spiral path. 
% Calculate the corresponding velocity(rpm) and contact stress(P) at the spiral points.

%Input:
%R0(radius of workpiece),R1(radius of tool),R_h(radius of the hole in the middle of workpiece),sx(spacing), 
%xa(X coordinate of the spiral point),ya(Y coordinate of the spiral point)
%DT(dwell matrix),rpm(velocity matrix),P(Contact pressure).

%Output:
%i_sp(The index of the spiral point on the X-direction),j_sp(The index of the spiral point on the Y-direction)
%cDT,crpm,cP(The DT,rpm,P parameters corresponding to spiral points)


function [i_sp,j_sp,cDT,crpm,cP]=Spiral_Dwell(R0,R_h,sx,xa,ya,DT,rpm,P)
%% 1.Input parameters.
% close all;
% clear;clc;


% R0=200;%radius of workpiece
% sx=2;%spacing
% R1=20;%radius of tool 1
% R_h=50;%radius of the hole in the middle of workpiece

x_s=R_h;%start point
x_e=R0;%end point

x=-R0:sx:R0;
[X,Y]=meshgrid(x,x);
mx=size(X,1);
my=size(X,2);

% x1=-R1:sx:R1;
% [X1,Y1]=meshgrid(x1,x1);
% mx1=size(X1,1);
% my1=size(X1,2);

%% 2.Find all the grids of dwelling points inside the workpiece.

% load ('data\xa1.mat');%xa1
% load ('data\ya1.mat');%ya1
% xa=xa1;
% ya=ya1;
% 
% load ('data\DT1.mat');%DT1
% load ('data\rpm1.mat');%rpm1
% load ('data\P1.mat');%P1
% DT1(find(isnan(DT1)==1))=0;
% rpm1(find(isnan(rpm1)==1))=0;
% P1(find(isnan(P1)==1))=0;
% DT=DT1;
% rpm=rpm1;
% P=P1;

k=0;
for i=1:mx
    for j=1:my
        if (X(i,j)^2+Y(i,j)^2<=x_e^2)&&(X(i,j)^2+Y(i,j)^2>=x_s^2)
            k=k+1;
            x_gr(k)=-R0+(j-1)*sx;% X coordinate of the center point of grid
            y_gr(k)=-R0+(i-1)*sx;% Y coordinate of the center point of grid
            i_gr(k)=j;%The index of the center point of grid on the X-direction
            j_gr(k)=i;%The index of the center point of grid on the Y-direction
            n_gr(k)=0;%Determine how many spiral points are inside the grid.
            DT_gr(k)=DT(i,j);
            rpm_gr(k)=rpm(i,j);
            P_gr(k)=P(i,j);
        end
    end
end


%% 3. Find out which grid the spiral point belongs to.

ind_s=zeros(1,size(xa,2));%Find out which grid the spiral point belongs to.
 
for i=1:size(xa,2)
    for j=1:size(x_gr,2)
        if ((xa(i)>=x_gr(j)-sx/2) && (xa(i)<x_gr(j)+sx/2)) && ((ya(i)>=y_gr(j)-sx/2) && (ya(i)<y_gr(j)+sx/2))
            n_gr(j)=n_gr(j)+1;%how many spiral points are inside the grid.
            ind_s(i)=j;%The grid number where the spiral point is.
        end
    end
end



%% 4. Solve the problem that the grid number is equal to 0.(ind_s(i)==0)
                
for i=1:size(xa,2)
    if ind_s(i)==0
        for j=1:size(x_gr,2)            
            length_gg(j)=sqrt((x_gr(j)-xa(i))^2+(y_gr(j)-ya(i))^2);%The distance between the spiral point and the grid point
        end
        j_gg=find(length_gg==min(min(length_gg)));%Spiral point number with the shortest distance from the grid
        ind_s(i)=j_gg;%The grid number where the spiral point is.
        n_gr(j_gg)=n_gr(j_gg)+1;%how many spiral points are inside the grid.       
    end        
end

%% 5. Distribution of dwell time.
cDT=zeros(1,size(xa,2));
crpm=zeros(1,size(xa,2));
cP=zeros(1,size(xa,2));

for i=1:size(xa,2)
    if ind_s(i)>0
        if n_gr(ind_s(i))>=1
            cDT(i)=DT_gr(ind_s(i))/n_gr(ind_s(i));
            crpm(i)=rpm_gr(ind_s(i));
            cP(i)=P_gr(ind_s(i));            
            i_sp(i)=i_gr(ind_s(i));%The index of the spiral point on the X-direction
            j_sp(i)=j_gr(ind_s(i));%The index of the spiral point on the Y-direction
        end
    end
end


for i=1:size(x_gr,2)
    if n_gr(i)==0
        for j=1:size(xa,2)
            length_sg(j)=sqrt((x_gr(i)-xa(j))^2+(y_gr(i)-ya(j))^2);%The distance between the spiral point and the grid point
        end
        j_gz=find(length_sg==min(min(length_sg)));%Spiral point number with the shortest distance from the grid
        cDT(j_gz)=cDT(j_gz)+DT_gr(i);
%         cDT(j_gz)=cDT(j_gz)+DT_gr(i)*rpm_gr(i)*P_gr(i)/(rpm_gr(ind_s(j_gz))*P_gr(ind_s(j_gz)));%%%%%%%
%         cDT(j_gz)=cDT(j_gz)+DT_gr(i)*rpm_gr(i)*P_gr(i)/(crpm(j_gz)*cP(j_gz));%%%%%%%
    end
end



% %% 6-1.load data of TIF and initial error map
% 
% load ('data\MRR.mat');%TIF
% TIF=imresize(MRR,[mx1,my1]);
% 
% 
% load ('data\Removal1.mat');%Removal data
% Removal1(find(isnan(Removal1)==1))=0;
% H=-Removal1;%initial error map
% 
% 
% for i=1:mx
%     for j=1:my
%         if X(i,j)^2+Y(i,j)^2<=R_h^2
%             H(i,j)=0;%there is a hole in the middle of workpiece.
%         end
%     end
% end
% 
% %% 6-2. 2D Convolve,and calculate the residual error.
% 
% % H=zeros(mx,my);%initial error map
% for i=1:size(cDT,2)%
%     Z0=zeros(mx,my);
%     Z0((j_sp(i)),i_sp(i))=1;
%     E=conv2(Z0,cDT(i)*crpm(i)*cP(i)*TIF,'same');%2D Convolve
%     H=H+E;                  
% end


% for i=1:mx
%     for j=1:my
%         if X(i,j)^2+Y(i,j)^2<=(R_h+0)^2%%%%%%%%%%%%%%15
%             H(i,j)=NaN;%there is a hole in the middle of workpiece.
%         end
%     end
% end
% for i=1:mx
%     for j=1:my
%         if X(i,j)^2+Y(i,j)^2>=(R0-0)^2%%%%%%%%%%%%5
%             H(i,j)=NaN;%
%         end
%     end
% end
% 
% subplot('position',[0.05,0.2,0.4,0.6]);
% surf(X,Y,H);
% shading interp;
% view([0 0 1]);
% colorbar;
% xlabel('x/mm');
% ylabel('y/mm');
% zlabel('residual error/mm');
% title('residual error');
% 
% %% 6-3. Drawing the DT, rpm and P graphs on the spiral path.
% 
% subplot('position',[0.5,0.7,0.4,0.25]);
% %dwell time
% plot(1:size(cDT,2),cDT,'r-','linewidth',2);      
% xlabel('Index of dwell point'), ylabel('dwell time/(s)')
% title('Dwell time in polishing path after adjustment');
% 
% subplot('position',[0.5,0.375,0.4,0.25]);
% %rpm
% plot(1:size(crpm,2),crpm,'r-','linewidth',1);
% xlabel('Index of dwell point'), ylabel('speed/(rpm)')
% title('Speed in polishing path after adjustment');
% % ylim([0,rpm2_max+50]);
% 
% subplot('position',[0.5,0.05,0.4,0.25]);
% %contact pressure
% plot(1:size(cP,2),cP,'r-','linewidth',1);
% xlabel('Index of dwell point'), ylabel('comtact pressure/(Mpa)')
% title('P values in polishing path after adjustment');


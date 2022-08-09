% Make sure the dwell time of Tool 2 is the same as that of Tool 1.
% Balance the speed for Tool 1 and Tool 2.(For 1D path)
% Make sure the maximum value of rpm1_a is not greater than rpm1_max.(0¡«rpm1_max)
% Make sure the maximum value of rpm2_a is not greater than rpm2_max.(0¡«rpm2_max)

function [i_sp1,j_sp1,bDT1_a,brpm1_a,bP1_a,i_sp2,j_sp2,bDT2_a,brpm2_a,bP2_a]=Dwell_Sync_s(R0,R_h,sx,DT1_a,rpm1_a,P1_a,DT2_a,rpm2_a,P2_a,xa1,ya1,axa2,aya2)
%% 1-1.Input the maps.
% close all;
% clear;clc;

% R0=200;%radius of workpiece
% R_h=50;%radius of the hole in the middle of workpiece
% sx=2;%spacing
rpm1_max=250;%Maximum speed of rpm1 allowed
rpm2_max=300;%Maximum speed of rpm2 allowed

x=-R0:sx:R0;
[X,Y]=meshgrid(x,x);
mx=size(X,1);
my=size(X,2);

% load ('data\DT1_a.mat');%DT1_a
% load ('data\rpm1_a.mat');%rpm1_a
% load ('data\P1_a.mat');%P1_a
% DT1_a(find(isnan(DT1_a)==1))=0;
% rpm1_a(find(isnan(rpm1_a)==1))=0;
% P1_a(find(isnan(P1_a)==1))=0;
% 
% load ('data\DT2_a.mat');%DT2_a
% load ('data\rpm2_a.mat');%rpm2_a
% load ('data\P2_a.mat');%P2_a
% DT2_a(find(isnan(DT2_a)==1))=0;
% rpm2_a(find(isnan(rpm2_a)==1))=0;
% P2_a(find(isnan(P2_a)==1))=0;
% 
% load ('data\xa1.mat');%xa1
% load ('data\ya1.mat');%ya1
% load ('data\axa2.mat');%axa2
% load ('data\aya2.mat');%aya2

mmx=size(xa1,2);

%% 1-2.Calculate the datas on the spiral paths

[i_sp1,j_sp1,cDT1,crpm1,cP1]=Spiral_Dwell(R0,R_h,sx,xa1,ya1,DT1_a,rpm1_a,P1_a);%Get the parameter value of the spiral points
[i_sp2,j_sp2,cDT2,crpm2,cP2]=Spiral_Dwell(R0,R_h,sx,axa2,aya2,DT2_a,rpm2_a,P2_a);%Get the parameter value of the spiral points

for i=1:mmx
    aDT1_a(i)=cDT1(i);
    aDT2_a(i)=cDT1(i);%Tool 2 has the same dwell time as Tool 1 (Or the dwell time of Tool 2 on the outside)
    
    arpm1_a(i)=crpm1(i);
    arpm2_a(i)=crpm2(i)*cDT2(i)/cDT1(i);%
    
    aP1_a(i)=cP1(i);
    aP2_a(i)=cP2(i);
end;

%% 1-3. drawing.

% %dwell time
% subplot(3,1,1);
% plot(1:size(aDT1_a,2),aDT1_a,'r-','linewidth',2);
% hold on;
% plot(1:size(aDT2_a,2),aDT2_a,'g-','linewidth',1);        
% legend('dwell time of too11','dwell time of too12');
% xlabel('Index of dwell point'), ylabel('dwell time/(s)')
% title('Dwell time in polishing path');
% hold off;
% 
% %rpm
% subplot(3,1,2);
% plot(1:size(arpm1_a,2),arpm1_a,'r-','linewidth',1);
% hold on;
% plot(1:size(arpm2_a,2),arpm2_a,'g-','linewidth',1);             
% legend('speed of too11','speed of too12');
% xlabel('Index of dwell point'), ylabel('speed/(rpm)')
% title('Speed in polishing path');
% %ylim([0,300]);
% hold off;
% 
% %contact pressure
% subplot(3,1,3);
% plot(1:size(aP1_a,2),aP1_a,'r-','linewidth',1);
% hold on;
% plot(1:size(aP2_a,2),aP2_a,'g-','linewidth',1);             
% legend('Contact pressure of too11','Contact pressure of too12');
% xlabel('Index of dwell point'), ylabel('comtact pressure/(Mpa)')
% title('P values in polishing path');
% hold off;
        

%% 1-4.Balance the speed of rpm1 and rpm2

bDT1_a=aDT1_a;%the parameters after adjusted.
bDT2_a=aDT2_a;
brpm1_a=arpm1_a;
brpm2_a=arpm2_a;
bP1_a=aP1_a;
bP2_a=aP2_a;

b_rpm1_h=0;%if the speed of rpm1 too high, b_rpm1_h=1
b_rpm2_h=0;%if the speed of rpm2 too high, b_rpm2_h=1

k=1;%Number of iterations
psi=2;%modified coefficient of rotated speed,¦×

delta_rpm1=zeros(1,mmx);%adjustment value of rpm1(i,j)(if the speed of rpm1 at this point is too high)
delta_rpm2=zeros(1,mmx);%adjustment value of rpm2(i,j)(if the speed of rpm2 at this point is too high)

b_rpm1_f=zeros(1,mmx);%if the value=1, it means the speed of rpm1 at this point does not need to be adjusted.
b_rpm2_f=zeros(1,mmx);%if the value=1, it means the speed of rpm2 at this point does not need to be adjusted.


for i=1:mmx
    if (X(j_sp1(i),i_sp1(i))^2+Y(j_sp1(i),i_sp1(i))^2>R0^2)
        b_rpm1_f(i)=1;%No adjustment is required outside the workpiece
    end
end

for i=1:mmx
    if (X(j_sp2(i),i_sp2(i))^2+Y(j_sp2(i),i_sp2(i))^2>R0^2)
        b_rpm2_f(i)=1;%No adjustment is required outside the workpiece
    end
end


while 1
    %Judge if the speed of rpm1 or rpm2 is too high    
    for i=1:mmx
        if brpm1_a(i)>rpm1_max
            b_rpm1_h=1;
        end
        if brpm2_a(i)>rpm2_max
            b_rpm2_h=1;
        end
    end
    
    
    if (all(b_rpm1_f==1)&&all(b_rpm2_f==1)) %No adjustment is required of all point in rpm1 and rpm2
        break;
    end
    
    if (b_rpm1_h==0)&&(b_rpm2_h==0) %if the speed of rpm1 and rpm2 are not too high. (both within certain range)
        break;
    end
    k=k+1;%Number of iterations    
    
    
    %Make sure the value of rpm2_a is between 0¡«rpm2_max %%%%%%%%%%%%%%%%
    for i=1:mmx
        if (delta_rpm2(i)>=rpm2_max)||(round(brpm2_a(i)*1000)/1000<=rpm2_max)%if the speed of rpm2 is between 0¡«rpm2_max
            b_rpm2_f(i)=1;%It means the speed at the point do not need to change
        end
        if (b_rpm2_f(i)==0)&&(round(brpm2_a(i)*1000)/1000>rpm2_max) % make sure the value of rpm2_a is not greater than 250             
            brpm2_a(i)=rpm2_max-delta_rpm2(i);
            bDT2_a(i)=aDT2_a(i).*(arpm2_a(i)./brpm2_a(i));   
%             delta_rpm2(i)=delta_rpm2(i)+psi;
        end
    end
    bDT1_a=bDT2_a;%dwell time of tool 1 equal dwell time of tool 2
    brpm1_a=arpm1_a.*(aDT1_a./bDT1_a);
    

    
    %Make sure the value of rpm1_a is between 0¡«rpm1_max %%%%%%%%%%%%%%%
    for i=1:mmx
        if (delta_rpm1(i)>=rpm1_max)||(round(brpm1_a(i)*1000)/1000<=rpm1_max)%if the speed of rpm2 is between 0¡«rpm1_max
            b_rpm1_f(i)=1;%It means the speed at the point do not need to change
        end
        if (b_rpm1_f(i)==0)&&(round(brpm1_a(i)*1000)/1000>rpm1_max) % make sure the value of rpm1_a is not greater than 200 
            brpm1_a(i)=rpm1_max-delta_rpm1(i);
            bDT1_a(i)=aDT1_a(i).*(arpm1_a(i)./brpm1_a(i)); 
%             delta_rpm1(i)=delta_rpm1(i)+psi;
        end
    end
    bDT2_a=bDT1_a;%dwell time of tool 2 equal dwell time of tool 1
    brpm2_a=arpm2_a.*(aDT2_a./bDT2_a);
    
    
    b_rpm1_h=0;%
    b_rpm2_h=0;%

end;

%% 1-4. Redrawing.

% figure;
% %dwell time
% subplot(3,1,1);
% plot(1:size(bDT1_a,2),bDT1_a,'r-','linewidth',2);
% hold on;
% plot(1:size(bDT2_a,2),bDT2_a,'g-','linewidth',1);        
% legend('dwell time of too11','dwell time of too12');
% xlabel('Index of dwell point'), ylabel('dwell time/(s)')
% title('Dwell time in polishing path after adjustment');
% hold off;
% 
% %rpm
% subplot(3,1,2);
% plot(1:size(brpm1_a,2),brpm1_a,'r-','linewidth',1);
% hold on;
% plot(1:size(brpm2_a,2),brpm2_a,'g-','linewidth',1);             
% legend('speed of too11','speed of too12');
% xlabel('Index of dwell point'), ylabel('speed/(rpm)')
% title('Speed in polishing path after adjustment');
% ylim([0,rpm2_max+50]);
% hold off;
% 
% %contact pressure
% subplot(3,1,3);
% plot(1:size(bP1_a,2),bP1_a,'r-','linewidth',1);
% hold on;
% plot(1:size(bP2_a,2),bP2_a,'g-','linewidth',1);             
% legend('Contact pressure of too11','Contact pressure of too12');
% xlabel('Index of dwell point'), ylabel('comtact pressure/(Mpa)')
% title('P values in polishing path after adjustment');
% hold off;


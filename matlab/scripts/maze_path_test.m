clear;
close all;
clc;
addpath(genpath('../functions'));

%% input parameters.
rou=5;
dx=0.5; % half step [mm]
dy=dx;
l=(4*rou-2)*dx; % workpiece length [mm]
w=(4*rou-2)*dx; % workpiece width

% l = 19; % workpiece length [mm]
% w = l;  % workpiece width
% dx=0.5; % half step [mm]
% dy=dx;
% rou = l/(4*dx)+0.5;

x=-dx-l/2:dx:l/2+dx;
y=-dy-w/2:dy:w/2+dy;
[X,Y]=meshgrid(x,y);

%% generate a maze path.
maze=squareMaze(rou);
maze(find(maze~=2))=1; % passage = 1
maze(find(maze==2))=0; % wall = 0
A=maze(3:2*rou+1,3:2*rou+1);
% A=[1 0 1 1 1;1 0 1 0 1;1 0 1 0 1;1 0 0 0 1;1 1 1 1 1];
MN=size(A);
m=MN(1);n=MN(2);
temp1=zeros(2*m+1,n);
temp1(2:2:end,:)=A;
temp2=zeros(2*m+1,2*n+1);
temp2(:,2:2:end)=temp1;
for i=2:2*m
    for j=2:2*n   
        if ((temp2(i-1,j)==1)&&(temp2(i+1,j)==1))||((temp2(i,j-1)==1)&&(temp2(i,j+1)==1))
            temp2(i,j)=1;
        end        
    end
end
temp3=zeros(2*m+3,2*n+3);
temp3(2:2*m+2,2:2*n+2)=temp2;
for i=2:2*m+2
    for j=2:2*n+2              
        if (temp3(i,j)==0)&&...
                ((temp3(i-1,j)==1)||(temp3(i-1,j+1)==1)||(temp3(i,j+1)==1)||...
                (temp3(i+1,j+1)==1)||(temp3(i+1,j)==1)||(temp3(i+1,j-1)==1)...
                ||(temp3(i,j-1)==1)||(temp3(i-1,j-1)==1))
            temp3(i,j)=2;
        end        
    end
end

tempPath=temp3;
tempPath(find(tempPath==1))=0;
tempPath(find(tempPath==2))=1;
nn=size(tempPath);
xn=nn(1);yn=nn(2);
NotVisited=-2;
Visited=2;
Room=NotVisited*ones(xn,yn);
currentP=sub2ind(size(tempPath),2,4);
S=[sub2ind(size(tempPath),2,2) sub2ind(size(tempPath),2,3) currentP];
Room(S)=Visited;
offset=[-1, xn, 1, -yn];
while (~isempty(currentP))
    moves = currentP+offset;
    if (~isempty(Room(moves)==NotVisited))&&(~isempty(tempPath(moves)==1))
         tempnext=find(Room(moves)==NotVisited);
         tempt=moves(tempnext);
         next=find(tempPath(tempt)==1);
         
         newP = tempt(next);
         S=[S newP];
         currentP=newP;
         Room(currentP)=Visited;      
    else
        break;       
    end   
end

%% plot
PATHX=X(S(1:2:end));
PATHY=Y(S(1:2:end));
Dx=PATHX; % 
Dy=PATHY;
Dx=Dx+l/2;Dy=Dy+w/2; % Set the origin at the lower left corner. Comment this code if need to set it in the center.

xp = []; % dwell points
yp = [];
for i = 1: size(Dx,2) - 1
    if Dy(i) == Dy(i+1)
        xp(i) = (Dx(i) + Dx(i+1))/2;
        yp(i) = Dy(i);
    end
    if Dx(i) == Dx(i+1)
        xp(i) = Dx(i);
        yp(i) = (Dy(i) + Dy(i+1))/2;
    end   
end

if Dx(1) == Dx(size(Dx,2))
    xp = [xp, Dx(1)];
    yp = [yp, (Dy(1)+Dy(size(Dy,2)))/2];
end
if Dy(1) == Dy(size(Dy,2))
    xp = [xp, (Dx(1)+Dx(size(Dx,2)))/2];
    yp = [yp, Dy(1)];
end


plot(Dx,Dy,'*-','linewidth',2);  
% hold on
% plot(xp,yp,'o','linewidth',2);  

% set(gca,'xcolor', 'none');
% set(gca,'xticklabel',[])
% set(gca,'xtick',[])

axis off;
% clear;clc;
%  n=5;%%表示一个方向上存在的单元数目
function M = squareMaze(n)
    showProgress = false;
%    n=5;%%表示一个方向上存在的单元数目
  
    %%用于显示迷宫图用
    colormap([1,1,1;1,1,1;0,0,0]);
    set(gcf,'color','w');
    %%用于显示迷宫图用
 
    NoWALL      = 0;
    WALL        = 2;
    NotVISITED  = -1;
    VISITED     = -2;
 
    m = 2*n+3;%一个单元可用一格表示，一段墙壁也用一格表示，在周围各增加两格，故每条边总数为2n+3
    M = NotVISITED(ones(m));%初始化所有单元为未遍历的单元
    offsets = [-1, m, 1, -m];%设置四个方向偏移时的移动索引值
 
    M([1 2:2:end end],:) = WALL;%周围1圈及中间隔行设为墙，横向
    M(:,[1 2:2:end end]) = WALL;%周围1圈及中间隔行设为墙；纵向
                                %%此时就可以看出每个单元房间
    currentCell = sub2ind(size(M),3,3);%%设定左上角的第一个单元为起始房间
    M(currentCell) = VISITED;%并标记为已遍历
 
    S = currentCell;%存储路径
 
    while (~isempty(S))
        moves = currentCell + 2*offsets;%当前单元对应的上右下左方向（顺时针）四个单元在M中的索引值
        unvistedNeigbors = find(M(moves)==NotVISITED);%确定四个隔壁方向单元中未经过的单元在moves中的索引
 
        if (~isempty(unvistedNeigbors))%如果隔壁的单元中存在未经过的单元
%            %next = unvistedNeigbors(randi(length(unvistedNeigbors),1));%确定下一个移动的目标单元的在
            %未经过的几个单元中的相对位置，可能是1或2或3或4  %%randi在matlab低版本中不能用，用下面语句代替
             next = unvistedNeigbors(unidrnd(length(unvistedNeigbors)));
                    %unidrnd(length(unvistedNeigbors))产生一个1到length(unvistedNeigbors)之间的整数
            
            M(currentCell + offsets(next)) = NoWALL;%确定下一个目标单元之后，将两个单元之间的墙拆掉
 
            newCell = currentCell + 2*offsets(next);%移动到这个目标单元，确定这个目标单元在M中的索引
            if (any(M(newCell+2*offsets)==NotVISITED))%如果新单元周围四个方向的单元中存在未经过的单元
                S = [S newCell];%记录经过的路径
            end
 
            currentCell = newCell;%将新单元作为重新作为当前单元
            M(currentCell) = VISITED;%将新单元标记为已经过
        else                             %如果隔壁的单元中不存在未经过的单元
            %%这部分语句主要是当路径走到死胡同了，隔壁单元都被经过了，但是中间还有未被
            %%经过的单元时，沿着原路返回路径，直至全部单元都被遍历过，若发现村子啊未遍历的
            %%单元，则执行上部分过程
            currentCell = S(1);%将当前的单元索引置为第一个经过的单元位置索引
            S = S(2:end);%
        end
 
%         if (showProgress)
%             image(M-VISITED);
%             axis equal off;
%             drawnow;
%             pause(.01);
%         end
    end
    %%用于显示迷宫图用
    PM=M-VISITED;
    set(gcf,'color','w');
    image(PM);
    axis equal off;
    %%用于显示迷宫图用
% M(find(M~=2))=1;
% M(find(M==2))=0;
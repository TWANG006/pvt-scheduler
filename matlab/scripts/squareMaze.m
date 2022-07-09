% clear;clc;
%  n=5;%%��ʾһ�������ϴ��ڵĵ�Ԫ��Ŀ
function M = squareMaze(n)
    showProgress = false;
%    n=5;%%��ʾһ�������ϴ��ڵĵ�Ԫ��Ŀ
  
    %%������ʾ�Թ�ͼ��
    colormap([1,1,1;1,1,1;0,0,0]);
    set(gcf,'color','w');
    %%������ʾ�Թ�ͼ��
 
    NoWALL      = 0;
    WALL        = 2;
    NotVISITED  = -1;
    VISITED     = -2;
 
    m = 2*n+3;%һ����Ԫ����һ���ʾ��һ��ǽ��Ҳ��һ���ʾ������Χ���������񣬹�ÿ��������Ϊ2n+3
    M = NotVISITED(ones(m));%��ʼ�����е�ԪΪδ�����ĵ�Ԫ
    offsets = [-1, m, 1, -m];%�����ĸ�����ƫ��ʱ���ƶ�����ֵ
 
    M([1 2:2:end end],:) = WALL;%��Χ1Ȧ���м������Ϊǽ������
    M(:,[1 2:2:end end]) = WALL;%��Χ1Ȧ���м������Ϊǽ������
                                %%��ʱ�Ϳ��Կ���ÿ����Ԫ����
    currentCell = sub2ind(size(M),3,3);%%�趨���Ͻǵĵ�һ����ԪΪ��ʼ����
    M(currentCell) = VISITED;%�����Ϊ�ѱ���
 
    S = currentCell;%�洢·��
 
    while (~isempty(S))
        moves = currentCell + 2*offsets;%��ǰ��Ԫ��Ӧ������������˳ʱ�룩�ĸ���Ԫ��M�е�����ֵ
        unvistedNeigbors = find(M(moves)==NotVISITED);%ȷ���ĸ����ڷ���Ԫ��δ�����ĵ�Ԫ��moves�е�����
 
        if (~isempty(unvistedNeigbors))%������ڵĵ�Ԫ�д���δ�����ĵ�Ԫ
%            %next = unvistedNeigbors(randi(length(unvistedNeigbors),1));%ȷ����һ���ƶ���Ŀ�굥Ԫ����
            %δ�����ļ�����Ԫ�е����λ�ã�������1��2��3��4  %%randi��matlab�Ͱ汾�в����ã�������������
             next = unvistedNeigbors(unidrnd(length(unvistedNeigbors)));
                    %unidrnd(length(unvistedNeigbors))����һ��1��length(unvistedNeigbors)֮�������
            
            M(currentCell + offsets(next)) = NoWALL;%ȷ����һ��Ŀ�굥Ԫ֮�󣬽�������Ԫ֮���ǽ���
 
            newCell = currentCell + 2*offsets(next);%�ƶ������Ŀ�굥Ԫ��ȷ�����Ŀ�굥Ԫ��M�е�����
            if (any(M(newCell+2*offsets)==NotVISITED))%����µ�Ԫ��Χ�ĸ�����ĵ�Ԫ�д���δ�����ĵ�Ԫ
                S = [S newCell];%��¼������·��
            end
 
            currentCell = newCell;%���µ�Ԫ��Ϊ������Ϊ��ǰ��Ԫ
            M(currentCell) = VISITED;%���µ�Ԫ���Ϊ�Ѿ���
        else                             %������ڵĵ�Ԫ�в�����δ�����ĵ�Ԫ
            %%�ⲿ�������Ҫ�ǵ�·���ߵ�����ͬ�ˣ����ڵ�Ԫ���������ˣ������м仹��δ��
            %%�����ĵ�Ԫʱ������ԭ·����·����ֱ��ȫ����Ԫ�����������������ִ��Ӱ�δ������
            %%��Ԫ����ִ���ϲ��ֹ���
            currentCell = S(1);%����ǰ�ĵ�Ԫ������Ϊ��һ�������ĵ�Ԫλ������
            S = S(2:end);%
        end
 
%         if (showProgress)
%             image(M-VISITED);
%             axis equal off;
%             drawnow;
%             pause(.01);
%         end
    end
    %%������ʾ�Թ�ͼ��
    PM=M-VISITED;
    set(gcf,'color','w');
    image(PM);
    axis equal off;
    %%������ʾ�Թ�ͼ��
% M(find(M~=2))=1;
% M(find(M==2))=0;
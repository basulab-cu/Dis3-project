function [mat, range] = sparse2mat(sp, resol, type,na2zero)
% type: 0---rectangle
%       1---triangle
%       2---square
%       3---square, start from 0
%       4---rectangle, start from 0
% written by Wanwei Zhang
if nargin<3
    type = 0;
end

if na2zero==1
    factor = 0;
else
    factor = nan;
end

range1 = [min(sp(:,1)),max(sp(:,1))];
range2 = [min(sp(:,2)),max(sp(:,2))];

if type == 0
    spIdx = sp(:,1:2)/resol;
    
    minIdx = min(spIdx);
    spIdx = spIdx-repmat(minIdx,size(spIdx,1),1)+1;

    mat = nan*zeros(max(spIdx));
    for i = 1:size(spIdx,1)
        mat(spIdx(i,1),spIdx(i,2)) = sp(i,3);
    end
    %{
    mat(sub2ind(size(mat),spIdx(:,1),spIdx(:,2))) = sp(:,3);
    %}
    
    % overlap region
    [temp,idx] = sort([range1,range2]);
    if sum(idx(1:2))>3 && sum(idx(1:2))<7
        idx1 = (temp(2):resol:temp(3))/resol-minIdx(1)+1;
        idx2 = (temp(2):resol:temp(3))/resol-minIdx(2)+1;
        mat_tmp = mat(idx1,idx2);
        %{
        temp = mat_tmp';
        idx = tril(ones(size(mat_tmp)),-1)==1;
        mat_tmp(idx) = temp(idx);
        %}
        for i = 1:size(mat_tmp,1)
            for j = 1:size(mat_tmp,2)
                if isnan(mat_tmp(i,j))
                    mat_tmp(i,j) = mat_tmp(j,i);
                end
            end
        end
        mat(idx1,idx2) = mat_tmp;
    end
    range = [range1;range2];
    
    if na2zero==1
        mat(isnan(mat)) = 0;
    end
end

if type == 1
    idx = sp(:,1:2)/resol;
    
    temp = range1(2)-range1(1)+range2(2)-range2(1);
    if (range1(2)-range2(1))<=temp && (range2(2)-range1(1))<=temp % overlap
        idx = idx-min(idx(:))+1;
    else
        minIdx = min(idx);
        maxIdx = max(idx);
        idx_tmp = min(minIdx) == minIdx;
        idx(:,idx_tmp) = idx(:,idx_tmp)-minIdx(idx_tmp)+1;
        idx(:,~idx_tmp) = idx(:,~idx_tmp)-minIdx(~idx_tmp)+maxIdx(idx_tmp)+1;
    end

    mat = factor*zeros(max(idx(:)),2*max(idx(:)));
    for i = 1:size(idx,1)
        mat(end-abs(idx(i,1)-idx(i,2)),idx(i,1)+idx(i,2)) = sp(i,3);
        mat(end-abs(idx(i,1)-idx(i,2)),idx(i,1)+idx(i,2)-1) = sp(i,3);
    end
    range = [range1;range2]';
end

if type == 2
    range = [min(reshape(sp(:,1:2),[],1)),...
        max(reshape(sp(:,1:2),[],1))];
    spIdx = sp(:,1:2)/resol;
    
    minIdx = min(spIdx(:));
    spIdx = spIdx-repmat(minIdx,size(spIdx,1),size(spIdx,2))+1;

    mat = factor*zeros(max(spIdx(:)));
    for i = 1:size(spIdx,1)
        mat(spIdx(i,1),spIdx(i,2)) = sp(i,3);
    end
    %{
    mat(sub2ind(size(mat),spIdx(:,1),spIdx(:,2))) = sp(:,3);
    %}
end

if type == 3
    spIdx = sp(:,1:2)/resol+1;
    
    mat = factor*zeros(max(spIdx(:)));
    for i = 1:size(spIdx,1)
        mat(spIdx(i,1),spIdx(i,2)) = sp(i,3);
    end
    %{
    mat(sub2ind(size(mat),spIdx(:,1),spIdx(:,2))) = sp(:,3);
    %}
    range = [0,max(reshape(sp(:,1:2),[],1))];
end

if type == 4
    range1 = [0,max(sp(:,1))];
    range2 = [0,max(sp(:,2))];

    spIdx = sp(:,1:2)/resol+1;
    
    mat = factor*zeros(max(spIdx));
    for i = 1:size(spIdx,1)
        mat(spIdx(i,1),spIdx(i,2)) = sp(i,3);
    end
    range = [range1;range2];
end

if na2zero==1
    mat(isnan(mat)) = 0;
end

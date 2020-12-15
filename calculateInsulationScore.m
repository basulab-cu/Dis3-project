function [Ins,Ins_norm,Ins_norm_log2] = calculateInsulationScore(dumpedFiles,window,resolution)
% dumpedFiles: name of files that are dumped by juicer tools
% window: block width (nt) for calculation
% resolution: one of 5000, 10000, 25000, 50000, 100000, 
%               250000, 500000, 1000000 and 2500000
% written by Wanwei Zhang

%{
% example
dumpedFiles = strcat('./example data/',{'Dis3_Het_chr1','Dis3_CC_chr1';'Dis3_Het_chr2','Dis3_CC_chr2'},'.txt');
window = 200000;
resolution = 10000;
%}

parpool(8);

% infer resolution from data if not specified
if isempty(resolution)
    temp = readtable(dumpedFiles{1},...
        'delimiter','\t','readvar',0);
    temp = unique(temp.(1));
    resolution = min(temp(2:end)-temp(1:end-1));
end

Ins = cell(size(dumpedFiles,1),1);
nbin = window/resolution;
parfor ic = 1:size(dumpedFiles,1)
    
    % read in dumped data
    mats = cell(size(dumpedFiles,2),1);
    for is = 1:size(dumpedFiles,2)
        fprintf(['Processing ',dumpedFiles{ic,is},'...\n']);
        temp = readtable(dumpedFiles{ic,is},'delimiter','\t','readvar',0);
        mats{is} = temp{:,:};
    end
    
    % get range of hic data
    temp = cell2mat(mats);
    range = [min(min(temp(:,1:2))),max(max(temp(:,1:2)))];
    
    % 
    ins = (range(1)+window:resolution:range(2)-window)';
    siz = (range(2)-range(1))/resolution+1;
    for is = 1:numel(mats)
        mat = mats{is};
        mat(:,1:2) = (mat(:,1:2)-range(1))/resolution+1;
        mat_sp = sparse(mat(:,1),mat(:,2),mat(:,3),siz,siz);
        for i = 1:size(ins,1)
                ins(i,is+1) = mean2(mat_sp(i-1+(1:nbin),...
                    i+(1:nbin)+nbin));
        end
    end
    Ins{ic} = ins;
end
Ins = cell2table(Ins);

Ins_norm = Ins;
Ins_norm_log2 = Ins;
for ic = 1:size(Ins_norm_log2,1)
    ins = Ins.(1){ic};
    ins(:,2:end) = ins(:,2:end)./repmat(median(ins(:,2:end),'omitnan'),size(ins,1),1);
    Ins_norm.(1){ic} = ins;
    ins(:,2:end) = log2(ins(:,2:end));
    Ins_norm_log2.(1){ic} = ins;
end


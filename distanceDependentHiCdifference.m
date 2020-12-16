%% distance difference analysis
% written by Wanwei Zhang

resolut = 1000000;
chrs = strcat('chr',[cellfun(@num2str,num2cell((1:19)'),'unif',0);{'X'}]);
chrs = cell2table(chrs,'row',chrs);
type = 'observed';
norm = 'KR';

% dump HiC
for is = 1:size(samples,1)
    hicFile = [workDir,'hic/',samples.name{is},'.q30.hic'];
    dumpDir = [workDir,'dump/',samples.name{is},'_','q30',...
        '_',type,'_',norm,'_',num2str(resolut),'/'];
    dumpHicChr(hicFile,dumpDir,'mode',1,'type',type,...
        'normal',norm,'resol',resolut,'chr',chrs.Row);
end


% get total
totals = zeros(size(samples,1),1);
for ic = 1:size(chrs,1)
    fprintf('ic=%d\n',ic);
    for jc = ic:size(chrs,1)
        chr1 = chrs.Row{ic};
        chr2 = chrs.Row{ic};
        
        for is = 1:size(samples,1)
            % read in dumped data
            dumpDir = [workDir,'dump/',samples.name{is},'_','q30',...
                '_',type,'_',norm,'_',num2str(resolut),'/'];
            txtFile = [dumpDir,chr1,'_',chr2,'.txt'];
            temp = readtable(txtFile,'delimiter','\t','readvar',0);
            totals(is) = totals(is)+sum(temp.(3),'omitnan');
        end
    end
end
factor = totals./totals(1);

mu = nan*zeros(200,size(chrs,1));
sd = nan*zeros(200,size(chrs,1));
mu_raw = nan*zeros(200,size(chrs,1),2);
sd_raw = nan*zeros(200,size(chrs,1),2);
ratio = 0.9;
for ic = 1:size(chrs,1)
    fprintf('ic=%d\n',ic);
    chr = chrs.Row{ic};
    
    % read in dumped data
    mats = cell(size(samples,1),1);
    for is = 1:size(samples,1)
        dumpDir = [workDir,'dump/',samples.name{is},'_','q30',...
            '_',type,'_',norm,'_',num2str(resolut),'/'];
        txtFile = [dumpDir,chr,'_',chr,'.txt'];
        temp = readtable(txtFile,'delimiter','\t','readvar',0);
        mats{is} = sparse2mat(temp{:,:},resolut,3,1);
        mats{is} = mats{is}./factor(is);
    end
    n = max(cellfun(@(x)size(x,1),mats));
    for i = 1:numel(mats)
        temp = zeros(n);
        temp(1:size(mats{i},1),1:size(mats{i},2)) = mats{i};
        mats{i} = temp;
    end
    for is = 1:numel(mats)
        mat = mats{is};
        for i = 1:round(n*ratio)
            temp = diag(mat,i-1);
            temp(isnan(temp)) = [];
            mu_raw(i,ic,is) = mean(temp);
            sd_raw(i,ic,is) = std(temp);
        end
    end
    mat = log2(mats{2}./mats{1});
    for i = 1:round(n*ratio)
        temp = diag(mat,i-1);
        temp(isnan(temp)|isinf(temp)) = [];
        mu(i,ic) = mean(temp);
        sd(i,ic) = std(temp);
    end
end

figure;plot(mu(:,:));
hold on;
plot(mean(mu(1:100,:),2,'omitnan'),'-k','LineWidth',2);
set(gca,'ylim',[-0.5,0.5],'xlim',[0,100]);

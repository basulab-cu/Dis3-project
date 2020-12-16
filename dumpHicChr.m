function dumpHicChr(hicFile,dumpDir,varargin)
% dump .hic files chromosome wise
% other parameters:
% 'type': 'observed' or 'oe'
% 'normalization': 'NONE', 'VC', 'VC_SQRT' or 'KR'
% 'resolution': 5000, 10000, 25000, 50000, 100000, 
%               250000, 500000, 1000000 or 2500000
% 'chromosome': name(s) of chromosome(s), e.g. 'chr1';
%               {'chr1','chr2'}
% 'mode': 0---intra-chromosome
%         1---inter-chromosome
% 'prefix': prefix of each dumped file name
% 'suffix': suffix of each dumped file name
% written by Wanwei Zhang

% build argument table
args = [];
args = addArgument(args,'type','observed',...
    'acceptableValues',{'observed','oe'});
args = addArgument(args,'normalization','KR',...
    'acceptableValues',{'NONE', 'VC', 'VC_SQRT', 'KR'});
args = addArgument(args,'resolution',10000,...
    'acceptableValues',[5000, 10000, 25000, 50000, 100000, ...
    250000, 500000, 1000000, 2500000]);
args = addArgument(args,'chromosome',[],'type',{'char','cell'});
args = addArgument(args,'mode',0);
args = addArgument(args,'prefix','');
args = addArgument(args,'suffix','');

args = setArgument(args,varargin{:});

if isempty(args.value{'chromosome'})
    error('Must supply chromosome name!')
end

if ischar(args.value{'chromosome'})
    args.value{'chromosome'} = {args.value{'chromosome'}};
end

if ~exist(dumpDir,'dir')
    mkdir(dumpDir)
end

type = args.value{'type'};
norm = args.value{'normalization'};
chrs = args.value{'chromosome'};
mode = args.value{'mode'};
prefix = args.value{'prefix'};
suffix = args.value{'suffix'};
resolut = args.value{'resolution'};
if mode==0
    for ic = 1:size(chrs,1)
            fprintf('ic=%d\n',ic);
        chr = chrs{ic};
        txtFile = [dumpDir,prefix,chr,suffix,'.txt'];
        cmd = ['juicer_tools dump ',type,' ',norm,' ',hicFile,...
            ' ',chr,' ',chr,' BP ',num2str(resolut),' ',txtFile];
        [status,cmdOut] = system(cmd);
    end
elseif mode==1
    for ic = 1:size(chrs,1)
        chr = chrs{ic};
        for jc = ic:size(chrs,1)
            fprintf('ic=%d,jc=%d\n',ic,jc);
            chr2 = chrs{jc};
            txtFile = [dumpDir,prefix,chr,'_',chr2,suffix,'.txt'];
            cmd = ['juicer_tools dump ',type,' ',norm,' ',...
                hicFile,' ',chr,' ',chr2,' BP ',...
                num2str(resolut),' ',txtFile];
            [status,cmdOut] = system(cmd);
        end
    end
end

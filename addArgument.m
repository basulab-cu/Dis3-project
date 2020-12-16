function args = addArgument(args,name,value,varargin)
% Add argument to the exist table variable args
% args: arguments for a function to run; a table variable 
%       with following fields: 'name','value','acceptableValues',...
%       'lowerLimit' and 'upperLimit'
% name: name of the argument to be added; madatory
% value: value of the argument; will be [] if not supply
%
% other arguments in name,value pairs:
% 'type': type of values ('double','char',etc)
% 'acceptableValues': set of acceptable values
% 'lowerLimit': lower limit of numeric arguments.
% 'upperLimit': upper limit of numeric arguments.
% see also: setArgument
% written by Wanwei Zhang

if ~exist('value','var')
    value = [];
end

vargs = struct(...
    'type',[],...
    'acceptableValues',[],...
    'lowerLimit',[],...
    'upperLimit',[]);
vargs_name = fieldnames(vargs);

vargs_u = reshape(varargin,2,[])';
for i = 1:size(vargs_u,1)
    idx = find(strcmp(vargs_u{i,1},vargs_name));
    if numel(idx)~=1
        error(['Unsupported parameter: ',vargs_u{i,1}])
    end
    vargs.(vargs_name{idx}) = vargs_u{i,2};
end

args_tmp = cell2table(cell(1,2+numel(vargs_name)),...
    'var',[{'name';'value'};vargs_name]);
args_tmp.name{1} = name;
args_tmp.value{1} = value;
args_tmp.type{1} = vargs.type;
args_tmp.acceptableValues{1} = vargs.acceptableValues;
args_tmp.lowerLimit{1} = vargs.lowerLimit;
args_tmp.upperLimit{1} = vargs.upperLimit;

if ~isempty(args_tmp.lowerLimit{1})
    if ~isnumeric(args_tmp.lowerLimit{1})
        error('Lower limit must be numeric!')
    end
    if numel(args_tmp.lowerLimit{1})>1
        error('Lower limit must be scaler!')
    end
end
if ~isempty(args_tmp.upperLimit{1})
    if ~isnumeric(args_tmp.upperLimit{1})
        error('Upper limit must be numeric!')
    end
    if numel(args_tmp.upperLimit{1})>1
        error('Upper limit must be scaler!')
    end
end

if isempty(args_tmp.type{1})
    args_tmp.type{1} = class(args_tmp.value{1});
end

args_tmp.Row = args_tmp.name;

args = [args;args_tmp];

function args = setArgument(args,varargin)
% written by Wanwei Zhang

if rem(numel(varargin),2)~=0
    error('Arguments must be in name and value pairs!')
end
args_u = reshape(varargin,2,[])';

for i = 1:size(args_u,1)
    %idx = find(strcmp(args_u{i,1},args.name));
    idx = grep(args.name,['^',args_u{i,1}]);
    if numel(idx)>1
        error(['Ambiguious parameter name: ',args_u{i,1}]);
    elseif numel(idx)<1
        error(['Unknown parameter: ',args_u{i,1}])
    end
    if ischar(args.type{idx})
        if ~strcmp(class(args_u{i,2}),args.type{idx})
            error([args_u{i,1}, ' type must be ',args.type{idx},'!'])
        end
    elseif iscell(args.type{idx})
        if ~ismember({class(args_u{i,2})},args.type{idx})
            error([args_u{i,1}, ' type must be one of ',...
                myStrcat2(args.type{idx},', '),'!'])
        end
    end
    if ~isempty(args.acceptableValues{idx})
        if ~ismember(args_u{i,2},args.acceptableValues{idx})
            error(['Unacceptible value of ',args.name{idx}]);
        end
    end
    if ~isempty(args.lowerLimit{idx})&&isnumeric(args_u{i,2})
        if args_u{i,2}<args.lowerLimit{idx}
            error([args_u{i,1},' exceed lower limit!'])
        end
    end
    if ~isempty(args.upperLimit{idx})&&isnumeric(args_u{i,2})
        if args_u{i,2}>args.upperLimit{idx}
            error([args_u{i,1},' exceed lower limit!'])
        end
    end
    args.value{idx} = args_u{i,2};
end


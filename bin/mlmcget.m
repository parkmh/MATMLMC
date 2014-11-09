function o = mlmcget(options,name,default)


if nargin < 2
    error('MATLAB:mlmcget:NotEnoughInputs', 'Not enough input arguments.');
end
if nargin < 3
    default = [];
end

if ~isempty(options) && ~isa(options,'struct')
    error('MATLAB:mlmcget:Arg1NotStruct',...
        'First argument must be an options structure created with AMGSET.');
end

if isempty(options)
    o = default;
    return;
end

% Create a cell array of all the field names
allfields = {'dim';'rmse';'maxL';'initN';'M1';'s';'olmc';'tlmc'};
Names = allfields;

name = deblank(name(:)'); % force this to be a row vector
j = find(strncmpi(name,Names,length(name)));

if isempty(j)               % if no matches
    error('MATLAB:mlmcget:InvalidPropName',...
        ['Unrecognized option name ''%s''.  ' ...
        'See MCSET for possibilities.'], name);
elseif length(j) > 1            % if more than one match
    % Check for any exact matches (in case any names are subsets of others)
    k = find(strcmpi(name,Names));
    if length(k) == 1
        j = k;
    else
        msg = sprintf('Ambiguous option name ''%s'' ', name);
        msg = [msg '(' Names{j(1),:}];
        for k = j(2:length(j))'
            msg = [msg ', ' Names{k,:}];
        end
        msg = [msg, '.)'];
        error('MATLAB:optimget:AmbiguousPropName', msg);
    end
end

if any(strcmp(Names,Names{j,:}))
    o = options.(Names{j,:});
    if isempty(o)
        o = default;
    end
else
    o = default;
end

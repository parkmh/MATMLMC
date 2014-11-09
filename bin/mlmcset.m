function options = mlmcset(varargin)

% Print out possible values of properties.
if (nargin == 0) && (nargout == 0)
    fprintf('%15s : %s\n','dim','[ positive scalar | 1 | {2} | 3 ]');
    fprintf('%15s : %s\n','rmse','[ positive scalar | {1e-2}');
    fprintf('%15s : %s\n','maxL','[ positive scalar | {7}');
    fprintf('%15s : %s\n','initN','[ positive scalar | {10}');   
    fprintf('%15s : %s\n','M1','[ positive scalar | {8}');
    fprintf('%15s : %s\n','s','[ positive scalar | {4} [scale factor]');
    fprintf('%15s : %s\n','olmc','[     string      | {oneLevelMC2D}]');
    fprintf('%15s : %s\n','tlmc','[     string      | {twoLevelMC2D}]');
    return
end

% Create a cell array of all the field names
allfields = {'dim';'rmse';'maxL';'initN';'M1';'s';'olmc';'tlmc'};

% Create a struct of all the field with all values set to []
% create cell array
structinput = cell(2,length(allfields));
% fields go in first row
structinput(1,:) = allfields';
%[]'s go in second row
structinput(2,:) = {[]};
% turn it into correctly ordered comma separated list and call struct
options = struct(structinput{:});

numberargs = nargin; % we might change this value, so assing it

Names = allfields;
m = size(Names,1);
names = lower(Names);

i = 1;
while i <= numberargs
    arg = varargin{i};
    
    if ischar(arg)  % arg is an option name
        break;
    end
    if ~isempty(arg)    % [] is a valid options argument
        if ~isa(arg,'struct')
            error('MATLAB:MLMCSET:NoParamNameOrStruct',...
                ['Expected argument %d to be a string parameter name '...
                'or an options structure \ncreated with MLMCSET.'],i);
        end
        for j = 1:m
            if any(strcmp(fieldnames(arg),Names{j,:}))
                val = arg.(Names{j,:});
            else
                val = [];
            end
            if ~isempty(val)
                if ischar(val)
                    val = lower(deblank(val));
                end
                checkfield(Names{j,:},val);
                options.(Names{j,:}) = val;
            end
        end
    end
    i = i + 1;
end

% finite to parse name-value pairs.
if rem(numberargs-i+1,2) ~= 0
    error('MATLAB:MLMCSET:ArgNameValueMismatch',...
        'Arguments must occur in name-value paris.');
end
    
expectval = 0;      % start expecting a name, not a valu

while i <= numberargs
    
    arg = varargin{i};
    if ~expectval
        if ~ischar(arg)
            error('MATLAB:MLMCSET:InvalidParamName',...
                'Expected argument %d to be a string parameter name.',i);
        end
        
        lowArg = lower(arg);
        j = strmatch(lowArg,names);
        
        if isempty(j)       % if no matches
            % Error out -compose internationalization-friendly message with
            % hyperlinks
            stringWithLink = formatStringWithHyperlinks(sprintf('Link to reference page'),'doc MLMCSET');
            error('MATLAB:MLMCSET:InvalidParamName',...
                ['Unrecognized parameter name ''%s''. Please see the optimset' ...
                   ' reference page in the documentation for a list of acceptable' ...
                   ' option parameters. %s'],arg,stringWithLink);
        elseif length(j) > 1        % if more than one match
            % Check for any exact matches (in case any names are subnsets
            % of others)
            k = strmatch(lowArg,names,'exact');
            if length(k) == 1
                j = k;
            else
                msg = sprintf('Ambigous parameter name ''%s'' ', arg);
                msg = [msg '(' Names{j(1),:}];
                for k = j(2:length(j))'
                    msg = [msg ',' Names{k,:}];
                end
                msg = [msg,'.'];
                error('MATLAB:MLMCSET:AmbiguousParamName',msg);
            end
        end
        expectval = 1;  % we expect a value next        
    else
        if ischar(arg)
            arg = lower(deblank(arg));
        end
        
        checkfield(names{j,:},arg);
        options.(Names{j,:}) = arg;
        expectval = 0;
    end
    i= i + 1;
end

if expectval
    error('MATLAB:MLMCSET:NoValueForParam',...
        'Expected value for parameter ''%s''.',arg);
end

function checkfield(field,value)
%CHECKFIELD Check validity of structure field contents.
%   CHECKFIELD('field',V,OPTIMTBX) checks the contents of the specified
%   value V to be valid for the field 'field'. OPTIMTBX indicates if 
%   the Optimization Toolbox is on the path.
%


% empty matrix is always valid
if isempty(value)
    return
end

field = lower(field);
% See if it is one of the valid MATLAB fields.  It may be both an Optim
% and MATLAB field, e.g. MaxFunEvals, in which case the MATLAB valid
% test may fail and the Optim one may pass.
validfield = true;
switch field
    case {'dim'}
        [validvalue, errmsg, errid] = isDim(field,value);
    case {'maxL','initN','M1','s'} % integer scalar >= 1
        [validvalue, errmsg, errid] = IntGTE(field,value,1);
    case {'rmse'} % positive real scalar
        [validvalue, errmsg, errid] =  posReal(field,value);
    case {'antithetic','mlmc'} % off,on
        [validvalue, errmsg, errid] = onOffType(field,value);
    case {'olmc','tlmc'}
        validfield = true;
        validvalue = true;
    otherwise
        validfield = false;
        validvalue = false;
        errmsg = sprintf('Unrecognized parameter name ''%s''.', field);
        errid = 'MATLAB:optimset:checkfield:InvalidParamName';
end

if validvalue 
    return;
elseif validfield  
    % Throw the MATLAB invalid value error
    error(errid, errmsg);
end

%-----------------------------------------------------------------------------------------

function [valid, errmsg, errid] = isDim(field,value)
% Any nonnegative real scalar or sometimes a special string

valid =  isreal(value) && isscalar(value) && (value >= 1) && (value <= 3) && value == floor(value);

if ~valid
    if ischar(value)
        errid = 'MATLAB:funfun:MLMCSET:IntGTl:IntLTNum';
        errmsg = sprintf('Invalid value for OPTIONS parameter %s: must be a integer scalar 1, 2 or 3 (not a string).',field);
    else
        errid = 'MATLAB:funfun:MLMCSET:IntGTl:IntLTNum';
        errmsg = sprintf('Invalid value for OPTIONS parameter %s: must be a integer scalar 1, 2 or 3.',field);
    end
else
    errid = '';
    errmsg = '';
end

%-----------------------------------------------------------------------------------------

function [valid, errmsg, errid] = IntGTE(field,value,lowerbnd)
% Any nonnegative real scalar or sometimes a special string

valid =  isreal(value) && isscalar(value) && (value >= lowerbnd) && value == floor(value);
if ~valid
    if ischar(value)
        errid = 'MATLAB:funfun:MLMCSET:IntGTl:IntLTNum';
        errmsg = sprintf('Invalid value for OPTIONS parameter %s: must be a integer scalar >=  %d (not a string).',field,lowerbnd);
    else
        errid = 'MATLAB:funfun:MLMCSET:IntGTl:IntLTNum';
        errmsg = sprintf('Invalid value for OPTIONS parameter %s: must be a integer scalar >=  %d.',field,lowerbnd);
    end
else
    errid = '';
    errmsg = '';
end

%-----------------------------------------------------------------------------------------

function [valid, errmsg, errid] = posReal(field,value)
% Any nonnegative real scalar or sometimes a special string
valid =  isreal(value) && isscalar(value) && (value > 0) ;

if ~valid
    if ischar(value)
        errid = 'MATLAB:funfun:MLMCSET:posReal:nonnegativeNum';
        errmsg = sprintf('Invalid value for OPTIONS parameter %s: must be a real positive scalar (not a string).',field);
    else
        errid = 'MATLAB:funfun:MLMCSET:posReal:nonnegativeNum';
        errmsg = sprintf('Invalid value for OPTIONS parameter %s: must be a real positive scalar.',field);
    end
else
    errid = '';
    errmsg = '';
end

%-----------------------------------------------------------------------------------------

function [valid, errmsg, errid] = posVecReal(field,value)
% Any nonnegative real scalar or sometimes a special string
valid =  isreal(value) && isvector(value) && prod(value > 0) ;

if ~valid
    if ischar(value)
        errid = 'MATLAB:funfun:MLMCSET:posReal:nonnegativeNum';
        errmsg = sprintf('Invalid value for OPTIONS parameter %s: must be a real positive vector (not a string).',field);
    else
        errid = 'MATLAB:funfun:MLMCSET:posReal:nonnegativeNum';
        errmsg = sprintf('Invalid value for OPTIONS parameter %s: must be a real positive vector.',field);
    end
else
    errid = '';
    errmsg = '';
end


%-----------------------------------------------------------------------------------------

function [valid, errmsg, errid] = onOffType(field,value)
% One of these strings: on, off
valid =  ischar(value) && any(strcmp(value,{'on';'off'}));
if ~valid
    errid = 'MATLAB:funfun:optimset:onOffType:notOnOffType';
    errmsg = sprintf('Invalid value for OPTIONS parameter %s: must be ''off'' or ''on''.',field);
else
    errid = '';
    errmsg = '';
end

%-----------------------------------------------------------------------------------------

function formattedString = formatStringWithHyperlinks(textToHyperlink,commandToRun)
% Check if user is running MATLAB desktop. In this case wrap
% textToHyperlink with HTML tags so that when user clicks on
% textToHyperlink, commandToRun gets executed. If not running
% MATLAB desktop, leave textToHyperlink unchanged.

if feature('hotlinks') && ~isdeployed
    % If using MATLAB desktop and not deployed, use hyperlinks
    formattedString = sprintf('<a href="matlab: %s ">%s</a>.',commandToRun,textToHyperlink);
else
    % Use plain string
    formattedString = sprintf('');
end
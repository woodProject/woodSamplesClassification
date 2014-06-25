function outStructure = featureDescription2struct(featStr)
%   Statistics is always at the end of the configuration. This need to be
%   avoided.
%
    tokenList = strsplit(featStr,{':' ' '});
    while ~isempty(tokenList)
        switch lower(tokenList{1})
            case {'nlevels', 'dist', 'angle'}
                outStructure.(tokenList{1}) = str2double(tokenList{2});
                tokenList(1:2)=[];
            case {'wavelettype'}
                outStructure.(tokenList{1}) = tokenList{2};
                tokenList(1:2)=[];
            case {'stats'}
                outStructure.(tokenList{1}) = tokenList(2:end);
                tokenList(1:end) = [];
            otherwise
                error('featureDescription2struct:unkownFeatureOption','%s is an unkown option',tokenList{1});
        end
    end


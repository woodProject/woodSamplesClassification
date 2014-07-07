function woodTestEnsureFeatures(conf)
%
% TODO: 
%       - modify featureDescription2struct so that form the initial configuration
%       string it gives back a structure with a function handle to
%       calculate the feature.

if conf.verboseMode >=1 
    fprintf( 'Features checking ... ' );
end

% recover the dataset images lists
imgIdExperimentList = cat(1,conf.dataSamples.sampleID{:});
imgPathExperimentList = cat(1,conf.dataSamples.imagePath{:});

% Collect all the features and generate the missing ones
featuresCollection = {conf.experiment.featureList}';
featuresCollection = unique(cat(1,featuresCollection{:}));
nFeaturesCollection = length(featuresCollection);

for featureIdx = 1:nFeaturesCollection 
    switch conf.verboseMode
        case 2
            if any(featureIdx == round(linspace(1,nFeaturesCollection,10)))
                fprintf('%0.1f%% ',100*featureIdx/nFeaturesCollection);
            end
        case 3
            fprintf('\n(%0.1f%% Feat. check) %s ...',   ...
                    100*featureIdx/nFeaturesCollection, ...
                    featuresCollection{featureIdx});
        otherwise
            %Stay quiet
    end
                
    % Recover the current Feature configuration
    [featureName, featureParamStr] = strtok(featuresCollection(featureIdx),' ');
    featureName = cell2mat(featureName);
    featureParamStr = cell2mat(featureParamStr);
    featureParameters = featureDescription2struct(featureParamStr(2:end));
    
    % Set the feature calculation function
    switch lower(featureName)
        case 'waveletenergy'
            featureCalcFun = @calcWaveletEnergy;
        case 'glcm'
            featureCalcFun = @calcGLCM;
        otherwise
            error('woodTestEnsureFeatures:unkownFeature','%s is an unkown feature',featureName);
    end
    
    % Set the feature Store point
    featureRelativePath = getRelativePath(featureName,featureParameters);
    featureParameters.dataStoragePath= fullfile( conf.calcPoolDir, featureRelativePath);
    
    % Generate the missing calculations
    toComputeFlag = checkCalculation(imgIdExperimentList,featureParameters.dataStoragePath);
    toComputeImagePath = imgPathExperimentList(toComputeFlag);
    toComputeImageId = imgIdExperimentList(toComputeFlag);
    numImgToBeComputed = length(toComputeImageId);
    displayCheckPoint  = round(linspace(1,numImgToBeComputed,5));
    
    for imgIdx = 1:numImgToBeComputed
        if conf.verboseMode >= 3 && any(displayCheckPoint==imgIdx)
            fprintf('%0.1f%% ',100*imgIdx/numImgToBeComputed);
        end
        featureCalcFun( imread(toComputeImagePath{imgIdx}),...
                        toComputeImageId{imgIdx},...
                        featureParameters);
    end
    if conf.verboseMode >= 3, fprintf(' ok'); end
    % Check if the feature needs statistics to be extracted
    if isfield(featureParameters,'stats')
        if conf.verboseMode >= 3 
                    fprintf('\n(%0.1f%% Feat. statistics check) ', ...
                    100*featureIdx/nFeaturesCollection);
        end 
        
        % Set the feature calculation function
        switch lower(featureName)
            case 'glcm'
                featureCalcFun = @calcGLCMStatistics;
            otherwise
                error('woodTestEnsureFeatures:unkownFeatureStatistic','%s is an unkown feature',featureName);
        end
        
        statisticsDataDir = getRelativePath([featureName 'Statistic'],featureParameters);
        statisticsDataDir = fullfile( conf.calcPoolDir, statisticsDataDir);
        toComputeFlag = checkCalculation(imgIdExperimentList,statisticsDataDir);
        toComputeImageId = imgIdExperimentList(toComputeFlag);
        numImgToBeComputed = length(toComputeImageId);
        displayCheckPoint  = round(linspace(1,numImgToBeComputed,5));
        
        for imgIdx = 1:numImgToBeComputed
            if conf.verboseMode >= 3 && any(displayCheckPoint==imgIdx)
                fprintf('%0.1f%% ',100*imgIdx/numImgToBeComputed);
            end
            featureCalcFun( toComputeImageId{imgIdx},...
                            featureParameters);
        end
        
        
    end
    
    
end

switch conf.verboseMode
    case 0
    case 1
        fprintf( ' ... ok\n' );
    case 2
        fprintf( ' ... ok\n' );
    otherwise
        fprintf( '\nFeatures checking ... ok\n' );
end


% function tobeComputedFlag = checkCalculation(imgIdExperimentList,featureCalculationPath)
% if ensureDir(featureCalculationPath)
%     tobeComputedFlag = true(length(imgIdExperimentList),1);
% else
%     alreadyCalculatedImagesId = dir(fullfile(featureCalculationPath,'*.mat'));
%     alreadyCalculatedImagesId = cellfun(@(x) x(1:end-4),{alreadyCalculatedImagesId.name}','UniformOutput',false);
%     tobeComputedFlag = ~ismember(imgIdExperimentList,alreadyCalculatedImagesId);
% end


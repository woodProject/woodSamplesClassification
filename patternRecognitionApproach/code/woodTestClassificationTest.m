function woodTestClassificationTest(conf)
%
% TODO: 
%       - modify featureDescription2struct so that form the initial configuration
%       string it gives back a structure with a function handle to
%       calculate the feature.
%       - Allow crossValidation with an arbitrary number of samples, etc...
%             + maybe by pulling N random experiments
% knownBUGs: getRelativePathWorkAround for features with statistics

global calcPoolDir
calcPoolDir = conf.calcPoolDir;

if conf.verboseMode >=1,    fprintf( 'Classification ... ' );end

classificationDataDir = fullfile( conf.calcPoolDir, 'classificationData', conf.dataSamples.datasetID);
experimentList = {conf.experiment.id}';

missingExperiments = find(checkCalculation(experimentList,classificationDataDir));
nMissingExperiments = length(missingExperiments);

for ii = 1:nMissingExperiments
    experimentIdx = missingExperiments(ii);
    switch conf.verboseMode
        case 2
            if any(ii == round(linspace(1,nMissingExperiments,10)))
                fprintf('%0.1f%% ',100*ii/nMissingExperiments);
            end
        case 3
            currentExperimentStatus = sprintf('\n(%0.1f%% Experiments done) current experiment status: ',   ...
                                               100*ii/nMissingExperiments);                                
        otherwise
            %Stay quiet
    end
    
    % Collect features
    if conf.verboseMode>=3, fprintf('%s Gathering Features ..',currentExperimentStatus); end
    features = generateFeatureDescriptor(conf.dataSamples,conf.experiment(experimentIdx));
    if conf.verboseMode>=3, fprintf('.. ok'); end
    
    % Running CrossValidation
    if conf.verboseMode>=3, fprintf('%s Running CrossValidation ..',currentExperimentStatus); end
    currentExperimentDataModelConfiguration = conf.dataModelConfig.(conf.experiment(experimentIdx).dataModel);
    estimatedClass = runCrossValidation(features,currentExperimentDataModelConfiguration,conf.verboseMode);
    if conf.verboseMode>=3, fprintf('.. ok'); end
    
    % Save the data
    fileName = fullfile(classificationDataDir,sprintf('%s.mat',conf.experiment(experimentIdx).id));
    save(fileName,'estimatedClass');
end
end

function estimatedClass = runCrossValidation(features,dataModelConfig,verboseMode)
    % TODO: this only works with balanced datasets
switch lower(dataModelConfig.type)
    case 'svm'
        trainFunction = @generateSVMModel;
        getClassEstimation = @testSVMmodel;
    otherwise
        error('woodTestClassificaitonTest:runCrossValidtaion','%s unkown dataModel type',dataModelConfig.type);

end

% TODO: this only works with balanced datasets
features = cat(2,features{:});
estimatedClass = zeros(size(features),'uint8');
numberOfFolds = size(features,1);
trainLabels = meshgrid(1:size(features,2),1:(numberOfFolds-1));
for foldId  = 1:numberOfFolds
    showProgress;

    % Generate the datasets
    roundTrainFeatures = features(setxor(foldId,1:numberOfFolds),:);
    roundTestFeatures  = features(foldId,:);
    
    % Train
    trainFeat_rowSamples_colFeat = cell2mat(roundTrainFeatures(:));   
    currentTrainedModel = trainFunction(trainFeat_rowSamples_colFeat,trainLabels(:),dataModelConfig);
    
    % Test
    testFeat_rowSamples_colFeat = cell2mat(roundTestFeatures(:));
    estimatedClass(foldId,:) = getClassEstimation(testFeat_rowSamples_colFeat, currentTrainedModel);
end

%% Displaying stuff function
    function showProgress()
        if verboseMode >= 4 && any(foldId == round(linspace(1,numberOfFolds,5)))
            fprintf('%0.1f ',100*foldId/numberOfFolds);
        end
    end

end

function estimatedClass = testSVMmodel(data,model)
spherify = @(x,param) (x-repmat(param.mean,[size(x,1) 1]))./repmat(param.std,[size(x,1) 1]);
spherifiedData = spherify(data,model.spherification);
scores = model.weights' * spherifiedData' + model.biasCorrection' * ones(1,size(spherifiedData,1)) ;
[maxClassificationScore, estimatedClass] = max(scores, [], 1) ;
end


function model = generateSVMModel(data,label,conf)
spherification.mean = mean(data,1);
spherification.std  =  std(data,1);
spherify = @(x,param) (x-repmat(param.mean,[size(x,1) 1]))./repmat(param.std,[size(x,1) 1]);
data = spherify(data,spherification);

switch(conf.solver)
    case {'sgd','sdca'}
        lambda = 1 / (conf.C *  size(data,1)) ;
        w = [] ;
        for currentClass = unique(label)'
            y = 2 * (label == currentClass) - 1 ; % set them one class vs others (1 vs -1)
            [w(:,currentClass) b(currentClass) info] = vl_svmtrain( data',y', lambda, ...
                                                                    'Solver', conf.solver, ...
                                                                    'MaxNumIterations', 50/lambda, ...
                                                                    'BiasMultiplier', conf.biasMultiplier, ...
                                                                    'Epsilon', 1e-3);
        end
        
    otherwise
        display('To be implemented'); exit(0);
end
model.spherification=spherification;
model.weights = w;
model.biasCorrection = conf.biasMultiplier * b ;
end

function features = generateFeatureDescriptor(dataConf, experimentConf)
imageIdList = cat(1,dataConf.sampleID{:});
numImageIds  = length( imageIdList );

numFeatures = length(experimentConf.featureList);
features = cell(numImageIds,numFeatures);

for featureIdx = 1:numFeatures
    features(:,featureIdx) = collectFeature(imageIdList,experimentConf.featureList(featureIdx));
end

% concatenate all the features for a single descriptor.
features = arrayfun(@(x) cat(2,features{x,:}),1:numImageIds,'UniformOutput',false)';

% Shape the output as the configuration samples
classNumElemets =  cellfun(@length, dataConf.sampleID);
features = mat2cell(features,classNumElemets,1)';
end


function dataCollection = collectFeature(imgIdList,featureDescriptionStr)
global calcPoolDir
    % Recover the current Feature configuration
    [featureName, featureParamStr] = strtok(featureDescriptionStr,' ');
    featureName = cell2mat(featureName);
    featureParamStr = cell2mat(featureParamStr);
    featureParameters = featureDescription2struct(featureParamStr(2:end));

    % Set the feature Store point
    featureRelativePath = getRelativePathWorkAround(featureName,featureParameters);
    featureParameters.dataStoragePath= fullfile( calcPoolDir, featureRelativePath);
    
    dataCollection = cell(length(imgIdList),1);
    for ii=1:length(imgIdList)
        currentImgFeatCalculationFile = fullfile(featureParameters.dataStoragePath,sprintf('%s.mat',imgIdList{ii}));
        load(currentImgFeatCalculationFile,'data');
%         load(currentImgFeatCalculationFile,'currentlbp');
%         dataCollection{ii} = currentlbp;
        dataCollection{ii} = data;
    end
    
    function featureRelativePath = getRelativePathWorkAround(featureName,featureParameters)
        if isfield(featureParameters,'stats')
            featureRelativePath = getRelativePath([featureName 'Statistic'],featureParameters);
        else
            featureRelativePath = getRelativePath(featureName,featureParameters);
        end
    end
end


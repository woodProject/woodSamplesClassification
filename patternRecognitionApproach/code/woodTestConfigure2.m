function conf = woodTestConfigure2(testName)
if ~exist('testName','var'), testName='test1';end

mat2struct = @(x,names) cell2struct(mat2cell(x,ones(1,size(x,1)),ones(1,size(x,2))),names);
strFileNameHorizontalCat = @(x) arrayfun(@(y) strjoin(x(y,:),filesep),1:size(x,1),'UniformOutput',false);

% General Configuration
conf.verboseMode = 3; % 0 quiet, 1 low, 2 medium, 3 high
conf.calcPoolDir = fullfile('.','calculations');

conf.dataSamples = generateDataConfiguration(testName);
conf.dataSamples = computeDataIds(conf.dataSamples);
conf.dataModelConfig   = generateModelConfiguration(testName);
conf.experiment  = generateExperimentConfiguration(testName);
conf.experiment  = computeExperimentIds(conf.experiment);

function experimentConf = computeExperimentIds(experimentConf)
hashOptions = struct('Method','SHA-512','Format', 'hex', 'Input', 'array');
for ii=1:length(experimentConf)
    experimentConf(ii).featureList = sort(experimentConf(ii).featureList);
    experimentConf(ii).id = DataHash(experimentConf(ii),hashOptions);
end



function dataConf = computeDataIds(dataConf)
% Compute image Ids
hashOptions = struct('Method','SHA-512','Format', 'hex', 'Input', 'array');
numSampleTypes = length(dataConf.sampleTypes);
imageHashID = cell(1,numSampleTypes);
for typeIdx = 1:numSampleTypes
    imageHashID{typeIdx} = cellfun(@(x) DataHash(imread(x),hashOptions),dataConf.imagePath{typeIdx},'UniformOutput',false);
end
dataConf.sampleID = imageHashID;

% Compute dataset Id
dataConf.datasetID = DataHash(cellfun(@sort,imageHashID,'UniformOutput',false),hashOptions);


function dataConf = generateDataConfiguration(testName)
datasetRootDir = 'D:\MatlabWorkspace\woodSamplesClassification\datasets\';
% Root Directory changed
missingConfiguration = false;
switch testName
    case 'test1'
        dataDir       = fullfile(datasetRootDir,'1004BalancedRandomDataset');
        sampleTypes   = {'TF', 'F', 'M', 'GG'};
        imageNames    = arrayfun(@(x) sprintf('%03d.png',x),1:4,'UniformOutput',false)';
        imagePath    = cellfun(@(x) fullfile(dataDir, x, imageNames), ...
                                    sampleTypes,'UniformOutput',false);
    case 'test1i2'    
        dataDir       = fullfile(datasetRootDir,'1004BalancedRandomDataset');
        sampleTypes   = {'TF', 'F', 'M', 'GG'};
        imageNames    = arrayfun(@(x) sprintf('%03d.png',x),1:20,'UniformOutput',false)';
        imagePath    = cellfun(@(x) fullfile(dataDir, x, imageNames), ...
                                    sampleTypes,'UniformOutput',false);
    otherwise
        missingConfiguration = true;
        display('Unknown dataSample Configuration, test1 applied');
        dataConf = generateDataConfiguration('test1');
end
if ~missingConfiguration
    dataConf.dataDir = dataDir;
    dataConf.datasetID = [];
    dataConf.sampleTypes = sampleTypes;
    dataConf.imagePath = imagePath;
end

function dataModelConf  = generateModelConfiguration(testName)
missingConfiguration = false;
switch testName
    case 'test1'
        %featureExtraction = false;
        %classifierType = 'svm';  
        dataModelConf.svm.type = 'svm';
        dataModelConf.svm.C = 10 ;
        dataModelConf.svm.solver = 'sdca' ;% 'sgd' ;% 'liblinear' ;woodTestEnsureFeatures
        dataModelConf.svm.biasMultiplier = 1 ;
    otherwise
        missingConfiguration = true;
        display('Unknown dataModel Configuration, test1 applied');
        dataModelConf = generateModelConfiguration('test1');
end
% if ~missingConfiguration
%     dataModelConf.featureExtraction = featureExtraction;
%     dataModelConf.classifierType    = classifierType;   
% end

function experimentConf = generateExperimentConfiguration(testName)
% missingConfiguration = false;
switch lower(testName)
    case 'test1'            
        experimentConf(1).dataModel = 'svm';
        experimentConf(1).featureList = {'waveletEnergy waveletType:haar nLevels:002';
                                         'waveletEnergy waveletType:haar nLevels:003';
                                        };
        experimentConf(2).dataModel = 'svm';
        experimentConf(2).featureList = {'waveletEnergy waveletType:haar nLevels:002';
                                         'glcm nLevels:256 dist:010 angle:020 stats:contrast homogeneity';
                                        };                                    
    case 'basicfeatures'
        waveletConfigs = {};
        waveletParameters = allcomb({'haar','db5','rbio2.4','bior2.4'},{2 4});
        nWaveletExperiments = size(waveletParameters,1);
        for ii=1:nWaveletExperiments
            waveletConfigs{ii} = sprintf('waveletEnergy waveletType:%s nLevels:%03d', waveletParameters{ii,:});
        end
        glcmConfigs = {};
        glcmParameters = allcomb([16,32,64],[2:20],setxor(union(0:30:180,0:40:180),180));
        nGLCMExperiments = size(glcmParameters,1);
        for ii=1:nGLCMExperiments
            glcmConfigs{ii} = sprintf('glcm nLevels:%03d dist:%03d angle:%3d stats:Correlation Energy Homogeneity contrast',glcmParameters(ii,:));
        end
        experimentFeatures = mat2cell([waveletConfigs glcmConfigs]',ones(nWaveletExperiments+nGLCMExperiments,1));
        experimentConf = cell2struct(allcomb({'svm'},experimentFeatures), ...
                                     {'dataModel','featureList'},2);

    case 'basicglcm'
        glcmConfigs = {};
        glcmParameters = allcomb([16,32,64],[2:20],setxor(union(0:30:180,0:40:180),180));
        nGLCMExperiments = size(glcmParameters,1);
        for ii=1:nGLCMExperiments
            glcmConfigs{ii} = sprintf('glcm nLevels:%03d dist:%03d angle:%3d stats:Correlation Energy Homogeneity contrast',glcmParameters(ii,:));
        end
        experimentFeatures = mat2cell(glcmConfigs',ones(nGLCMExperiments,1));
        experimentConf = cell2struct(allcomb({'svm'},experimentFeatures), ...
                                     {'dataModel','featureList'},2);                                 
    case ('test1i2')
        xx = generateExperimentConfiguration('test1');
        yy = generateExperimentConfiguration('basicfeatures');
        experimentConf = cell2struct([[{xx.dataModel}'; {yy.dataModel}'] [{xx.featureList}'; {yy.featureList}']], ...
                                     {'dataModel','featureList'},2);
    otherwise
        missingConfiguration = true;
        display('Unknown Feature Configuration, test1 applied');
        experimentConf = generateDataConfiguration('test1');
end
% if ~missingConfiguration
%     %experimentConf.featureExtraction = featureExtraction;
%     experimentConf.classifierType    = classifierType;   
%     experimentConf.features
% end


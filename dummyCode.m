%% Adjust the images
imagesDir = '/home/sik/Work/escola/recerca/Wood/imagesManipulationCut/';
imageTypes = {'TF', 'F', 'M', 'GG'};

imNames = cellfun(@(x) dir(fullfile(imagesDir,x,'*.png')),imageTypes,'UniformOutput',false);
for typeIdx = 1:length(imageTypes)
     for imId = 1:length(imNames{typeIdx});
        imFullName = fullfile(imagesDir,imageTypes{typeIdx}, imNames{typeIdx}(imId).name);
        currentImage = imread(imFullName);
        if ndims(currentImage) == 3, currentImage = rgb2gray(currentImage);end
        currentImage = imadjust(currentImage);
        imwrite(currentImage,imFullName);        
    end
end

%% Sample the images to balance the dataset
clear all;
imagesDir = '/home/sik/Work/escola/recerca/Wood/images/0404CropProcessed/';
outImagesDir = '~/Work/escola/recerca/Wood/datasets/0404WoodProcessedBalancedInputData';
imageTypes = {'TF', 'F', 'M', 'GG'};
imNames = cellfun(@(x) dir(fullfile(imagesDir,x,'*.png')),imageTypes,'UniformOutput',false);
nSamples = 30;

% Save random State and set it to the beginig to generate the same
% selection
stream = RandStream.getGlobalStream;
savedState = stream.State;
reset(stream)
selectedImaesId = cellfun( @(x) randperm(length(x),nSamples),imNames,'UniformOutput',false);
% Restore the previous random state
stream.State = savedState;

for typeIdx = 1:length(imageTypes)
    currentInDir  = fullfile(imagesDir,imageTypes{typeIdx});
    currentOutDir = fullfile(outImagesDir,imageTypes{typeIdx});
    mkdir(currentOutDir); % in case is not created yet
    
    for sampleId = 1:nSamples
        targetFile = fullfile(currentInDir,imNames{typeIdx}(selectedImaesId{typeIdx}(sampleId)).name);
        linkName = fullfile(currentOutDir,sprintf('%03d.png',sampleId));
        system( sprintf('ln -s %s %s',targetFile,linkName) );                                           
    end
end
        
%%
clear all;
imagesDir = '/home/sik/Work/escola/recerca/Wood/WoodProcessedBalancedInputData/';
imageTypes = {'TF', 'F', 'M', 'GG'};
imNames = cellfun(@(x) dir(fullfile(imagesDir,x,'*.png')),imageTypes,'UniformOutput',false);
hashOptions = struct('Method','SHA-512','Format', 'hex', 'Input', 'array');

imageHashID = cell(size(imageTypes));
for typeIdx = 1:length(imageTypes)
    currentInDir   = fullfile(imagesDir,imageTypes{typeIdx});
    imagesFullName = fullfile(currentInDir,{imNames{typeIdx}(:).name}'); 
    imageHashID{typeIdx} = cellfun(@(x) DataHash(imread(x),hashOptions),imagesFullName,'UniformOutput',false);
end

if isequal( size(cat(1,imageHashID{:})), ...
            size(unique(cat(1,imageHashID{:}))))
        display('no Hash colissions');
else
    display('PROBLEM with HASH ids');
end

%% Generate a random balanced dataset for the images in 1004Crop directori

imagesDir = 'D:\MatlabWorkspace\woodSamplesClassification\images\1004Crop\imAdjust\';
outDir = 'D:\MatlabWorkspace\woodSamplesClassification\datasets\1004BalancedRandomDataset\';
nSamplesDesired = 20;

sampleType = {'TF', 'F', 'M', 'GG'};
imNames = dir(fullfile(imagesDir,'*.png'));
imNames = {imNames(:).name}';


% Save random State and set it to the beginig to generate the same
% simagesDirelection
stream = RandStream.getGlobalStream;
savedState = stream.State;
reset(stream)

for ii=1:length(sampleType)
    mkdir(fullfile(outDir,sampleType{ii}));
    currentRegExp = sprintf('[1-3]%s',sampleType{ii});
    currentTypeImageIdx = find(~cellfun(@isempty,regexp(imNames,currentRegExp,'match')));
    randomizedNsamples = randperm(length(currentTypeImageIdx),nSamplesDesired);
    currentTypeImageIdx = currentTypeImageIdx(randomizedNsamples);
    for sampleIdx=1:nSamplesDesired
        linkName = fullfile(outDir,sampleType{ii},sprintf('%03d.png',sampleIdx));
        targetName = fullfile(imagesDir,imNames{currentTypeImageIdx(sampleIdx)});
        currentCommand = sprintf('ln -s %s %s',targetName,linkName);
%         unix('ln -s',targetName,linkName);
%           dos(mklink,linkName,targetName)
        system(['mklink "' linkName '" "' targetName '"']);
    end
end

% Restore the previous random state
stream.State = savedState;


%% Call calcWaveletTransform.m
conf = woodTestConfigure2('test1');
imgId = conf.dataSamples.sampleID{1}{1};
I = imread(conf.dataSamples.imagePath{1}{1});
wFeatConf.dataStoragePath = './calculations/tmp';
wFeatConf.nLevels = 2;
wFeatConf.wavletType = 'haar';
calcWaveletTransform(I,imgId,wFeatConf)

%% Call calcWaveletEnergy
conf = woodTestConfigure2('test1');
imgId = conf.dataSamples.sampleID{1}{1};
I = imread(conf.dataSamples.imagePath{1}{1});
wFeatConf.nLevels = 2;
wFeatConf.wavletType = 'haar';
wFeatConf.dataStoragePath = fullfile(conf.calcPoolDir,'features','waveletEnergy',sprintf('%s_%02dlevels',wFeatConf.wavletType,wFeatConf.nLevels));
mkdir(wFeatConf.dataStoragePath);
calcWaveletEnergy(I,imgId,wFeatConf)


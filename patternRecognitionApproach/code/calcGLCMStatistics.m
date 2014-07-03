function calcGLCMStatistics(imgId,glcmConf)
glcmFileName = fullfile(glcmConf.dataStoragePath,sprintf('%s.mat',imgId));
load( glcmFileName, 'currentGLCM');
data = struct2array( graycoprops(currentGLCM,glcmConf.stats) );
fullStoreFileName = fullfile(pwd,glcmConf.dataStoragePath, ...
    strjoin(sort(glcmConf.stats),'_'),...
    sprintf('%s.mat',imgId));
addpath(genpath('D:\MatlabWorkspace\woodSamplesClassification\patternRecognitionApproach\calculations'))
% addpath('D:\MatlabWorkspace\woodSamplesClassification\patternRecognitionApproach\calculations\features\GLCM\002dsit_000angle_016levels\Correlation_Energy_Homogeneity_contrast')
fullStoreFileName1 = fullfile(glcmConf.dataStoragePath, ...
    strjoin(sort(glcmConf.stats),'_'));
ensureDir('fullStoreFileName1')
% save(fullStoreFileName,'data');
save('fullStoreFileName','data');
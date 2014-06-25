function calcGLCMStatistics(imgId,glcmConf)
glcmFileName = fullfile(glcmConf.dataStoragePath,sprintf('%s.mat',imgId));
load( glcmFileName, 'currentGLCM');
data = struct2array( graycoprops(currentGLCM,glcmConf.stats) );
fullStoreFileName = fullfile(glcmConf.dataStoragePath, ...
                             strjoin(sort(glcmConf.stats),'_'),...
                             sprintf('%s.mat',imgId));
save(fullStoreFileName,'data');
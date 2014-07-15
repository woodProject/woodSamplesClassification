function relativePath = getRelativePath(featureType, featureParameters)
switch lower(featureType)    
    case 'waveletenergy'
        dirName = sprintf('%s_%02dlevels',featureParameters.waveletType, ...
                                          featureParameters.nLevels);
        relativePath = fullfile('features','waveletEnergy', dirName);
    case 'glcm'
        relativePath = glcmMatrixDirName(featureParameters);
    case 'glcmstatistic'
        relativePath = fullfile(glcmMatrixDirName(featureParameters), ...
                                strjoin(sort(featureParameters.stats),'_'));
    case 'lbp'
        dirName = sprintf('%s_%01d','cellsize',featureParameters.cellsize);
        relativePath = fullfile('features','lbp', dirName);
    otherwise
        error('getRelativePath:argChk','unkown feature type ''%s''',featureName);
        
end

function glcmMatrixPath = glcmMatrixDirName(glcmConf)
dirNameStr = '%03ddsit_%03dangle_%03dlevels';
dirName = sprintf(dirNameStr,glcmConf.dist, glcmConf.angle,glcmConf.nLevels  );
glcmMatrixPath = fullfile('features','GLCM',dirName);
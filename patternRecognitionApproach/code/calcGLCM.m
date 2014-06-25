function calcGLCM(I,imgId,glcmConf)
[xOffset, yOffset] = pol2cart(degtorad(-glcmConf.angle),...
                                        glcmConf.dist);
currentGLCM = graycomatrix( I, 'Offset', round([yOffset xOffset]), ...
                               'NumLevels',glcmConf.nLevels); %#ok<NASGU>

fullStoreFileName = fullfile(glcmConf.dataStoragePath,sprintf('%s.mat',imgId));
save( fullStoreFileName, 'currentGLCM');

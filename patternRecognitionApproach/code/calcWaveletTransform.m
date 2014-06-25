function calcWaveletTransform(I,imgId,wFeatConf)
%
% I :        Image (it should be MxNx1 uint8)
% imageId:   correspond to the name that the calculations would be stored.
% wFeatConf: Wood Test wavelet Configuration
%   . dataStoragePath:  path where the wavelet data would be sored 
%   . nLevels:          the ammound of approximations needed
%   . wavletType:       parameter corresponding to 'wname' in dwt2 funciton
%
% Data storage point:
%   wFeatConf.dataStoragePath/imgId.mat
% Data format
%   1 Level case: data = [{H1}, {V1}, {D1}, {App1}]
%   2 Level case: data = [{H1}, {V1}, {D1}, {H2}, {V2}, {D2}, {App2}]
%   n Level case: data = [{H1}, {V1}, {D1}, {H2}, ... {Dn}, {Appn}]

data = {I};
for ii=1:wFeatConf.nLevels
    [Approximation,HorizontalCoef,VerticalCoef,DiagonalCoef] = dwt2(data{end},wFeatConf.wavletType);
    data = [data {HorizontalCoef, VerticalCoef, DiagonalCoef, Approximation}];
end
data(1) = [];

fullStoreFileName = fullfile(wFeatConf.dataStoragePath,sprintf('%s.mat',imgId));
save(fullStoreFileName,'data');


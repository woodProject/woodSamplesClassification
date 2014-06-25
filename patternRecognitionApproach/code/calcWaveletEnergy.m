function calcWaveletEnergy(I,imgId,wFeatConf)
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
% Data format (more info doc wavedec2 )
%   data = [ A(N) | H(N) | H(N-1) | ... | H(1) | V(N) | V(N-1) | ... 
%                 | V(1) | D(N) | D(N-1) | ... | D(1) ];
%           where A     is the energy of the Approximation,
%                 H(N)  is the energy of the Horizontal at level N
%                 V(N)  is the energy of the Vertical at level N
%                 D(N)  is the energy of the Diagonal at level N
%

maxLevels = wmaxlev(size(I),'haar');
if wFeatConf.nLevels <=  maxLevels    
    [C,S] = wavedec2(I,wFeatConf.nLevels,wFeatConf.waveletType);
    [Ea,Eh,Ev,Ed] = wenergy2(C,S);
    data = [Ea Eh Ev Ed];
    fullStoreFileName = fullfile(wFeatConf.dataStoragePath,sprintf('%s.mat',imgId));
    save(fullStoreFileName,'data');
else
    error('waveletEnergyCalc::argChk',sprintf('Image %s only accepts %02d levels',imgId,maxLevels));
end


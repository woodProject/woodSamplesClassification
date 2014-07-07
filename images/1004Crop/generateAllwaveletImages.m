inImgPath = './imAdjust/';
waveletType = allcomb({'haar','db5','rbio2.4','bior2.4'},num2cell(1:3));
for wavletConfId = 1:size(waveletType,1)
    outImgPath=sprintf('./wavelet/%s/%02dlevels/',waveletType{wavletConfId,:});
    mkdir(outImgPath);
    imNames = dir(fullfile(inImgPath,'*.png'));
    for ii=1:length(imNames)
        imFullName = fullfile(inImgPath,imNames(ii).name);
        imOutFullName = fullfile(outImgPath,imNames(ii).name);
        generateWaveLetImages(imFullName,waveletType{wavletConfId,1},waveletType{wavletConfId,2},imOutFullName);
    end
end
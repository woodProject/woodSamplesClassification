function calclbp(I,imgId,lbpConf)
currentlbp = vl_lbp(single(I), lbpConf.cellsize);

fullStoreFileName = fullfile(lbpConf.dataStoragePath,sprintf('%s.mat',imgId));
if size(currentlbp,1) == 0
    error('cellsize too small')
end
hj = mean(currentlbp(:,:,:));
if size(hj,2)>1
    
    hk = mean(hj);

data = reshape(hk,1,58);
else 
    data = reshape(hj,1,58);
end

save( fullStoreFileName, 'data');

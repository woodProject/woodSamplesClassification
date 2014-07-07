function generateWaveLetImages(imName,dbName,nLevel,outImgName)
startImage=imread (imName);
% nLevel = 4;
nColors = 255;

% % Perform single-level decomposition 
% % of X using db1.  
%  for iLevel = 1:nLevel,
%   [cA{iLevel},cH{iLevel},cV{iLevel},cD{iLevel}] = dwt2(X,'db5');
%   X = cA{iLevel};
% end   
% [cA1,cH1,cV1,cD1] = dwt2(X,'db1');
% 
% % Images coding. 
% cod_X = wcodemat(X,nbcol); 
% cod_cA1 = wcodemat(cA1,nbcol); 
% cod_cH1 = wcodemat(cH1,nbcol); 
% cod_cV1 = wcodemat(cV1,nbcol); 
% cod_cD1 = wcodemat(cD1,nbcol); 
% dec2d = [... 
%         cod_cA1,     cod_cH1;     ... 
%         cod_cV1,     cod_cD1      ... 
%         ];

% Using some plotting commands,
% the following figure is generated.



% startImage=imread ('./imAdjust/1TF001.png');
% nLevel=3;
% nColors=255;
% 
for iLevel = 1:nLevel,
  [cA{iLevel},cH{iLevel},cV{iLevel},cD{iLevel}] = dwt2(startImage,dbName);
  startImage = cA{iLevel};
end

% tiledImage = cA{nLevel};
% for iLevel = nLevel:-1:1,
%   tiledImage = [tiledImage cH{iLevel}; ...
%                 cV{iLevel} cD{iLevel}];
% end
tiledImage = wcodemat(cA{nLevel},nColors);
tiledImage = repmat(tiledImage,[1 1 3]);
for iLevel = nLevel:-1:1,
    %   paddingSize=size(tiledImage)-size(cH{iLevel});
    %   current_cH = padarray(wcodemat(cH{iLevel},nColors),paddingSize,'pre');
    %   current_cV = padarray(wcodemat(cV{iLevel},nColors),paddingSize,'pre');
    %   current_cD = padarray(wcodemat(cD{iLevel},nColors),paddingSize,'pre');
    current_cH=repmat(wcodemat(cH{iLevel},nColors),[1 1 3]);
    current_cV=repmat(wcodemat(cV{iLevel},nColors),[1 1 3]);
    current_cD=repmat(wcodemat(cD{iLevel},nColors),[1 1 3]);
    directions = 'HVD';
    borderSize = 1;
    for ii=1:3
        eval(sprintf('current_c%c(end-(borderSize-1):end,:,1)=255;',directions(ii)));
        eval(sprintf('current_c%c(:,end-(borderSize-1):end,1)=255;',directions(ii)));
        eval(sprintf('current_c%c(end-(borderSize-1):end,:,2:3)=0;',directions(ii)));
        eval(sprintf('current_c%c(:,end-(borderSize-1):end,2:3)=0;',directions(ii)));
    end
    
    paddingSize=size(tiledImage(:,:,1))-size(cH{iLevel});

    tiledImage = adaptAndPaintBorders(tiledImage,paddingSize,borderSize);
    tiledImage = [tiledImage  current_cH; ...
                  current_cV  current_cD];
    tiledImage = drawBorder(tiledImage,borderSize);
end

%figure;imshow(mat2gray(tiledImage));
imwrite(mat2gray(tiledImage),sprintf('./%s_%02d.png',outImgName,nLevel));
end

function colorImg = adaptAndPaintBorders(colorImg,paddingSize,borderSize)
    upLeftCorner = max([floor(paddingSize/2); 1 1],[],1);
    downRightCorner = size(colorImg(:,:,1))-(paddingSize-upLeftCorner+1);
    colorImg = colorImg(upLeftCorner(1):downRightCorner(1), ...
                        upLeftCorner(2):downRightCorner(2),:);
    %place a border                    
    colorImg = drawBorder(colorImg,borderSize);
end

function colorImg=drawBorder(colorImg,borderSize)
    colorImg(end-(borderSize-1):end,:,1)=255;
    colorImg(end-(borderSize-1):end,:,2:3)=0;
    colorImg(:,end-(borderSize-1):end,1)=255;
    colorImg(:,end-(borderSize-1):end,2:3)=0;
    colorImg(1:borderSize,:,1)=255;
    colorImg(1:borderSize,:,2:3)=0;
    colorImg(:,1:borderSize,1)=255;
    colorImg(:,1:borderSize,2:3)=0;
end
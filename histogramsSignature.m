function similitudeMatrix = histogramsSignature(nbeams)
% notes: TF/1.3RB.png,
%        M/1.1RA.png,
%        GG/1.1RB.png & GG/'2.10RA.png
%        are the wired from its batch
%
%%%%%
if ~exist('nbeams','var'), nbeams = 32; end
imagesDir = '/home/sik/Work/escola/recerca/Wood/imagesManipulationCut/';
imageTypes = {'TF', 'F', 'M', 'GG'};
outputDir = '/home/sik/Work/escola/recerca/Wood/outputFigures/intensityModels/';
%outputDir = '/home/sik/Work/escola/recerca/Wood/outputFigures/intensityModels_reajusted/';

imNames = cellfun(@(x) dir(fullfile(imagesDir,x,'*.png')),imageTypes,'UniformOutput',false);

%% Capture the histograms
imHist  = cell(size(imageTypes)); 
for typeIdx = 1:length(imageTypes)
    imHist{typeIdx} = zeros(length(imNames{typeIdx}),nbeams);
    for imId = 1:length(imNames{typeIdx});
        currentImage = imread(fullfile(imagesDir,imageTypes{typeIdx}, imNames{typeIdx}(imId).name));
        imHist{typeIdx}(imId,:) = hist(double(currentImage(:)),nbeams)/numel(currentImage);
    end
end

%% show the models
myColors = jet(length(imageTypes));
intensityModelsFig = figure; hold on;
for typeIdx = 1:length(imageTypes)
    errorbar(mean(imHist{typeIdx},1),std(imHist{typeIdx},1),'Color',myColors(typeIdx,:))
end
hold off;
title('Class Intensity Models');
legend(imageTypes);
saveas(intensityModelsFig,fullfile(outputDir,sprintf('intensityModels_%03dbeams.png',nbeams)));

%% Compute and illustrate the images similitudes
[A, m] = getQCParameters(nbeams);
imHist = cell2mat(imHist');
similitudeMatrix = zeros(size(imHist,1));

for ii = 1:size(imHist,1)
    for jj=1:size(imHist,1)
        similitudeMatrix(ii,jj) = QC(imHist(ii,:), imHist(jj,:), A, m);
    end
end

image4showing = round(1023*mat2gray(similitudeMatrix))+1;
imwrite( label2rgb(imresize(image4showing,10,'nearest'),jet(1024)), ...
         fullfile(outputDir,sprintf('intensityDistances_%03dbeams.png',nbeams)));

%% Most different images
weirdImagesIdx = sort(findTheWeirdSamples(similitudeMatrix));

strImNames = cellfun(@(x) {x(:).name}',imNames,'UniformOutput',false);
strImNames = arrayfun(@(x) strcat([imageTypes{x} filesep], strImNames{x}),1:length(imageTypes),'UniformOutput',false);
strImNames = cat(1,strImNames{:});

display('The following images stand as the more distant to the group')
display(strImNames(weirdImagesIdx))


function weirdImagesIdx = findTheWeirdSamples(simMatrix)
totalSimilitudeCost = sum(simMatrix,2)+sum(simMatrix,1)';
[sortedSimilitudeCost, imageIdx] = sort(totalSimilitudeCost);
[drop, firstWeirdSample] = max(diff(sortedSimilitudeCost)); %#ok<ASGLU>
weirdImagesIdx = imageIdx(firstWeirdSample:end);


    
function [A, m] = getQCParameters(nbeams)
% The dimension of the histogram
N= nbeams; 
% A pair of bins with L_1 distance greater or equal to
% THRESHOLD get a similarity of 0.
THRESHOLD= 3;
% The normalization factor. Should be 0 <= m < 1. 
% 0.9 experimentally yielded good results. 0.5 is the generalization of
% chi^2 which also yields good results.
m= 0.9;

% The sparse bin-similarity matrix. See other demos for fast mex
% computation of this kind of matrix.
A= sparse(N,N);
for i=1:N
    for j=max([1 i-THRESHOLD+1]):min([N i+THRESHOLD-1])
        A(i,j)= 1-(abs(i-j)/THRESHOLD); 
    end
end

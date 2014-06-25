function woodTestReportResults(conf)
% TODO: no need of a balanced set.
% showInit;
[confussionMatrix, estimatedClasses] = getConfusionMatrixResults(conf);
numOfClassSamples = length(conf.dataSamples.sampleID{1});
confussionMatrix =  cellfun(@(x) x./numOfClassSamples,confussionMatrix,'UniformOutput',false);

confussionMatrixVolume = cat(3,confussionMatrix{:});

globalTPPerformance = @(x) trace(x)/length(diag(x));
experimentGlobalTP = cell2mat(cellfun(@(x) globalTPPerformance(x), confussionMatrix, 'UniformOutput',false));

gtClasses = 1:length(conf.dataSamples.sampleTypes);
classTPPerformance = arrayfun(@(x) squeeze(confussionMatrixVolume(x,x,:)),gtClasses,'UniformOutput',false);

showPerformanceDistributionForAllTPR(classTPPerformance,experimentGlobalTP,[conf.dataSamples.sampleTypes {'globalPerformance'}]);

showAndSave_sampleTypeTPR_performance;

showAndSave_globalTPR_performance;

% Printing and saving stuff Functions
    function showInit
        if conf.verboseMode >=1,    fprintf( 'Results ... ' );end
    end
    function showAndSave_globalTPR_performance
        savingName = 'top10_globalTP';
        [topNIndexes, figID] = topNConfusionMatrix( confussionMatrix, ...
                                                    experimentGlobalTP, ...
                                                    5,2, savingName);
        saveas(figID, sprintf('%s.png',savingName));
        dumbTopNConfigurationIntoFile(topNIndexes,sprintf('%s.dat',savingName));
    end

    function showAndSave_sampleTypeTPR_performance
        sampleTypesNames = cellfun(@(x) sprintf('top10_%s_configuration',x),...
                                        conf.dataSamples.sampleTypes,...
                                        'UniformOutput',false);
        for sampleTypeIndx=1:length(sampleTypesNames)
            [topNIndexes, figID] = topNConfusionMatrix( confussionMatrix, ...
                                                        classTPPerformance{sampleTypeIndx}, ...
                                                        5,2, ...
                                                        sampleTypesNames{sampleTypeIndx});
            saveas(figID, sprintf('%s.png',sampleTypesNames{sampleTypeIndx}));
            dumbTopNConfigurationIntoFile(topNIndexes,sprintf('%s.dat',sampleTypesNames{sampleTypeIndx}));
        end
    end

    function dumbTopNConfigurationIntoFile(topNIndexes,fileName)
    fileID = fopen(fileName,'w');
    for topNIndx = 1:length(topNIndexes)
        fprintf(fileID,'-----------\n');
        cellfun(  @(x)  fprintf(fileID,'%s\n',x),...
                        conf.experiment(topNIndexes(topNIndx)).featureList,...
                        'UniformOutput',false);
    end
    fclose(fileID);
    end

end

function [topNIndexes, figID] = topNConfusionMatrix(confusionMatrixColection,experimentPerformance,numFigureCols,numFigureRows,figureName)
if exist('figureName','var')==1
    figID=figure('name',figureName);
else
    figID=figure;
end
[dropVal,sortingIndx] = sort(experimentPerformance,'descend');
for ii=1:numFigureCols*numFigureRows
    subplot(numFigureRows,numFigureCols,ii); 
    currentConfusionMatrix = confusionMatrixColection{sortingIndx(ii)};
    showConfusionMatrix(currentConfusionMatrix,sprintf('%c',64+ii));
end
set(figID,'position',[ 209, 323, 1292, 464]);
topNIndexes = sortingIndx(1:numFigureCols*numFigureRows);
end

function showConfusionMatrix(confusionMatrix,matrixIDName)
imshow(confusionMatrix);
if exist('matrixIDName','var')==1
    text(0,0,matrixIDName,'HorizontalAlignment', 'right');
end
%% plotCosmetics
colormap jet;
axis on;
set(gca,'xaxisLocation','top');
for tick = ['x', 'y']
    set(gca,[tick 'tick'],1:4,[tick 'tickLabel'],{'TF','F','M','GG'});
end
for jj=1:size(confusionMatrix,1)
    for kk=1:size(confusionMatrix,2)
        text(   jj,kk,...
            sprintf('%03d',round(100*confusionMatrix(jj,kk))),...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'middle'  ...
            );
    end
end
end

function showPerformanceDistributionForAllTPR(classTPPerformance,experimentGlobalTP,legendNames)
myColors = [jet(4); 0 0 0];
histogramBeams = linspace(0,1,20);
performanceHist = cellfun(@(x) histc(x,histogramBeams),classTPPerformance,'UniformOutput',false);
performanceHist = [performanceHist {histc(experimentGlobalTP,histogramBeams)}];
figure; hold on;
for ii=1:length(performanceHist)
    plot(linspace(0,1,20)*100,performanceHist{ii},'color',myColors(ii,:));
end
xlabel('percentage of well detected samples')
ylabel('number of configurations producing this result')
legend(legendNames)
end

function [confusionMatrix,estimatedClassCollection] = getConfusionMatrixResults(conf)
classificationDataDir = fullfile( conf.calcPoolDir, 'classificationData', conf.dataSamples.datasetID);
numOfExperiments = length(conf.experiment);
confusionMatrix = cell(numOfExperiments,1);
estimatedClassCollection = cell(numOfExperiments,1);
for experimentIdx = 1:numOfExperiments
    fileName = fullfile(classificationDataDir,sprintf('%s.mat',conf.experiment(experimentIdx).id));
    load(fileName,'estimatedClass');
    estimatedClassCollection{experimentIdx} = estimatedClass;
    gtLabels = uint8(meshgrid(1:size(estimatedClass,2),1:size(estimatedClass,1)));
    confusionMatrix{experimentIdx} = confusionmat(gtLabels(:),estimatedClass(:));
end
end
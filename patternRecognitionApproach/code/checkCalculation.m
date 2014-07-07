function tobeComputedFlag = checkCalculation(experimentList,classificationCaclutalionPoint)
if ensureDir(classificationCaclutalionPoint)
    tobeComputedFlag = true(length(experimentList),1);
else
    alreadyCalculatedExperient = dir(fullfile(classificationCaclutalionPoint,'*.mat'));
    alreadyCalculatedExperient = cellfun(@(x) x(1:end-4),{alreadyCalculatedExperient.name}','UniformOutput',false);
    tobeComputedFlag = ~ismember(experimentList,alreadyCalculatedExperient);
end
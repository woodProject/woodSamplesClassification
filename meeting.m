for ii=1:8
    conf = woodTestConfigure(sprintf('test%d',ii));
    woodtest(conf);
end

%%
for ii=1:8
    conf = woodTestConfigure(sprintf('test%d',ii));
    showWoodResults(conf)
    pause;
end

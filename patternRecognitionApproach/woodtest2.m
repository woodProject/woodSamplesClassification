addpath('./code')
conf = woodTestConfigure2('test1');%'test1i2');
woodTestEnsureFeatures(conf);
woodTestClassificationTest(conf);
woodTestReportResults(conf);
addpath('./code')
conf = woodTestConfigure2('test33');%'test1i2');
woodTestEnsureFeatures(conf);
woodTestClassificationTest(conf);
woodTestReportResults(conf);
addpath('./code')
conf = woodTestConfigure2('basicGLCM');%'test1i2');
woodTestEnsureFeatures(conf);
woodTestClassificationTest(conf);
woodTestReportResults(conf);
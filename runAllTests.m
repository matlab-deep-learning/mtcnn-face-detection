function runAllTests
import matlab.unittest.TestRunner;
import matlab.unittest.Verbosity;
import matlab.unittest.plugins.CodeCoveragePlugin;
import matlab.unittest.plugins.TestReportPlugin;
import matlab.unittest.plugins.codecoverage.CoverageReport;

suite = testsuite(pwd, 'IncludeSubfolders', true);

resultsDir = "public/jobs/" + getenv("GITHUB_RUN_ID");
testResultsDir = resultsDir + "/test-results";
coverageDir = resultsDir + "/code-coverage";
[~,~] = mkdir(testResultsDir);
[~,~] = mkdir(coverageDir);

runner = TestRunner.withTextOutput('OutputDetail', Verbosity.Detailed);
runner.addPlugin(TestReportPlugin.producingHTML(testResultsDir,'IncludingPassingDiagnostics',true));
runner.addPlugin(CodeCoveragePlugin.forFolder({'code'}, 'IncludingSubfolders', true, 'Producing', CoverageReport(coverageDir)));

results = runner.run(suite);

nfailed = nnz([results.Failed]);
assert(nfailed == 0, [num2str(nfailed) ' test(s) failed.']);
end

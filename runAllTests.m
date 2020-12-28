function runAllTests
import matlab.unittest.TestRunner;
import matlab.unittest.Verbosity;
import matlab.unittest.plugins.CodeCoveragePlugin;
import matlab.unittest.plugins.TestReportPlugin;
import matlab.unittest.plugins.codecoverage.CoverageReport;

suite = testsuite(pwd, 'IncludeSubfolders', true);

[~,~] = mkdir('public/test-results');
[~,~] = mkdir('public/code-coverage');

runner = TestRunner.withTextOutput('OutputDetail', Verbosity.Detailed);
runner.addPlugin(TestReportPlugin.producingHTML('public/test-results'));
runner.addPlugin(CodeCoveragePlugin.forFolder({'code'}, 'IncludingSubfolders', true, 'Producing', CoverageReport('public/code-coverage')));

results = runner.run(suite);

nfailed = nnz([results.Failed]);
assert(nfailed == 0, [num2str(nfailed) ' test(s) failed.']);
end

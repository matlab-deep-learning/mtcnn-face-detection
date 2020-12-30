classdef DocTest < matlab.unittest.TestCase
    
    methods(TestClassSetup)
        function addDocToPath(testCase)
            testCase.applyFixture(PathFixture(fullfile(mtcnnRoot,'doc')));
        end
    end
    
    methods(TestMethodSetup)
        function captureAndCleanFigures(testCase)
            figs = findall(groot,'Type','figure');
            testCase.addTeardown(@testCase.logAndClose, figs);
        end
    end
    methods(Access=private)
        function logAndClose(testCase, figs)
            openedFigs = setdiff(findall(groot,'Type','figure'),figs);
            for fig=openedFigs'
                testCase.log(1,FigureDiagnostic(fig));
            end
            close(openedFigs);
        end
    end
    
    methods(Test)
        function executesWithoutError(~)
            GettingStarted;
        end
    end
end

function f = FigureDiagnostic(varargin)
f = matlab.unittest.diagnostics.FigureDiagnostic(varargin{:});
end
    
function f = PathFixture(varargin)
f = matlab.unittest.fixtures.PathFixture(varargin{:});
end
classdef DocTest < matlab.unittest.TestCase
    
    methods(TestClassSetup)
        function addDocToPath(testCase)
            testCase.applyFixture(PathFixture(fullfile(mtcnnRoot,'doc')));
        end
    end
    
    methods(TestMethodSetup)
        function captureAndCleanFigures(testCase)
            figs = findall(groot,'Type','figure');
            testCase.addTeardown(@() close(...
                setdiff(findall(groot,'Type','figure'),figs)));
        end
    end
    
    
    methods(Test)
        function executesWithoutError(~)
            GettingStarted;
        end
    end
end

function f = PathFixture(varargin)
f = matlab.unittest.fixtures.PathFixture(varargin{:});
end
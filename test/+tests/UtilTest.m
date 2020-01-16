classdef UtilTest < matlab.unittest.TestCase
    % Test helper functions in the util package.
    
    % Copyright 2019 The MathWorks, Inc.
    
    methods (Test)
        function testCalcScales(test)
            im = zeros(50, 50, 3);
            defaultScale = 12;
            minSize = 12;
            maxSize = [];
            expectedScales = [1, sqrt(2), 2, 2*sqrt(2), 4];
            
            scales = mtcnn.util.calculateScales(im, minSize, maxSize, defaultScale);
            
            test.verifyEqual(scales, expectedScales, "RelTol", 1e-10);
        end
        
        function testCalcScalesSetMax(test)
            im = zeros(50, 50, 3);
            defaultScale = 12;
            minSize = 12;
            maxSize = 34;
            expectedScales = [1, sqrt(2), 2, 2*sqrt(2)];
            
            scales = mtcnn.util.calculateScales(im, minSize, maxSize, defaultScale);
            
            test.verifyEqual(scales, expectedScales, "RelTol", 1e-10);
        end
        
        function testCalcScalesSetMin(test)
            im = zeros(50, 50, 3);
            defaultScale = 12;
            minSize = 24;
            maxSize = 34;
            expectedScales = [2, 2*sqrt(2)];
            
            scales = mtcnn.util.calculateScales(im, minSize, maxSize, defaultScale);
            
            test.verifyEqual(scales, expectedScales, "RelTol", 1e-10);
        end
        
        function testCalcScalesPyramidScale(test)
            im = zeros(50, 50, 3);
            defaultScale = 12;
            minSize = 12;
            maxSize = [];
            pyramidScale = 2;
            expectedScales = [1, 2, 4];
            
            scales = mtcnn.util.calculateScales(im, minSize, maxSize, ...
                                                defaultScale, pyramidScale);
            
            test.verifyEqual(scales, expectedScales, "RelTol", 1e-10);
        end
        
        function testCalcScalesPyramidScaleLessThanOne(test)
            im = zeros(50, 50, 3);
            defaultScale = 12;
            minSize = 12;
            maxSize = [];
            pyramidScale = 0.1;
            
            calcScales = @() mtcnn.util.calculateScales(im, minSize, maxSize, ...
                                                defaultScale, pyramidScale);
            
            test.verifyError(calcScales, "mtcnn:util:calculateScales:badScale")
        end
        
        function testMakeSquare(test)
            bbox = [1, 2, 3, 4];
            expectedBox = [0.5, 2, 4, 4];
            
            resizedBox = mtcnn.util.makeSquare(bbox);
            
            test.verifyEqual(resizedBox, expectedBox);
        end
        
        function testApplyCorrection(test)
            bbox = [1, 2, 3, 3];
            correction = [0, -0.5, 0.5, 1];
            expected = [1, 0.5, 4.5, 6];
            
            corrected = mtcnn.util.applyCorrection(bbox, correction);
            
            test.verifyEqual(corrected, expected);
        end
    end
end
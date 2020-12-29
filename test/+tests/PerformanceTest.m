classdef PerformanceTest < matlab.perftest.TestCase
    % Test the run-time performance of face detection.
    
    %  Copyright 2019 The MathWorks, Inc.
    
    properties
        Image
        Reference
    end
    
    properties (TestParameter)
        imSize = struct('small', 0.5, 'med', 1, 'large', 2);
        imFaces = {'few', 'many'};
    end
    
    methods (TestClassSetup)
        function setupTestImage(test)
            test.Image = imread("visionteam.jpg");
        end
        
        function loadReference(test)
            test.Reference = load(fullfile(mtcnnTestRoot(), ...
                                            "resources", ...
                                            "ref.mat"));
        end
    end
    
    methods (Test)
        function testDefaultDetect(test, imSize, imFaces)
            
            switch imFaces
                case 'few'
                    im = test.Image;
                case 'many'
                    im = repmat(test.Image(25:125, :, :), [4, 1]);
            end
            im = imresize(im, imSize);
            
            test.startMeasuring();
            [bboxes, scores, landmarks] = mtcnn.detectFaces(im);r
            [bboxes, scores, landmarks] = mtcnn.detectFaces(im);
            [bboxes, scores, landmarks] = mtcnn.detectFaces(im);
            test.stopMeasuring();
        end
        
        function testLowLevelDetect(test, imSize, imFaces)
            
            switch imFaces
                case 'few'
                    im = test.Image;
                case 'many'
                    im = repmat(test.Image(25:125, :, :), [4, 1]);
            end
            im = imresize(im, imSize);
            
            detector = mtcnn.Detector();
            
            test.startMeasuring();
            [bboxes, scores, landmarks] = detector.detect(im);
            test.stopMeasuring();
        end
    end
    
end
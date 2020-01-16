classdef DetectorTest < matlab.unittest.TestCase
    % Test cases for Detector class.
    
    % Copyright 2019 The MathWorks, Inc.
    
    properties
        Image
        Reference
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
        
        function testCreate(test)
            detector = mtcnn.Detector();
        end
        
        function testDetectwithDefaults(test)
            detector = mtcnn.Detector();
            
            [bboxes, scores, landmarks] = detector.detect(test.Image);
            
            test.verifyEqual(size(bboxes), [6, 4]);
            test.verifyEqual(size(scores), [6, 1]);
            test.verifyEqual(size(landmarks), [6, 5, 2]);
            
            test.verifyEqual(bboxes, test.Reference.bboxes, "RelTol", 1e-6);
            test.verifyEqual(scores, test.Reference.scores, "RelTol", 1e-6);
            test.verifyEqual(landmarks, test.Reference.landmarks, "RelTol", 1e-6);
        end
        
        %% Pyramid parameters
        function testMinSize(test)
            detector = mtcnn.Detector("MinSize", 240);
            [bboxes, scores, landmarks] = detector.detect(test.Image);
            
            test.verifyEmpty(bboxes);
            test.verifyEmpty(scores);
            test.verifyEmpty(landmarks);
        end
        
        function testMinMinSize(test)
            createDetector = @() mtcnn.Detector("MinSize", 1);
            
            test.verifyError(createDetector, "MATLAB:validators:mustBeGreaterThan")
        end
        
        function testMaxSize(test)
            detector = mtcnn.Detector("MaxSize", 12);
            [bboxes, scores, landmarks] = detector.detect(test.Image);
            
            test.verifyEmpty(bboxes);
            test.verifyEmpty(scores);
            test.verifyEmpty(landmarks);
        end
        
        function testDetectwithMoreScales(test)
            detector = mtcnn.Detector("PyramidScale", sqrt(1.5));
            
            [bboxes, scores, landmarks] = detector.detect(test.Image);
            
            test.verifyEqual(size(bboxes), [6, 4]);
            test.verifyEqual(size(scores), [6, 1]);
            test.verifyEqual(size(landmarks), [6, 5, 2]);
            
            boxOverlaps = bboxOverlapRatio(bboxes, test.Reference.bboxes);
            test.verifyEqual(max(boxOverlaps) > 0.8, true(1, 6));
            test.verifyEqual(scores, test.Reference.scores, "RelTol", 1e-3);
        end
        
        %% Thresholds
        function testConfThresholds(test)
            detector = mtcnn.Detector("ConfidenceThresholds", [0.8, 0.8, 0.9]);
            
            [bboxes, scores, landmarks] = detector.detect(test.Image);
            
            test.verifyNotEmpty(bboxes);
            test.verifyNotEmpty(scores);
            test.verifyNotEmpty(landmarks);
        end
        
        function testNmsThresholds(test)
            detector = mtcnn.Detector("NmsThresholds", [0.4, 0.4, 0.4]);
            
            [bboxes, scores, landmarks] = detector.detect(test.Image);
            
            test.verifyNotEmpty(bboxes);
            test.verifyNotEmpty(scores);
            test.verifyNotEmpty(landmarks);
        end
        
        %% GPU
        function testGpuDetect(test)
            % filter if no GPU present
            test.assumeGreaterThan(gpuDeviceCount, 0);
            
            detector = mtcnn.Detector("UseGPU", true);
            [bboxes, scores, landmarks] = detector.detect(test.Image);
            
            test.verifyEqual(size(bboxes), [6, 4]);
            test.verifyEqual(size(scores), [6, 1]);
            test.verifyEqual(size(landmarks), [6, 5, 2]);
            
            % Reference was taken on the CPU so increase relative tolerance
            test.verifyEqual(bboxes, test.Reference.bboxes, "RelTol", 1e-1);
            test.verifyEqual(scores, test.Reference.scores, "RelTol", 1e-1);
            test.verifyEqual(landmarks, test.Reference.landmarks, "RelTol", 1e-1);
        end
    end
end
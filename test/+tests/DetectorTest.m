classdef DetectorTest < matlab.unittest.TestCase
    % Test cases for Detector class.
    
    % Copyright 2019 The MathWorks, Inc.
    
    properties
        Image
        Reference
    end
    
    properties (TestParameter)
        imageTypeConversion = struct("uint8", @(x) x, ...
            "single", @(x) single(x)/255, ...
            "double", @(x) double(x)/255)
        useDagNet = {false, true}
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
        
        function testDetectwithDefaults(test, imageTypeConversion, useDagNet)
            % Test expected inputs with images of type uint8, single,
            % double (float images are scaled 0-1);
            detector = mtcnn.Detector("UseDagNet", useDagNet);
            
            inputImage = imageTypeConversion(test.Image);
            
            [bboxes, scores, landmarks] = detector.detect(inputImage);
            
            test.verifySize(bboxes, [6, 4]);
            test.verifySize(scores, [6, 1]);
            test.verifySize(landmarks, [6, 5, 2]);
            
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
            
            test.verifySize(bboxes, [6, 4]);
            test.verifySize(scores, [6, 1]);
            test.verifySize(landmarks, [6, 5, 2]);
            
            boxOverlaps = bboxOverlapRatio(bboxes, test.Reference.bboxes);
            test.verifyEqual(max(boxOverlaps) > 0.8, false(1, 6));
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
        function testGpuDetect(test, imageTypeConversion, useDagNet)
            
            % filter if no GPU present
            test.assumeGreaterThan(gpuDeviceCount, 0, "This test only runs with GPUs present");
            
            inputImage = imageTypeConversion(test.Image);
            detector = mtcnn.Detector("UseGPU", true, "UseDagNet", useDagNet);
            [bboxes, scores, landmarks] = detector.detect(inputImage);
            
            test.verifySize(bboxes, [6, 4]);
            test.verifySize(scores, [6, 1]);
            test.verifySize(landmarks, [6, 5, 2]);
            
            % Reference was taken on the CPU so increase relative tolerance
            test.verifyEqual(bboxes, test.Reference.bboxes, "RelTol", 1e-1);
            test.verifyEqual(scores, test.Reference.scores, "RelTol", 1e-1);
            test.verifyEqual(landmarks, test.Reference.landmarks, "RelTol", 1e-1);
        end
    end
end

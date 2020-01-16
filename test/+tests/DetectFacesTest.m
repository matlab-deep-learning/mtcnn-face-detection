classdef DetectFacesTest < matlab.unittest.TestCase
    % Test the high-level api for detecting faces.
    
    %  Copyright 2019 The MathWorks, Inc.
    
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
        function testDefaultDetect(test)
            [bboxes, scores, landmarks] = mtcnn.detectFaces(test.Image);
            
            test.assertEqual(size(bboxes), [6, 4]);
            test.assertEqual(size(scores), [6, 1]);
            test.assertEqual(size(landmarks), [6, 5, 2]);
            
            test.assertEqual(bboxes, test.Reference.bboxes, "RelTol", 1e-6);
            test.assertEqual(scores, test.Reference.scores, "RelTol", 1e-6);
            test.assertEqual(landmarks, test.Reference.landmarks, "RelTol", 1e-6);
        end
    end
    
end
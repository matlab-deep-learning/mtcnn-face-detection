classdef RegressionTest < matlab.unittest.TestCase
    % Test cases for known bugs that have been fixed
    
    % Copyright 2020 The MathWorks, Inc.

    methods (Test)
        function testSelectStrongestBug(test)
            % GitHub issue #17
            im = imread("visionteam1.jpg");

            [bboxes, scores, landmarks] = mtcnn.detectFaces(im, "ConfidenceThresholds", repmat(0.01, [3, 1]));
            for iBox = 1:size(bboxes, 1)
                test.assertInBox(landmarks(iBox, :, :), bboxes(iBox, :));
            end
        end
    end
    
    methods
        function assertInBox(test, landmarks, box)
            % check that all landmarks are within the bounding box
            tf = all(inpolygon(landmarks(1, :, 1), ...
                            landmarks(1, :, 2), ...
                            [box(1), box(1) + box(3), box(1) + box(3), box(1)], ...
                            [box(2), box(2), box(2) + box(4), box(2) + box(4)]));
            test.assertTrue(tf, "Landmarks should all be inside bounding box");
        end
    end

end
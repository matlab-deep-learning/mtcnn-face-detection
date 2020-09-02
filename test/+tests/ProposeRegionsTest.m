classdef ProposeRegionsTest < matlab.unittest.TestCase
    % Test propose regions function
    
    %  Copyright 2020 The MathWorks, Inc.
    
    properties (Constant)
        Image = single(imread("visionteam.jpg"))/255*2 - 1
    end
    
    properties (TestParameter)
        getNet = struct("dl", @() mtcnn.util.DlNetworkStrategy(false) , ...
                        "dag", @() mtcnn.util.DagNetworkStrategy(false));
    end
    
    methods (Test)
        function testOutputs(test, getNet)
            scale = 2;
            conf = 0.5;
            strategy = getNet();
            strategy.load();
            
            [box, score] = mtcnn.proposeRegions(test.Image, scale, conf, strategy);
            
            test.verifyOutputs(box, score);
        end
        
        function test1DActivations(test, getNet)
            % Test for bug #6 (1xn activations causes proposeRegions to
            % fail)
            cropped = imcrop(test.Image, [300, 42, 65, 38]);
            scale = 3;
            conf = 0.5;
            strategy = getNet();
            strategy.load();
            
            [box, score] = mtcnn.proposeRegions(cropped, scale, conf, strategy);
            
            test.verifyOutputs(box, score);
        end
        
    end
    
    methods
        function verifyOutputs(test, box, score)
            % helper to check expected outputs of proposeRegions
            test.verifyEqual(size(box, 2), 4, ...
                "first output should be nx4 bounding box list");
            test.verifyEqual(size(score, 2), 1, ...
                "second output should be nx1 face probabilities");
            test.verifyEqual(size(box, 1), size(score, 1), ...
                "should be 1 box for each probability");
        end
    end
    
end
    
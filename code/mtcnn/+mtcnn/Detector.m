classdef Detector < matlab.mixin.SetGet
    % MTCNN Detector class
    %
    %   When creating an mtcnn.Detector object
    %   pass in any of the public properties as Name-Value pairs to
    %   configure the detector. For more details of the available
    %   options see the help for mtcnn.detectFaces.
    %
    %   See also: mtcnn.detectFaces
    
    % Copyright 2019 The MathWorks, Inc.
    
    properties
        % Approx. min size in pixels
        MinSize {mustBeGreaterThan(MinSize, 12)} = 24
        % Approx. max size in pixels
        MaxSize = []
        % Pyramid scales for region proposal
        PyramidScale = sqrt(2)
        % Confidence threshold at each stage of detection
        ConfidenceThresholds = [0.6, 0.7, 0.8]
        % Non-max suppression overlap thresholds
        NmsThresholds = [0.5, 0.5, 0.5]
        % Use GPU for processing or not
        UseGPU = false
    end
    
    properties (Constant)
        % Input sizes (pixels) of the networks
        PnetSize = 12
        RnetSize = 24
        OnetSize = 48
    end
    
    properties (SetAccess=private)
        % Weights for the networks
        PnetWeights
        RnetWeights
        OnetWeights
    end
    
    methods
        function obj = Detector(varargin)
            % Create an mtcnn.Detector object
            
            obj.loadWeights();
            
            if nargin > 1
                obj.set(varargin{:});
            end
            
            if obj.UseGPU()
                obj.PnetWeights = dlupdate(@gpuArray, obj.PnetWeights);
                obj.RnetWeights = dlupdate(@gpuArray, obj.RnetWeights);
                obj.OnetWeights = dlupdate(@gpuArray, obj.OnetWeights);
            end
        end
        
        function [bboxes, scores, landmarks] = detect(obj, im)
            % detect    Run the detection algorithm on an image.
            % 
            %   Args:
            %       im  - RGB input image for detection
            %
            %   Returns:
            %       bbox        - nx4 array of face bounding boxes in the 
            %                   format [x, y, w, h]
            %       scores      - nx1 array of face probabilities
            %       landmarks   - nx5x2 array of facial landmarks
            %
            %   See also: mtcnn.detectFaces
            
            im = obj.prepImage(im);
            
            bboxes = [];
            scores = [];
            landmarks = [];
            
            %% Stage 1 - Proposal
            scales = mtcnn.util.calculateScales(im, ...
                                                obj.MinSize, ...
                                                obj.MaxSize, ...
                                                obj.PnetSize, ...
                                                obj.PyramidScale);
            
            for scale = scales
                [thisBox, thisScore] = ...
                    mtcnn.proposeRegions(im, scale, ...
                                            obj.ConfidenceThresholds(1), ...
                                            obj.PnetWeights);
                bboxes = cat(1, bboxes, thisBox);
                scores = cat(1, scores, thisScore);
            end
            
            if ~isempty(scores)
                [bboxes, ~] = selectStrongestBbox(gather(bboxes), scores, ...
                    "RatioType", "Min", ...
                    "OverlapThreshold", obj.NmsThresholds(1));
            else
                return % No proposals found
            end
            
            %% Stage 2 - Refinement
            [cropped, bboxes] = obj.prepBbox(im, bboxes, obj.RnetSize);
            [probs, correction] = mtcnn.rnet(cropped, obj.RnetWeights);
            [scores, bboxes] = obj.processOutputs(probs, correction, bboxes, 2);
            
            if isempty(scores)
                return
            end
            
            %% Stage 3 - Output
            [cropped, bboxes] = obj.prepBbox(im, bboxes, obj.OnetSize);
            
            % Adjust bboxes for the behaviour of imcrop
            bboxes(:, 1:2) = bboxes(:, 1:2) - 0.5;
            bboxes(:, 3:4) = bboxes(:, 3:4) + 1;
            
            [probs, correction, landmarks] = mtcnn.onet(cropped, obj.OnetWeights);
            
            % landmarks are relative to uncorrected bbox
            landmarks = extractdata(landmarks)';
            x = bboxes(:, 1) + landmarks(:, 1:5).*(bboxes(:, 3));
            y = bboxes(:, 2) + landmarks(:, 6:10).*(bboxes(:, 4));
            landmarks = cat(3, x, y);
            landmarks(extractdata(probs(2, :))' < obj.ConfidenceThresholds(3), :, :) = [];
            
            [scores, bboxes] = obj.processOutputs(probs, correction, bboxes, 3);
            
            % Gather and cast the outputs
            bboxes= gather(double(bboxes));
            scores = gather(double(scores));
            landmarks = gather(double(landmarks));
        end
    end
    
    methods (Access=private)
        function loadWeights(obj)
            % loadWeights   Load the network weights from file.
            obj.PnetWeights = load(fullfile(mtcnnRoot(), "weights", "pnet.mat"));
            obj.RnetWeights = load(fullfile(mtcnnRoot(), "weights", "rnet.mat"));
            obj.OnetWeights = load(fullfile(mtcnnRoot(), "weights", "onet.mat"));
        end
        
        function [cropped, bboxes] = prepBbox(obj, im, bboxes, outputSize)
            % prepImages    Pre-process the images and bounding boxes.
            bboxes = mtcnn.util.makeSquare(bboxes);
            bboxes = round(bboxes);
            cropped = mtcnn.util.cropImage(im, bboxes, outputSize);
            cropped = dlarray(cropped, "SSCB");
            
        end
        
        function [scores, bboxes] = ...
                processOutputs(obj, probs, correction, bboxes, netIdx)
            % processOutputs    Post-process the output values.
            faceProbs = extractdata(probs(2, :))';
            correction = extractdata(correction)';
            bboxes = mtcnn.util.applyCorrection(bboxes, correction);
            bboxes(faceProbs < obj.ConfidenceThresholds(netIdx), :) = [];
            scores = faceProbs(faceProbs > obj.ConfidenceThresholds(netIdx));
            if ~isempty(scores) 
                [bboxes, ~] = selectStrongestBbox(gather(bboxes), scores, ...
                                "RatioType", "Min", ...
                                "OverlapThreshold", obj.NmsThresholds(netIdx));
            end
        end
        
        function outIm = prepImage(obj, im)
            % convert the image to the correct scaling and type
            % All images should be scaled to -1 to 1 and of single type
            % also place on the GPU if required
            
            switch class(im)
                case "uint8"
                    outIm = single(im)/255*2 - 1;
                case "single"
                    % expect floats to be 0-1 scaled
                    outIm = im*2 - 1;
                case "double"
                    outIm = single(im)*2 - 1;
                otherwise
                    error("mtcnn:Detector:UnsupportedType", ...
                        "Input image is of unsupported type '%s'", class(im));
            end
            
            if obj.UseGPU()
                outIm = gpuArray(outIm);
            end
            
        end
    end
end
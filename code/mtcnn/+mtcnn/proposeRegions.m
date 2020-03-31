function [bboxes, scores] = proposeRegions(im, scale, threshold, weightsOrNet)
% proposeRegions    Generate region proposals at a given scale.
%
% Args:
%   im          - Input image -1 to 1 range, type single
%   scale       - Scale to run proposal at
%   threshold   - Confidence threshold to accept proposal
%   weights     - P-Net weights struct or trained network
%
% Returns:
%   bboxes      - Nx4 array of bounding boxes
%   scores      - Nx1 array of region scores

% Copyright 2019 The MathWorks, Inc.

    useDagNet = isa(weightsOrNet, "DAGNetwork");
    assert(isa(im, "single"), "mtcnn:proposeRegions:wrongImageType", ...
        "Input image should be a single scale -1 to 1");

    % Stride of the proposal network
    stride = 2;
    % Field of view of the proposal network in pixels
    pnetSize = 12;
    
    im = imresize(im, 1/scale);
    
    if useDagNet
        % need to use activations as we don't know what size it will be
        result = weightsOrNet.activations(im, "concat");
        probability = gather(result(:,:,1:2,:));
        correction = gather(result(:,:,3:end,:));
    else
        im = dlarray(im, "SSCB");
        [probability, correction] = mtcnn.pnet(im, weightsOrNet);
        probability = extractdata(gather(probability));
        correction = extractdata(gather(correction));
    end
    
    
    faces = probability(:,:,2) > threshold;
    if sum(faces, 'all') == 0
        bboxes = [];
        scores = [];
        return
    end
    
    linCoord = find(faces(:));
    [iY, iX] = ind2sub(size(faces), linCoord);
    
    % Generate bounding boxes from positive locations
    bboxes = [scale*stride*(iX - 1) + 1, scale*stride*(iY - 1) + 1];
    bboxes(:, 3:4) = scale*pnetSize;
    
    % Apply bounding box correction
    linCorrection = reshape(correction, [], 4);
    scaledOffset = scale*pnetSize*linCorrection(linCoord, :);
    bboxes = bboxes + scaledOffset;
    
    linProb = reshape(probability, [], 2);
    scores = linProb(linCoord, 2);
    
end

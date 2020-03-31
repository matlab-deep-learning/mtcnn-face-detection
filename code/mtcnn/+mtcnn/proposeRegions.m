function [bboxes, scores] = proposeRegions(im, scale, threshold, weights)
% proposeRegions    Generate region proposals at a given scale.
%
% Args:
%   im          - Input image 0-255 range
%   scale       - Scale to run proposal at
%   threshold   - Confidence threshold to accept proposal
%   weights     - P-Net weights struct
%
% Returns:
%   bboxes      - Nx4 array of bounding boxes
%   scores      - Nx1 array of region scores

% Copyright 2019 The MathWorks, Inc.

    % Stride of the proposal network
    stride = 2;
    % Field of view of the proposal network in pixels
    pnetSize = 12;
    
    im = imresize(im, 1/scale);
    im = dlarray(single(im)./255*2 - 1, "SSCB");
    
    [probability, correction] = mtcnn.pnet(im, weights);
    
    probability = extractdata(gather(probability));
    correction = extractdata(gather(correction));
    
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

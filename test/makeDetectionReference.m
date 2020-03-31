function makeDetectionReference()
    % Run the detector in known good config to create reference boxes,
    % scores and landmarks for regression tests.
    im = imread("visionteam.jpg");
    [bboxes, scores, landmarks] = mtcnn.detectFaces(im);
    
    filename = fullfile(mtcnnTestRoot(), "resources", "ref.mat");
    save(filename, "bboxes", "scores", "landmarks");
    
end
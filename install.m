function install()
    
%  Copyright 2019 The MathWorks, Inc.

    folder = fileparts(mfilename('fullpath'));
    pathsToAdd = projectPaths();
    for iPath = 1:numel(pathsToAdd)
        addpath(fullfile(folder, char(pathsToAdd(iPath))));
    end
    
    % generate DAG net versions if not there already
    nets = ["p", "r", "o"];
    for iNet = 1:numel(nets)
        thisNet = nets(iNet);
        dagFile = fullfile(mtcnnRoot, 'weights', ...
            strcat('dag', char(upper(thisNet)), 'Net.mat'));
        if ~isfile(dagFile)
            net = mtcnn.util.convertToDagNet(thisNet);
            save(dagFile, "net");
        end
    end
end
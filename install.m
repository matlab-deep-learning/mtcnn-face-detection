function install()
    
%  Copyright 2019 The MathWorks, Inc.

    folder = fileparts(mfilename('fullpath'));
    pathsToAdd = projectPaths();
    for iPath = 1:numel(pathsToAdd)
        addpath(fullfile(folder, pathsToAdd(iPath)));
    end
end
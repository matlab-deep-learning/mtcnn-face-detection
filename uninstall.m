function uninstall()
    
%  Copyright 2019 The MathWorks, Inc.

    folder = fileparts(mfilename('fullpath'));
    pathsToRemove = projectPaths();
    for iPath = 1:numel(pathsToRemove)
        rmpath(fullfile(folder, pathsToRemove(iPath)));
    end
end
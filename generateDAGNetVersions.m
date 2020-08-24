function generateDAGNetVersions
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
classdef DagNetworkStrategy < handle
    
    properties (SetAccess=private)
        % Trained Dag networks
        Pnet
        Rnet
        Onet
    end
    
    methods
        function obj = DagNetworkStrategy()
        end
        
        function load(obj)
            % loadWeights   Load the network weights from file.
            obj.Pnet = importdata(fullfile(mtcnnRoot(), "weights", "dagPNet.mat"));
            obj.Rnet = importdata(fullfile(mtcnnRoot(), "weights", "dagRNet.mat"));
            obj.Onet = importdata(fullfile(mtcnnRoot(), "weights", "dagONet.mat"));
        end
        
        function pnet = getPNet(obj)
            pnet = obj.Pnet;
        end
        
        function [probs, correction] = applyRNet(obj, im)
            output = obj.Rnet.predict(im);
            
            probs = output(:,1:2);
            correction = output(:,3:end);
        end
        
        function [probs, correction, landmarks] = applyONet(obj, im)
            output = obj.Onet.predict(im);
            
            probs = output(:,1:2);
            correction = output(:,3:6);
            landmarks = output(:,7:end);
        end
        
    end
end
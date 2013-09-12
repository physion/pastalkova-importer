% Import Pastalkova Lab Experiment
%
%
%   experiment = ImportExperiment(dataStoreCoordinator, parameters, behavioralData)
%
%     context: us.physion.ovation.DataContext
%
%     project : us.physion.ovation.domain.Project
%
%     parameters: parameters structure via load()-ing a parameters .MAT
%     file
%
%     behavioralData: structure via load()-ing a BehavElectrData.mat
%     file
% 
%     sourceProtocol: Protocol URI for source (brain, brain area) derivation
%      
%     sourceProtocolParameters: Protocol parameters for Source derivation
%      
%     sourceDerivationDeviceParameters: Device parameters for Source derivation
     

% Copyright (c) 2012 Physion Consulting LLC

function [exp, epochs] = ImportExperiment(ctx,...
        project,...
        parameters,...
        data,...
        srcProtocol,...
        srcProtocolParameters,...
        srcDeviceParameters)
    
    narginchk(7, 7);
    
    disp('Importing Ovation structure...');
    [~, group] = importParameters(ctx,...
        project,...
        parameters,...
        data.xml,...
        srcProtocol,...
        srcProtocolParameters,...
        srcDeviceParameters);
    
    disp('Importing Epochs...');
    epochs = importEpochs(group, parameters, data);
    
    exp = group.getExperiment();
end
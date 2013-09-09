function [exp, epochs] = ImportExperiment(ctx, project, parameters, data)
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
   
   % Copyright (c) 2012 Physion Consulting LLC
    
    disp('Importing Ovation structure...');
    [~, group] = importParameters(ctx, project, parameters, data.xml);
    
    disp('Importing Epochs...');
    epochs = importEpochs(group, parameters, data);
    
    exp = group.getExperiment();
end
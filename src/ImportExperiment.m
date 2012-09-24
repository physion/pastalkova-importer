function [exp, epochs] = ImportExperiment(dsc, parameters, data)
   % Import Pastalkova Lab Experiment
   %
   %
   %   experiment = ImportExperiment(dataStoreCoordinator, parameters, behavioralData)
   %
   %     dataStoreCoordinator: authenticated DataStoreCoordinator for the
   %     database. Use the DataContext getAuthenticatedDataStoreCoordinator() 
   %     method to retrieve the authenticated DataStoreCoordinator from an
   %     authenticated DataContext.
   %
   %     parameters: parameters structure via load()-ing a parameters .MAT
   %     file
   %
   %     behavioralData: structure via load()-ing a BehavElectrData.mat
   %     file
   
   % Copyright (c) 2012 Physion Consulting LLC
    
    disp('Importing Ovation structure...');
    [~, group] = importParameters(dsc, parameters, data.xml);
    
    disp('Importing Epochs...');
    epochs = importEpochs(group, parameters, data);
    
    exp = group.getExperiment();
end
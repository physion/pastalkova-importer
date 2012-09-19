function [exp, epochs] = ImportExperiment(dsc, parameters, data)
   % Import Pastalkova Lab Experiment
   %
   %   experiment = ImportExperiment(dataStoreCoordinator, parameters, behavioralData)
   
   % Copyright (c) 2012 Physion Consulting LLC
    
    disp('Importing Ovation structure...');
    [~, group] = importParameters(dsc, parameters, data.xml);
    
    disp('Importing Epochs...');
    epochs = importEpochs(group, parameters, data);
    
    exp = group.getExperiment();
end
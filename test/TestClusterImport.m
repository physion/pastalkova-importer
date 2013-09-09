% Copyright (c) 2012 Physion Consulting LLC


classdef TestClusterImport < MatlabTestCase
    
    properties
        paramsPath;
        behavPath;
    end
    
    methods
        
        function self = TestClusterImport(name)
             self = self@MatlabTestCase(name);
             
             self.paramsPath = 'fixtures/A543-20120422-01-param.mat';
             self.behavPath = 'fixtures/A543-20120422-01_BehavElectrData.mat';
        end 
        
        function [epoch,data,params,desc] = importSingleEpoch(self)
            data = load(self.behavPath);
            params = load(self.paramsPath);
            d = splitEpochs(data.Laps);
            
            [~,grp] = importParameters(self.dsc, params, data.xml);
            
            ind = 2;
            epoch = importEpoch(grp, params, data, d(ind));
            desc = d(ind);
        end
        
        function testShouldSaveClusterDerivedResponses(self)
            import ovation.*;
            [epoch, data, ~, desc] = self.importSingleEpoch();
            
            assertTrue(false, 'TODO');
        end
        
    end
end
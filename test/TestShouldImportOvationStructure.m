% Copyright (c) 2012 Physion Consulting LLC

classdef TestShouldImportOvationStructure < TestMatlabSuite
   
    properties
        paramsPath;
    end
    
    methods
       
        function self = TestShouldImportOvationStructure(name)
             self = self@TestMatlabSuite(name);
             
             self.paramsPath = 'fixtures/params.mat';
        end 
        
        
        function testShouldImportOvationProject(self)
            
            params = load(self.paramsPath);
            
            ctx = self.dsc.getContext();
            
            [proj,grp] = importParameters(ctx, params);
            
            assertEqual(char(proj.getName()), params.project.name);
        end
        
        function testShouldImportOvationExperiment(self)
            params = load(self.paramsPath);
            
            ctx = self.dsc.getContext();
            
            [~,grp] = importParameters(ctx, params);
            
            assertEqual(char(grp.getExperiment().getPurpose),...
                params.experiment.purpose);
            
        end
        
        function testShouldImportOvaitonEpochGroup(self)
            params = load(self.paramsPath);
            
            ctx = self.dsc.getContext();
            
            [proj,grp] = importParameters(ctx, params);
            
            assertTrue(grp.getExperiment().getProjects().contains(proj));
            assertEqual(grp.getLabel(), params.group.label);
        end
    end
end
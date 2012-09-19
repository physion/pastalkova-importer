% Copyright (c) 2012 Physion Consulting LLC

classdef TestOvationStructureImport < TestMatlabSuite
   
    properties
        paramsPath;
        behavPath;
    end
    
    methods
       
        function self = TestShouldImportOvationStructure(name)
             self = self@TestMatlabSuite(name);
             
             self.paramsPath = 'fixtures/A543-20120422-01-param.mat';
             self.behavPath = 'fixtures/A543-20120422-01_BehavElectrData.mat';
        end 
        
        
        function testShouldImportOvationProject(self)
            
            params = load(self.paramsPath);
            xml.FileName = 'foo';
            
            [proj,~] = importParameters(self.dsc, params, xml);
            
            assertEqual(char(proj.getName()), params.project.name);
        end
        
        function testShouldImportChannelDevices(self)
            params = load(self.paramsPath);
            behav = load(self.behavPath);
            xml = behav.xml;
            
            [~,grp] = importParameters(self.dsc, params, xml);
            
            for i = 1:xml.nChannels
                dev = grp.getExperiment().getExternalDevice(['channel' num2str(i)], 'Neuronexus');
                assert(~isempty(dev));
                assert(~isempty(dev.getOwnerProperty('shank').getOwnerProperty('probe')));
            end
        end
        
        function testShouldImportOvationExperiment(self)
            params = load(self.paramsPath);
            behav = load(self.behavPath);
            xml = behav.xml;
            
            [~,grp] = importParameters(self.dsc, params, xml);
            
            assertJavaEqual(parseDateTime(params.experiment.startDate, params.experiment.timezone),...
                grp.getExperiment().getStartTime());
            assertEqual(char(grp.getExperiment().getPurpose()),...
                char(params.experiment.purpose{1}));
            
            exp = grp.getExperiment();
            assertEqual(exp.getOwnerProperty('nChTotal'),...
                params.experiment.nChTotal);
            assertEqual(exp.getOwnerProperty('nProbes'),...
                params.experiment.nProbes);
            assertEqual(exp.getOwnerProperty('nHeadstages'),...
                params.experiment.nHeadstages);
            
            assertEqual(exp.getOwnerProperty('originalFile'),...
                xml.FileName);
        end
        
        function testShouldImportOvaitonEpochGroup(self)
            params = load(self.paramsPath);
            xml.FileName = 'foo';
            
            [proj,grp] = importParameters(self.dsc, params, xml);
            
            projs = grp.getExperiment().getProjects();
            assertJavaEqual(projs(1), proj);
            
            assertJavaEqual(grp.getLabel(),...
                params.epochGroup.description);
            
            assertEqual(grp.getOwnerProperty('restrictionLengthHrs'),...
                params.epochGroup.restrictionLengthHrs);
            assertEqual(grp.getOwnerProperty('animalWeight'), ...
                params.epochGroup.animWeight); %TODO units?
            assertEqual(grp.getOwnerProperty('blockID'),...
                params.epochGroup.blockID);
            
            notes = grp.getNoteAnnotations('experiment-notes');
            assertEqual(1, length(notes));
            assertJavaEqual(notes(1).getText(),...
                params.epochGroup.notes);
        end
        
        function testShouldImportRootOvationSource(self)
            
            params = load(self.paramsPath);
            xml.FileName = 'foo';
            importParameters(self.dsc, params, xml);
            
            ctx = self.dsc.getContext();
            
            sources = ctx.getSources(params.source.ID);
            assertEqual(1, length(sources));
            
            src = sources(1);
            
            assertJavaEqual(...
                src.getLabel(),...
                params.source.ID);
            
            assertEqual(src.getOwnerProperty('specie'),...
                params.source.specie);
            assertEqual(...
                src.getOwnerProperty('strain'),...
                params.source.strain);
            assertEqual(...
                src.getOwnerProperty('sex'),...
                params.source.sex);
            assertEqual(...
                src.getOwnerProperty('lightCycle'),...
                params.source.lightCyc);
            assertEqual(...
                src.getOwnerProperty('ID'),...
                params.source.ID);
            
        end
        
        function testShouldImportSourceHierarchy(self)
            params = load(self.paramsPath);
            xml.FileName = 'foo';
            
            importParameters(self.dsc, params, xml);
            
            ctx = self.dsc.getContext();
            
            sources = ctx.getSources('brain');
            assertEqual(1, length(sources));
            brainSource = sources(1);
            
            assertJavaEqual(...
                brainSource.getParent().getLabel(),...
                params.source.ID);
            
            for i = 1:length(params.epochGroup.brainAreaLayer)
                label = params.epochGroup.brainAreaLayer{i};
                expectedCount = sum(ismember(params.epochGroup.brainAreaLayer, label));
                
                assertEqual(expectedCount, length(brainSource.getChildren(label)));
            end
        end
    end
end
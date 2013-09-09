% Copyright (c) 2012 Physion Consulting LLC

classdef TestOvationStructureImport < MatlabTestCase
    
    properties
        paramsPath;
        behavPath;
    end
    
    methods
        
        function self = TestOvationStructureImport(name)
            self = self@MatlabTestCase(name);
            
            self.paramsPath = 'fixtures/A543-20120422-01-param.mat';
            self.behavPath = 'fixtures/A543-20120422-01_BehavElectrData.mat';
        end
        
        
        function testShouldImportOvationProject(self)
            
            params = load(self.paramsPath);
            data = load(self.behavPath);
            xml = data.xml;
            
            [proj,~] = importParameters(self.context, params, xml);
            
            assertEqual(char(proj.getName()), params.project.name);
        end
        
        
        function testShouldImportOvationExperiment(self)
            params = load(self.paramsPath);
            behav = load(self.behavPath);
            xml = behav.xml;
            
            [~,grp] = importParameters(self.context, params, xml);
            
            assertJavaEqual(parseDateTime(params.experiment.startDate, params.experiment.timezone),...
                grp.getExperiment().getStartTime());
            assertEqual(char(grp.getExperiment().getPurpose()),...
                char(params.experiment.purpose{1}));
            
            exp = grp.getExperiment();
            assertEqual(exp.getProperty(exp.getOwner(), 'nChTotal'),...
                params.experiment.nChTotal);
            assertEqual(exp.getProperty(exp.getOwner(), 'nProbes'),...
                params.experiment.nProbes);
            assertEqual(exp.getProperty(exp.getOwner(), 'nHeadstages'),...
                params.experiment.nHeadstages);
            
            assertEqual(exp.getOwnerProperty('originalFile'),...
                xml.FileName);
        end
        
        function testShouldImportOvaitonEpochGroup(self)
            params = load(self.paramsPath);
            data = load(self.behavPath);
            xml = data.xml;
            
            [proj,grp] = importParameters(self.context, params, xml);
            
            projs = grp.getExperiment().getProjects();
            assertJavaEqual(projs(1), proj);
            
            assertJavaEqual(grp.getLabel(),...
                params.epochGroup.description);
            
            assertEqual(grp.getProtocolParameter('restrictionLengthHrs'),...
                params.epochGroup.restrictionLengthHrs);
            assertEqual(grp.getProtocolParameter('animalWeight'), ...
                params.epochGroup.animWeight); %TODO units?
            assertEqual(grp.getProtocolParameter('blockID'),...
                params.epochGroup.blockID);
            
            notes = grp.getNoteAnnotations('experiment-notes');
            assertEqual(1, length(notes));
            assertJavaEqual(notes(1).getText(),...
                params.epochGroup.notes);
        end
        
        function testShouldImportRootOvationSource(self)
            import ovation.*;
            
            params = load(self.paramsPath);
            data = load(self.behavPath);
            xml = data.xml;
            importParameters(self.context, params, xml);
            
            ctx = self.context;
            
            sources = asarray(ctx.getSources(params.source.ID, params.source.ID));
            assertEqual(1, length(sources));
            
            src = sources(1);
            
            
            assertEqual(src.getProperty(src.getOwner(), 'specie'),...
                params.source.specie);
            assertEqual(...
                src.getProperty(src.getOwner(), 'strain'),...
                params.source.strain);
            assertEqual(...
                src.getProperty(src.getOwner(), 'sex'),...
                params.source.sex);
            assertEqual(...
                src.getProperty(src.getOwner(), 'lightCycle'),...
                params.source.lightCyc);
        end
        
        function testShouldImportSourceHierarchy(self)
            import ovation.*;
            
            params = load(self.paramsPath);
            data = load(self.behavPath);
            xml = data.xml;
            
            ctx = self.context;
            
            importParameters(ctx, params, xml);
            
            sources = asarray(ctx.getSourcesWithLabel('brain'));
            assertEqual(1, length(sources));
            brainSource = sources(1);
            
            parents = asarray(brainSource.getParentSources());
            found = false;
            for i = 1:length(parents)
                if(parents(i).getLabel().equals(params.source.ID))
                    found = true;
                    break;
                end
            end
            assertTrue(found);
            
            for i = 1:length(params.epochGroup.brainAreaLayer)
                label = params.epochGroup.brainAreaLayer{i};
                expectedCount = sum(ismember(params.epochGroup.brainAreaLayer, label));
                
                actual = 0;
                children = asarray(brainSource.getChildrenSources());
                for j = 1:length(children)
                    if(children(j).getLabel().equals(label))
                        actual = actual + 1;
                    end
                end
                
                assertEqual(expectedCount, actual);
            end
        end
    end
end
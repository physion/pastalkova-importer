% Copyright (c) 2012 Physion Consulting LLC


classdef TestSpikeImport < MatlabTestCase
    
    properties
        paramsPath;
        behavPath;
    end
    
    methods
        
        function self = TestSpikeImport(name)
            self = self@MatlabTestCase(name);
            
            self.paramsPath = 'fixtures/A543-20120422-01-param.mat';
            self.behavPath = 'fixtures/A543-20120422-01_BehavElectrData.mat';
        end
        
        function [epoch,data,params,desc] = importSingleEpoch(self)
            data = load(self.behavPath);
            params = load(self.paramsPath);
            d = splitEpochs(data.Laps);
            
            project = self.context.insertProject('TestEpochImport',...
                'TestEpochImport',...
                datetime());
            
            [~,grp] = importParameters(self.context, project, params, data.xml);
            
            ind = 2;
            epoch = importEpoch(grp, params, data, d(ind));
            desc = d(ind);
        end
        
        function d = analysisRecordData(~, arMap, name)
            d = nm2data(arMap.get(name).getOutputs().get(name));
        end
    
        function testShouldSaveSpikeTimeDerivedResponses(self)
            import ovation.*;
            [epoch, data, ~, desc] = self.importSingleEpoch();
            
            expectedSpikesLFP = data.Spike.res(desc.lfpStartIndex <= data.Spike.res & ...
                data.Spike.res <= desc.lfpEndIndex);
            
            expectedSpikeCount = numel(expectedSpikesLFP);
            
            ar = namedMap(epoch.getAnalysisRecords(epoch.getOwner()));
            
            r = self.analysisRecordData(ar, 'spike-index-lfp');
            assertEqual(expectedSpikeCount, numel(r));
            
            r = self.analysisRecordData(ar, 'spike-index-20kHz');
            assertEqual(expectedSpikeCount, numel(r));
        end
        
        function testShouldSaveSpikeRelatedDerivedResponses(self)
            [epoch, data, ~, desc] = self.importSingleEpoch();
            
            expectedSpikesLFP = data.Spike.res(desc.lfpStartIndex <= data.Spike.res & ...
                data.Spike.res <= desc.lfpEndIndex);
            
            expectedSpikeCount = numel(expectedSpikesLFP);
            
            ar = namedMap(epoch.getAnalysisRecords(epoch.getOwner()));
            
            r = self.analysisRecordData(ar, 'spike-clu');
            assertEqual(expectedSpikeCount, numel(r));
            
            r = self.analysisRecordData(ar, 'spike-shank');
            assertEqual(expectedSpikeCount, numel(r));
            
            r = self.analysisRecordData(ar, 'spike-totClu');
            assertEqual(expectedSpikeCount, numel(r));
            
            r = self.analysisRecordData(ar, 'spike-IDBurst');
            assertEqual(expectedSpikeCount, numel(r));
            
            r = self.analysisRecordData(ar, 'spike-burstLength');
            assertEqual(expectedSpikeCount, numel(r));
            
            r = self.analysisRecordData(ar, 'spike-orderInBurst');
            assertEqual(expectedSpikeCount, numel(r));
            
        end
        
        function testShouldSaveSpikeRelatedPhaseDerivedResponses(self)
            [epoch, data, ~, desc] = self.importSingleEpoch();
            
            expectedSpikeCount = numel(...
                data.Spike.thPhaseHilb(desc.lfpStartIndex <= data.Spike.res(1:length(data.Spike.thPhaseHilb)) & ...
                data.Spike.res(1:length(data.Spike.thPhaseHilb)) <= desc.lfpEndIndex)...
                );
            
            assert(false, 'Don''t know how thPhase transform truncates indexes');
            
            ar = namedMap(epoch.getAnalysisRecords(epoch.getOwner()));
            
            r = self.analysisRecordData(ar, 'spike-thPhaseHilb');
            assertEqual(expectedSpikeCount, numel(r));
            
            r = self.analysisRecordData(ar, 'spike-thPhaseInterp');
            assertEqual(expectedSpikeCount, numel(r));
        end
    end
end
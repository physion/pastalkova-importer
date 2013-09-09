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
            
            [~,grp] = importParameters(self.context, params, data.xml);
            
            ind = 2;
            epoch = importEpoch(grp, params, data, d(ind));
            desc = d(ind);
        end
        
        function testShouldSaveSpikeTimeDerivedResponses(self)
           
            [epoch, data, ~, desc] = self.importSingleEpoch();
            
            expectedSpikesLFP = data.Spike.res(desc.lfpStartIndex <= data.Spike.res & ...
                data.Spike.res <= desc.lfpEndIndex);
            
            expectedSpikeCount = numel(expectedSpikesLFP);
            
            r = epoch.getMyDerivedResponse('spike-index-lfp');
            assertEqual(expectedSpikeCount, length(r.getFloatingPointData()));
            
            r = epoch.getMyDerivedResponse('spike-index-20kHz');
            assertEqual(expectedSpikeCount, length(r.getFloatingPointData()));
        end
        
        function testShouldSaveSpikeRelatedDerivedResponses(self)
            [epoch, data, ~, desc] = self.importSingleEpoch();
            
            expectedSpikesLFP = data.Spike.res(desc.lfpStartIndex <= data.Spike.res & ...
                data.Spike.res <= desc.lfpEndIndex);
            
            expectedSpikeCount = numel(expectedSpikesLFP);
            
            r = epoch.getMyDerivedResponse('spike-clu');
            assertEqual(expectedSpikeCount, length(r.getFloatingPointData()));
            
            r = epoch.getMyDerivedResponse('spike-shank');
            assertEqual(expectedSpikeCount, length(r.getFloatingPointData()));
            
            r = epoch.getMyDerivedResponse('spike-totClu');
            assertEqual(expectedSpikeCount, length(r.getFloatingPointData()));
            
            r = epoch.getMyDerivedResponse('spike-IDBurst');
            assertEqual(expectedSpikeCount, length(r.getFloatingPointData()));
            
            r = epoch.getMyDerivedResponse('spike-burstLength');
            assertEqual(expectedSpikeCount, length(r.getFloatingPointData()));
            
            r = epoch.getMyDerivedResponse('spike-orderInBurst');
            assertEqual(expectedSpikeCount, length(r.getFloatingPointData()));
            
            
        end
        
        function testShouldSaveSpikeRelatedPhaseDerivedResponses(self)
            [epoch, data, ~, desc] = self.importSingleEpoch();
            
            expectedSpikeCount = numel(...
                data.Spike.thPhaseHilb(desc.lfpStartIndex <= data.Spike.res(1:length(data.Spike.thPhaseHilb)) & ...
                data.Spike.res(1:length(data.Spike.thPhaseHilb)) <= desc.lfpEndIndex)...
                );
            
            assert(false, 'Don''t know how thPhase transform truncates indexes');
            
            r = epoch.getMyDerivedResponse('spike-thPhaseHilb');
            assertEqual(expectedSpikeCount, length(r.getFloatingPointData()));
            
            r = epoch.getMyDerivedResponse('spike-thPhaseInterp');
            assertEqual(expectedSpikeCount, length(r.getFloatingPointData()));
        end
    end
end
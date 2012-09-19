% Copyright (c) 2012 Physion Consulting LLC

classdef TestEpochImport < TestMatlabSuite
    
    properties
        paramsPath;
        behavPath;
    end
    
    methods
        
        function self = TestEpochImport(name)
             self = self@TestMatlabSuite(name);
             
             self.paramsPath = 'fixtures/A543-20120422-01-param.mat';
             self.behavPath = 'fixtures/A543-20120422-01_BehavElectrData.mat';
        end 
        
        function testShouldImportOneEpochPerLapID(self)
           
            data = load(self.behavPath);
            params = load(self.paramsPath);
            
            [~,grp] = importParameters(self.dsc, params, data.xml);
            
            epochs = importEpochs(grp, params, data);
            
            assertEqual(length(unique(data.Laps.lapID)),...
                length(epochs));
            
            for i = 1:length(epochs)
                assertEqual(['org.hhmi.pastalkova.' char(grp.getLabel())],...
                    char(epochs(i).getProtocolID()));
            end
        end
        
        function testShouldImportEpochProtocolID(self)
            data = load(self.behavPath);
            params = load(self.paramsPath);
            d = splitEpochs(data.Laps);
            
            [~,grp] = importParameters(self.dsc, params, data.xml);
            
            epoch = importEpoch(grp, params, data, d(2));
            
            assertEqual(['org.hhmi.pastalkova.' char(grp.getLabel())],...
                    char(epoch.getProtocolID()));
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
        
        function testShouldImportProtocolParametersFromProtocol(self)
            
            [epoch, ~, params, ~] = self.importSingleEpoch();
            
            protocolParams = ovation.map2struct(...
                ovation.struct2map(params.epochGroup.protocol));
            
            actual = ovation.map2struct(epoch.getProtocolParameters());
            
            fnames = fieldnames(protocolParams);
            for i = 1:length(fnames)
                fname = fnames{i};
                
                assertEqual(protocolParams.(fname),...
                    actual.(fname));
            end
        end
        
        function testShouldAddLFPResponse(self)
            [epoch, data, ~, desc] = self.importSingleEpoch();
            
            r = epoch.getResponse('Recording System');
            
            assert(~isempty(r));
            
            assertElementsAlmostEqual(r.getFloatingPointData(),...
                data.Track.eeg(desc.lfpStartIndex:desc.lfpEndIndex));
            
            assertEqual(char(r.getUnits()),...
                'mV');
            
            rates = r.getSamplingRates();
            assertEqual(data.xml.lfpSampleRate,...
                rates(1));
            
            assertEqual('Hz', char(r.getSamplingUnits()));
        end
        
        function testShouldAddTrackXResponse(self)
            [epoch, data, ~, desc] = self.importSingleEpoch();
            
            r = epoch.getResponse('Tracking xPix');
            
            assert(~isempty(r));
            
            assertElementsAlmostEqual(r.getFloatingPointData(),...
                data.Track.xPix(desc.lfpStartIndex:desc.lfpEndIndex));
            
            assertEqual(char(r.getUnits()),...
                'pixel');
            
            rates = r.getSamplingRates();
            assertEqual(data.xml.lfpSampleRate,...
                rates(1));
            
            assertEqual('Hz', char(r.getSamplingUnits()));
        end
        
        function testShouldAddTrackYResponse(self)
            [epoch, data, ~, desc] = self.importSingleEpoch();
            
            r = epoch.getResponse('Tracking yPix');
            
            assert(~isempty(r));
            
            assertElementsAlmostEqual(r.getFloatingPointData(),...
                data.Track.yPix(desc.lfpStartIndex:desc.lfpEndIndex));
            
            assertEqual(char(r.getUnits()),...
                'pixel');
            
            rates = r.getSamplingRates();
            assertEqual(data.xml.lfpSampleRate,...
                rates(1));
            
            assertEqual('Hz', char(r.getSamplingUnits()));
        end
        
        function testShouldAddDirectionChoiceResponse(self)
            [epoch, data, ~, desc] = self.importSingleEpoch();
            
            r = epoch.getResponse('Direction Choice');
            
            assert(~isempty(r));
            
            assertElementsAlmostEqual(r.getFloatingPointData(),...
                data.Laps.dirChoice(desc.trialNumber));
            
            assertEqual(char(r.getUnits()),...
                'n/a');
            
            rates = r.getSamplingRates();
            assertEqual(1,...
                rates(1));
            
            assertEqual('1/trial', char(r.getSamplingUnits()));
        end
        
        function testShouldTagCorrectChoiceTrials(self)
            import ovation.*;
            
            data = load(self.behavPath);
            params = load(self.paramsPath);
            
            [~,grp] = importParameters(self.dsc, params, data.xml);
            
            epochs = importEpochs(grp, params, data);
            
            assertEqual(length(unique(data.Laps.lapID)),...
                length(epochs));
            
            for i = 1:length(epochs)
                taggedCorrect = epochs(i).getTagSet().contains(KeywordTag.keywordTagWithTag('correct'));
                assert(taggedCorrect == data.Laps.corrChoice(i), [num2str(i) ': ' num2str(taggedCorrect) ' ' num2str(data.Laps.corrChoice(i))]);
            end
        end
        
        function testShouldSetWhilDirChoiceAsProtocolParameter(self)
            data = load(self.behavPath);
            params = load(self.paramsPath);
            
            [~,grp] = importParameters(self.dsc, params, data.xml);
            
            epochs = importEpochs(grp, params, data);
            
            assertEqual(length(unique(data.Laps.lapID)),...
                length(epochs));
            
            for i = 1:length(epochs)
                assert(data.Laps.whlDirChoice(i) == epochs(i).getProtocolParameter('wheelDirectionChoice'));
            end
        end
    end
end
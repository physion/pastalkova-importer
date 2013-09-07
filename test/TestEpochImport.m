% Copyright (c) 2012 Physion Consulting LLC

classdef TestEpochImport < MatlabTestCase
    
    properties
        paramsPath;
        behavPath;
    end
    
    methods
        
        function self = TestEpochImport(name)
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
            
            startIndex = floor(desc.lfpStartIndex * data.xml.SampleRate / data.xml.lfpSampleRate);
            endIndex = floor(desc.lfpEndIndex * data.xml.SampleRate / data.xml.lfpSampleRate);
            assertElementsAlmostEqual(r.getFloatingPointData(),...
                data.Track.eegRaw(startIndex:endIndex));
            
            assertEqual(char(r.getUnits()),...
                'unknown');
            
            rates = r.getSamplingRates();
            assertEqual(data.xml.SampleRate,...
                rates(1));
            
            assertEqual('Hz', char(r.getSamplingUnits()));
        end
        
        function testShouldAddDownsampledLFPDerivedResponse(self)
            [epoch, data, ~, desc] = self.importSingleEpoch();
            
            r = epoch.getMyDerivedResponse('eeg');
            
            assert(~isempty(r));
            
            assertElementsAlmostEqual(r.getFloatingPointData(),...
                data.Track.eeg(desc.lfpStartIndex:desc.lfpEndIndex));
        end
        
        function testShouldAddTrackXResponse(self)
            [epoch, data, ~, desc] = self.importSingleEpoch();
            
            r = epoch.getResponse('Tracking xPix');
            
            assert(~isempty(r));
            
            assertElementsAlmostEqual(r.getFloatingPointData(),...
                data.Track.xPix(desc.lfpStartIndex:desc.lfpEndIndex));
            
            assertEqual(char(r.getUnits()),...
                'pixels');
            
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
                'pixels');
            
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
                epochs(i).getTagSet().contains(KeywordTag.keywordTagWithTag('correct'));
                taggedCorrect = epochs(i).getTagSet().contains(KeywordTag.keywordTagWithTag('correct'));
                
                assert(taggedCorrect == data.Laps.corrChoice(i));
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
        
        function testShouldHaveExpectedDerivedResposnes(self)
            [epoch, ~, ~, ~] = self.importSingleEpoch();
            drNames = epoch.getDerivedResponseNames();
            
            expectedNames = { 'WhlDistCW',...
                'WhlLapsDistCW',...
                'WhlSpeedCW',...
                'WhlDistCCW',...
                'WhlLapsDistCCW',...
                'WhlSpeedCCW',...
                'xMM',...
                'yMM',...
                'mazeSect',...
                'speed_MMsec',...
                'accel_MMsecSq',...
                'headDirDeg',...
                'realDistMM',...
                'linXMM',...
                'linYMM',...
                'linXPix',...
                'linYPix',...
                'linDistMM',...
                'thetaPhHilb',...
                'thetaPhLinInterp'};
            
            for i = 1:length(expectedNames)
                expectedName = expectedNames{i};
                
                found = false;
                for j = 1:length(drNames)
                    if(drNames(j).equals([expectedName])) %TODO: add date?
                        found = true;
                        break;
                    end
                end
                assert(found, expectedName);
            end
        end
        
        function testShouldImportSpikeLfpTimeSeconds(self)
            [epoch, data, ~, ~] = self.importSingleEpoch();
            
            lfpIndex = epoch.getMyDerivedResponse('spike-index-lfp').getFloatingPointData();
            lfpTime = epoch.getMyDerivedResponse('spike-lfp-time-seconds').getFloatingPointData();
            
            
            assertElementsAlmostEqual(lfpTime, lfpIndex / data.xml.lfpSampleRate);
        end
        
        
        function testShouldImportSpikeRawTimeSeconds(self)
            [epoch, data, ~, ~] = self.importSingleEpoch();
            
            rawIndex = epoch.getMyDerivedResponse('spike-index-20kHz').getFloatingPointData();
            rawTime = epoch.getMyDerivedResponse('spike-time-seconds').getFloatingPointData();
            
            
            assertElementsAlmostEqual(rawTime, rawIndex / data.xml.SampleRate);
        end
        
        function testShouldIndexLfpSpikesFromEpochStart(self)
            [epoch, data, ~, desc] = self.importSingleEpoch();
            
            % Find spikes in this Epoch
            spikeIdx = desc.lfpStartIndex <= data.Spike.res & data.Spike.res <= desc.lfpEndIndex;
    
            expected = data.Spike.res(spikeIdx) - desc.lfpStartIndex;
            
            assertElementsAlmostEqual(epoch.getMyDerivedResponse('spike-index-lfp').getFloatingPointData(),...
                expected);
        end
        
        function testShouldIndexRawSpikesFromEpochStart(self)
            [epoch, data, ~, desc] = self.importSingleEpoch();
            
            % Find spikes in this Epoch
            spikeIdx = desc.lfpStartIndex <= data.Spike.res & data.Spike.res <= desc.lfpEndIndex;
    
            % lfpIndex * rawSamples/sec * sec/lfpSamples = rawSamples
            rawStartIndex = floor(desc.lfpStartIndex * data.xml.SampleRate / data.xml.lfpSampleRate);
            
            % Raw spike indexes in this Epoch, 0-offet at Epoch start
            expected = data.Spike.res20kHz(spikeIdx) - rawStartIndex;
            
            assertElementsAlmostEqual(epoch.getMyDerivedResponse('spike-index-20kHz').getFloatingPointData(),...
                expected);
        end
    end
end
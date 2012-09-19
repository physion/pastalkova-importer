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
        
        function [epoch,data,params] = importSingleEpoch(self)
            data = load(self.behavPath);
            params = load(self.paramsPath);
            d = splitEpochs(data.Laps);
            
            [~,grp] = importParameters(self.dsc, params, data.xml);
            
            epoch = importEpoch(grp, params, data, d(2));
        end
        
        function testShouldImportProtocolParametersFromProtocol(self)
            
            [epoch, ~, params] = self.importSingleEpoch();
            
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
            [epoch, data, ~] = self.importSingleEpoch();
            
            r = epoch.getResponse('Recording System');
            
            assert(~isempty(r));
            
            assertElementsAlmostEqual(r.getFloatingPointData(),...
                data.Track.eeg);
            
            assertEqual(char(r.getUnits()),...
                'mV');
            
            rates = r.getSamplingRates();
            assertEqual(data.xml.lfpSampleRate,...
                rates(1));
            
            assertEqual('Hz', char(r.getSamplingUnits()));
        end
    end
end
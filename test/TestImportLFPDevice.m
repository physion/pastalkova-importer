% Copyright (c) 2012 Physion Consulting LLC

classdef TestImportLFPDevice < TestMatlabSuite
    
    properties
        paramsPath;
        behavPath;
    end
    
    methods
        
        function self = TestImportLFPDevice(name)
             self = self@TestMatlabSuite(name);
             
             self.paramsPath = 'fixtures/A543-20120422-01-param.mat';
             self.behavPath = 'fixtures/A543-20120422-01_BehavElectrData.mat';
        end 
        
        function testShouldImportProbeDeviceFromParameters(self)
            params = load(self.paramsPath);
            data = load(self.behavPath);
            xml = data.xml;
            
            [~,grp] = importParameters(self.dsc, params, xml);
            
            exp = grp.getExperiment();
            
            for i = 1:length(params.device.probe)
                dev = exp.externalDevice(['probe' num2str(i)], params.device.probe(i).manufacturer);
                props = ovation.map2struct(dev.getOwnerProperties());
                
                expected = ovation.map2struct(...
                    ovation.struct2map(params.device.probe(i)));
                
                fnames = fieldnames(params.device.probe);
                for j = 1:length(fnames)
                    fname = fnames{j};
                    
                    assertEqual(props.(fname),...
                        expected.(fname));
                end
            end
        end
        
        function testShouldImportHeadstageDeviceFromParameters(self)
            params = load(self.paramsPath);
            data = load(self.behavPath);
            xml = data.xml;
            
            [~,grp] = importParameters(self.dsc, params, xml);
            
            exp = grp.getExperiment();
            
            for i = 1:length(params.device.headstage)
                dev = exp.externalDevice(['headstage' num2str(i)],params.device.headstage(i).manufacturer);
                props = ovation.map2struct(dev.getOwnerProperties());
                
                
                expected = ovation.map2struct(...
                    ovation.struct2map(params.device.headstage(i)));
                
                fnames = fieldnames(params.device.headstage);
                for j = 1:length(fnames)
                    fname = fnames{j};
                    
                    assertEqual(props.(fname),...
                        expected.(fname));
                end
            end
        end
        
        function testShouldLinkProbeToHeadstage(self)
            params = load(self.paramsPath);
            data = load(self.behavPath);
            xml = data.xml;
            
            [~,grp] = importParameters(self.dsc, params, xml);
            
            exp = grp.getExperiment();
            
            for i = 1:length(params.device.probe)
                dev = exp.externalDevice(['probe' num2str(i)], params.device.probe(i).manufacturer);
                
                headstage = dev.getOwnerProperty('headstage');
                
                assertTrue(~isempty(headstage));
            end
        end
        
        function testShouldImportRecordingSystem(self)
            params = load(self.paramsPath);
            data = load(self.behavPath);
            xml = data.xml;
            
            [~,grp] = importParameters(self.dsc, params, xml);
            
            exp = grp.getExperiment();
            
            dev = exp.externalDevice('Recording System',...
                params.device.RecSyst.manufacturer);
            
            props = ovation.map2struct(dev.getOwnerProperties());
            
            
            expected = ovation.map2struct(...
                ovation.struct2map(params.device.RecSyst));
            
            fnames = fieldnames(params.device.RecSyst);
            for j = 1:length(fnames)
                fname = fnames{j};
                
                assertEqual(props.(fname),...
                    expected.(fname));
            end
        end
        
        
        function testShouldImportCableToRecordingSystem(self)
            params = load(self.paramsPath);
            data = load(self.behavPath);
            xml = data.xml;
            
            [~,grp] = importParameters(self.dsc, params, xml);
            
            exp = grp.getExperiment();
            
            dev = exp.externalDevice('Recording System',...
                params.device.RecSyst.manufacturer);
            
            props = ovation.map2struct(dev.getOwnerProperties());
            
            
            expected = ovation.map2struct(...
                ovation.struct2map(params.device.cable));
            
            fnames = fieldnames(params.device.RecSyst);
            for j = 1:length(fnames)
                fname = fnames{j};
                
                assertEqual(props.(['cable_' fname]),...
                    expected.(fname));
            end
        end
        
        function testShouldLinkHeadstageToRecordingSystem(self)
            params = load(self.paramsPath);
            data = load(self.behavPath);
            xml = data.xml;
            
            [~,grp] = importParameters(self.dsc, params, xml);
            
            exp = grp.getExperiment();
            
            for i = 1:length(params.device.headstage)
                dev = exp.externalDevice(['headstage' num2str(i)],params.device.headstage(i).manufacturer);
                
                recordingSystem = dev.getOwnerProperty('recording-system');
                assertTrue(~isempty(recordingSystem));
            end
        end
        
    end
end
% Copyright (c) 2012 Physion Consulting LLC

classdef TestImportArduinoDevice < MatlabTestCase
    
    properties
        paramsPath;
        behavPath;
    end
    
    methods
        
        function self = TestImportArduinoDevice(name)
             self = self@MatlabTestCase(name);
             
             self.paramsPath = 'fixtures/A543-20120422-01-param.mat';
             self.behavPath = 'fixtures/A543-20120422-01_BehavElectrData.mat';
        end 
        
        function assertTrackingDeviceFromParameters(self, name)
            params = load(self.paramsPath);
            data = load(self.behavPath);
            xml = data.xml;
            
            [~,grp] = importParameters(self.dsc, params, xml);
            
            exp = grp.getExperiment();
            
            dev = exp.externalDevice(name, 'Pastalkova'); %TODO manufacturer
            props = ovation.map2struct(dev.getOwnerProperties());
            
            expected = ovation.map2struct(...
                ovation.struct2map(params.device.tracking));
            
            fnames = fieldnames(params.device.probe);
            for j = 1:length(fnames)
                fname = fnames{j};
                
                assertEqual(props.(fname),...
                    expected.(fname));
            end
        end
        
        function testShouldImportArduinoDevice(self)
            params = load(self.paramsPath);
            data = load(self.behavPath);
            xml = data.xml;
            
            [~,grp] = importParameters(self.dsc, params, xml);
            
            exp = grp.getExperiment();
            
            % TODO: name, manufacturer and what parameters?
            dev = exp.getExternalDevice('Arduino', 'JFRC');
            props = ovation.map2struct(dev.getOwnerProperties());
            
            expected = ovation.map2struct(...
                ovation.struct2map(params.device.maze));
            
            fnames = fieldnames(params.device.maze);
            for j = 1:length(fnames)
                fname = fnames{j};
                
                assertEqual(props.(fname),...
                    expected.(fname));
            end
        end
        
        function testShouldTestAndLinkDirectionChoice(self)
            params = load(self.paramsPath);
            data = load(self.behavPath);
            xml = data.xml;
            
            [~,grp] = importParameters(self.dsc, params, xml);
            
            exp = grp.getExperiment();
            
            % TODO: name, manufacturer and what parameters?
            dev = exp.getExternalDevice('Direction Choice', 'JFRC');
            
            assert(~isempty(dev.getOwnerProperty('arduino')));
        end
        
    end
end
% Copyright (c) 2012 Physion Consulting LLC

classdef TestImportTrackingDevice < MatlabTestCase
    
    properties
        paramsPath;
        behavPath;
    end
    
    methods
        
        function self = TestImportTrackingDevice(name)
             self = self@MatlabTestCase(name);
             
             self.paramsPath = 'fixtures/A543-20120422-01-param.mat';
             self.behavPath = 'fixtures/A543-20120422-01_BehavElectrData.mat';
        end 
        
        function testShouldImportxPixDeviceFromParameters(self)
            self.testTrackingDeviceFromParameters('Tracking xPix');
        end
        
        function testShouldImportyPixDeviceFromParameters(self)
            self.testTrackingDeviceFromParameters('Tracking yPix');
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
        
        function testShouldImportCameraDevice(self)
            params = load(self.paramsPath);
            data = load(self.behavPath);
            xml = data.xml;
            
            [~,grp] = importParameters(self.dsc, params, xml);
            
            exp = grp.getExperiment();
            
            dev = exp.externalDevice('Camera', params.device.camera);
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
        
        function testShouldLinkTrackingxPixDeviceToCamera(self)
            self.assertTrackingDeviceToCamera('Tracking xPix');
        end
        
        function testShouldLinkTrackingyPixDeviceToCamera(self)
            self.assertTrackingDeviceToCamera('Tracking yPix');
        end        
        
        function assertTrackingDeviceToCamera(self, name)
            params = load(self.paramsPath);
            data = load(self.behavPath);
            xml = data.xml;
            
            [~,grp] = importParameters(self.dsc, params, xml);
            
            exp = grp.getExperiment();
            
            dev = exp.externalDevice(name, 'Pastalkova'); %TODO manufacturer
            
            assert(~isempty(dev.getOwnerProperty('camera')));
        end
    end
end
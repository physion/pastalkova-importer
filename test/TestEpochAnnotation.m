% Copyright (c) 2012 Physion Consulting LLC

classdef TestEpochAnnotation < MatlabTestCase
    
    properties
        paramsPath;
        behavPath;
    end
    
    methods
        
        function self = TestEpochAnnotation(name)
            self = self@MatlabTestCase(name);
            
            self.paramsPath = 'test/fixtures/A543-20120422-01-param.mat';
            self.behavPath = 'test/fixtures/A543-20120422-01_BehavElectrData.mat';
        end
        
        function [epoch,data,params,desc] = importSingleEpoch(self)
            import ovation.*;
            
            data = load(self.behavPath);
            params = load(self.paramsPath);
            d = splitEpochs(data.Laps);
            
            project = self.context.insertProject('TestEpochImport',...
                'TestEpochImport',...
                datetime());
            
            srcProtocol = self.context.insertProtocol('Source Protocol',...
                'Source derivation protocol mouse => brain area');
            
            expProtocol = self.context.insertProtocol('Experiment Protocol',...
                'Exp protocol');
            
            [~,grp] = importParameters(self.context,...
                project,...
                params,...
                data.xml,...
                expProtocol,...
                srcProtocol,...
                [],...
                []);
            
            ind = 4;
            epoch = importEpoch(grp, params, data, d(ind));
            desc = d(ind);
        end
        
        function checkWheelRunTimelineAnnotations(self, prefix, name)
            import ovation.*;
            [epoch, data, ~, desc] = self.importSingleEpoch();
            
            starts = data.Laps.WhlLfpIndStartCW{desc.trialNumber} - data.Laps.startLfpInd(desc.trialNumber);
            stops = data.Laps.WhlLfpIndEndCW{desc.trialNumber} - data.Laps.startLfpInd(desc.trialNumber);
            
            assert(all(size(starts) == size(stops)));
            
            timelineAnnotationsItr = epoch.getTimelineAnnotations(epoch.getOwner()).iterator();
            wruns = java.util.HashSet();
            while(timelineAnnotationsItr.hasNext())
                annotation = timelineAnnotationsItr.next();
                if(annotation.getName().startsWith(prefix))
                    wruns.add(annotation);
                end
            end
                    
            wheelRuns = asarray(wruns);
            assertEqual(numel(starts), length(wheelRuns));
            
            annotationMap = namedMap(epoch.getTimelineAnnotations(epoch.getOwner()));
            
            for i = 1:length(wheelRuns)
                annotation = annotationMap.get([prefix '-' num2str(i)]);
                
                assertEqual(name, char(annotation.getText()));
                assertEqual(starts(i), annotation.getOwnerProperty('lfpStartIndex'));
                assertEqual(stops(i), annotation.getOwnerProperty('lfpEndIndex'));
                
                expectedStart = epoch.getStartTime().plusMillis(1000 * starts(i) / data.xml.lfpSampleRate);
                expectedEnd = epoch.getStartTime().plusMillis(1000 * stops(i) / data.xml.lfpSampleRate);
                
                assertJavaEqual(expectedStart, annotation.getStartTime());
                assertJavaEqual(expectedEnd, annotation.getEndTime());
            end
            
            annotation = annotationMap.get([prefix '-' num2str(i)]);
            assert(java.util.HashSet(annotation.getAllTags()).contains(['last-' prefix]));
        end
        
        function testShouldAddWheelRunCWTimelineAnnotations(self)
            self.checkWheelRunTimelineAnnotations('wheel-run-cw', 'Wheel Run CW');
        end
        
        function testShouldAddWheelRunCCWTimelineAnnotations(self)
            self.checkWheelRunTimelineAnnotations('wheel-run-ccw', 'Wheel Run CCW');
        end
        
        function testShouldAnnotateThetaEvents(self)
            import ovation.*;
            
            [epoch, data, ~, ~] = self.importSingleEpoch();
            
            startSeconds = (epoch.getStartTime().getMillis() - epoch.getEpochGroup().getStartTime().getMillis) / 1000;
            endSeconds = (epoch.getEndTime().getMillis() - epoch.getEpochGroup().getStartTime().getMillis) / 1000;
            
            timelineAnnotations = namedMap(epoch.getTimelineAnnotations(epoch.getOwner()));
            analysisRecords = namedMap(epoch.getAnalysisRecords(epoch.getOwner()));
            
            indWithinEpoch = find(startSeconds <= data.Track.thetaPeak_tAmpl(:,1) & data.Track.thetaPeak_tAmpl(:,1) <= endSeconds);
            assertEqual(sum(indWithinEpoch), timelineAnnotations.get('thetaPeak').size());
            assertTrue(analysisRecords.containsKey('thetaPeakTime'));
            assertTrue(analysisRecords.containsKey('thetaPeakTime'));
            assertTrue(analysisRecords.containsKey('thetaPeakAmplitude'));
            
            indWithinEpoch = find(startSeconds <= data.Track.thetaTrough_tAmpl(:,1) & data.Track.thetaTrough_tAmpl(:,1) <= endSeconds);
            assertEqual(sum(indWithinEpoch), timelineAnnotations.get('thetaTrough').size());
            assertTrue(analysisRecords.containsKey('thetaTroughTime'));
            assertTrue(analysisRecords.containsKey('thetaTroughAmplitude'));
            
            indWithinEpoch = find(startSeconds <= data.Track.thetaPtoTZeros_tAmpl(:,1) & data.Track.thetaPtoTZeros_tAmpl(:,1) <= endSeconds);
            assertEqual(sum(indWithinEpoch), timelineAnnotations.get('thetaPtoTZeros').size());
            assertTrue(analysisRecords.containsKey('thetaPtoTZerosTime'));
            assertTrue(analysisRecords.containsKey('thetaPtoTZerosAmplitude'));
            
            indWithinEpoch = find(startSeconds <= data.Track.thetaTtoPZeros_tAmpl(:,1) & data.Track.thetaTtoPZeros_tAmpl(:,1) <= endSeconds);
            assertEqual(sum(indWithinEpoch), timelineAnnotations.get('thetaTtoPZeros').size());
            assertTrue(analysisRecords.containsKey('thetaTtoPZerosTime'));
            assertTrue(analysisRecords.containsKey('thetaTtoPZerosAmplitude'));
        end
        
        function testShoulAddSpwAnalysisRecords(self)
            import ovation.*;
            
            [epoch, ~, ~, ~] = self.importSingleEpoch();
            
            analysisRecords = namedMap(epoch.getAnalysisRecords(epoch.getOwner()));
            assertTrue(analysisRecords.containsKey('spw_peak'));
            assertTrue(analysisRecords.containsKey('spw_start'));
            assertTrue(analysisRecords.containsKey('spw_end'));
            assertTrue(analysisRecords.containsKey('spw_shpwPeakAmplSD'));
            assertTrue(analysisRecords.containsKey('spw_ripPeakAmplSD'));
        end
    end
end
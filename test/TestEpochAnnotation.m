% Copyright (c) 2012 Physion Consulting LLC

classdef TestEpochAnnotation < MatlabTestCase
    
    properties
        paramsPath;
        behavPath;
    end
    
    methods
        
        function self = TestEpochAnnotation(name)
            self = self@MatlabTestCase(name);
            
            self.paramsPath = 'fixtures/A543-20120422-01-param.mat';
            self.behavPath = 'fixtures/A543-20120422-01_BehavElectrData.mat';
        end
        
        function [epoch,data,params,desc] = importSingleEpoch(self)
            data = load(self.behavPath);
            params = load(self.paramsPath);
            d = splitEpochs(data.Laps);
            
            [~,grp] = importParameters(self.dsc, params, data.xml);
            
            ind = 4;
            epoch = importEpoch(grp, params, data, d(ind));
            desc = d(ind);
        end
        
        function testShouldAddWheelRunCWTimelineAnnotations(self)
            import ovation.*;
            [epoch, data, ~, desc] = self.importSingleEpoch();
            
            starts = data.Laps.WhlLfpIndStartCW{desc.trialNumber} - data.Laps.startLfpInd(desc.trialNumber);
            stops = data.Laps.WhlLfpIndEndCW{desc.trialNumber} - data.Laps.startLfpInd(desc.trialNumber);
            
            assert(all(size(starts) == size(stops)));
            
            wheelRuns = epoch.getTimelineAnnotations('wheel-runs-cw');
            assertEqual(numel(starts), length(wheelRuns));
            
            for i = 1:length(wheelRuns)
                annotations = epoch.getTimelineAnnotations(['wheel-run-cw-' num2str(i)]);
                assertEqual(1, length(annotations));
                annotation = annotations(1);
                
                assertEqual('Wheel Run CW', char(annotation.getText()));
                assertEqual(starts(i), annotation.getOwnerProperty('lfpStartIndex'));
                assertEqual(stops(i), annotation.getOwnerProperty('lfpEndIndex'));
                
                expectedStart = epoch.getStartTime().plusMillis(1000 * starts(i) / data.xml.lfpSampleRate);
                expectedEnd = epoch.getStartTime().plusMillis(1000 * stops(i) / data.xml.lfpSampleRate);
                
                assertJavaEqual(expectedStart, annotation.getStartTime());
                assertJavaEqual(expectedEnd, annotation.getEndTime());
            end
            
            annotations = epoch.getTimelineAnnotations(['wheel-run-cw-' num2str(i)]);
            assertEqual(1, length(annotations));
            annotation = annotations(1);
            assert(annotation.getTagSet().contains(KeywordTag.keywordTagWithTag('last-wheel-run-cw')));
        end
        
        function testShouldAddWheelRunCCWTimelineAnnotations(self)
            [epoch, data, ~, desc] = self.importSingleEpoch();
            
            starts = data.Laps.WhlLfpIndStartCCW{desc.trialNumber} - data.Laps.startLfpInd(desc.trialNumber);
            stops = data.Laps.WhlLfpIndEndCCW{desc.trialNumber} - data.Laps.endLfpInd(desc.trialNumber);
            
            assert(all(size(starts) == size(stops)));
            
            wheelRuns = epoch.getTimelineAnnotations('wheel-runs-ccw');
            assertEqual(numel(starts), length(wheelRuns));
            
            for i = 1:length(wheelRuns)
                annotations = epoch.getTimelineAnnotations(['wheel-run-ccw-' num2str(i)]);
                assertEqual(1, length(annotations));
                annotation = annotations(1);
                
                assertEqual('Wheel Run CCW', annotation.getText());
                assertEqual(starts(i), annotation.getOwnerProperty('lfpStartIndex'));
                assertEquals(stops(i), annotation.getOwnerProperty('lfpEndIndex'));
                
                expectedStart = epoch.getStartTime().plusMillis(1000 * starts(i) / data.xml.lfpSampleRate);
                expectedEnd = epoch.getStartTime().plusMillis(1000 * stops(i) / data.xml.lfpSampleRate);
                
                assertJavaEqual(expectedStart, annotation.getStartTime());
                assertJavaEqual(expectedEnd, annotation.getEndTime());
            end
            
            annotations = epoch.getTimelineAnnotations(['wheel-run-ccw-' num2str(length(wheelRuns))]);
            assert(length(annotations) <= 1);
            if(~isempty(annotations))
                annotation = annotations(1);
                assert(annotation.getTagSet().contains(KeywordTag.keywordTagWithTag('last-wheel-run-ccw')));
            end
        end
        
        function testShouldAnnotateThetaEvents(self)
            [epoch, data, ~, ~] = self.importSingleEpoch();
            
            startSeconds = (epoch.getStartTime().getMillis() - epoch.getEpochGroup().getStartTime().getMillis) / 1000;
            endSeconds = (epoch.getEndTime().getMillis() - epoch.getEpochGroup().getStartTime().getMillis) / 1000;
            
            indWithinEpoch = find(startSeconds <= data.Track.thetaPeak_tAmpl(:,1) & data.Track.thetaPeak_tAmpl(:,1) <= endSeconds);
            assertEqual(sum(indWithinEpoch), length(epoch.getTimelineAnnotations('thetaPeak')));
            assert(~isempty(epoch.getMyDerivedResponse('thetaPeakTime')));
            assert(~isempty(epoch.getMyDerivedResponse('thetaPeakAmplitude')));
            
            indWithinEpoch = find(startSeconds <= data.Track.thetaTrough_tAmpl(:,1) & data.Track.thetaTrough_tAmpl(:,1) <= endSeconds);
            assertEqual(sum(indWithinEpoch), length(epoch.getTimelineAnnotations('thetaTrough')));
            assert(~isempty(epoch.getMyDerivedResponse('thetaTroughTime')));
            assert(~isempty(epoch.getMyDerivedResponse('thetaTroughAmplitude')));
            
            indWithinEpoch = find(startSeconds <= data.Track.thetaPtoTZeros_tAmpl(:,1) & data.Track.thetaPtoTZeros_tAmpl(:,1) <= endSeconds);
            assertEqual(sum(indWithinEpoch), length(epoch.getTimelineAnnotations('thetaPtoTZeros')));
            assert(~isempty(epoch.getMyDerivedResponse('thetaPtoTZerosTime')));
            assert(~isempty(epoch.getMyDerivedResponse('thetaPtoTZerosAmplitude')));
            
            indWithinEpoch = find(startSeconds <= data.Track.thetaTtoPZeros_tAmpl(:,1) & data.Track.thetaTtoPZeros_tAmpl(:,1) <= endSeconds);
            assertEqual(sum(indWithinEpoch), length(epoch.getTimelineAnnotations('thetaTtoPZeros')));
            assert(~isempty(epoch.getMyDerivedResponse('thetaTtoPZerosTime')));
            assert(~isempty(epoch.getMyDerivedResponse('thetaTtoPZerosAmplitude')));
        end
        
        function testShoulAddSpwDerivedResponses(self)
            [epoch, ~, ~, ~] = self.importSingleEpoch();
            
            assert(~isempty(epoch.getMyDerivedResponse('spw_peak')));
            assert(~isempty(epoch.getMyDerivedResponse('spw_start')));
            assert(~isempty(epoch.getMyDerivedResponse('spw_end')));
            assert(~isempty(epoch.getMyDerivedResponse('spw_shpwPeakAmplSD')));
            assert(~isempty(epoch.getMyDerivedResponse('spw_ripPeakAmplSD')));
        end
    end
end
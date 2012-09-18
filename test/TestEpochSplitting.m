% Copyright (c) 2012 Physion Consulting LLC

classdef TestEpochSplitting < TestMatlabSuite
    
    properties
        dataPath;
    end
    
    methods
        
        function self = TestEpochSplitting(name)
             self = self@TestMatlabSuite(name);
             self.dataPath = 'fixtures/A543-20120422-01_BehavElectrData.mat';
        end 
        
        function testShouldSplitEpochs(self)
            import ovation.*;
            
            behav = load(self.dataPath);
            
            epochs = splitEpochs(behav.Laps);
            
            assertEqual(22, length(epochs));
            
            for i = 1:length(epochs)
                assertEqual(epochs(i).startTimeSeconds,...
                    behav.Laps.startT(i));
                assertEqual(epochs(i).endTimeSeconds,...
                    behav.Laps.endT(i));
                
                assertEqual(epochs(i).lfpStartIndex,...
                    behav.Laps.startLfpInd(i));
                assertEqual(epochs(i).lfpEndIndex,...
                    behav.Laps.endLfpInd(i));
                
                % TODO ??
                %assertEqual(epochs(i).upsampledStartIndex,...
                %    behav.Laps.?
            end
                
        end
    end
end
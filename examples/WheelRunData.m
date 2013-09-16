%% Wheel run data from all Epochs
% This file loads all spikes from segments in which the mouse was running
% CW in the wheel

import ovation.*

%% Connect to database
ctx = NewDataContext();

%% Retrieve an EpochGroup from the database, replacint EPOCH_GROUP_URI with the URI of the desired Epoch
epochGroup = ctx.getObjectWithURI(EPOCH_GROUP_URI);

%% Collect Epochs
epochs = asarray(epochGroup.getEpochs());

%% Collect wheel run CW spikes from each Epoch
% We iterate over each epoch, pulling all timeline annotations from the
% "wheel-runs-cw" annotation group. Each annotation has the start and end
% index as a property (use getOwnerProperty to retrieve the value for that
% property set by the object's owner). We collect spikes and save them in a
% cell array 1xnTrials with each cell containing a 1xnRuns cell array whose
% elements are the spikes' time indexes.
spikes = {};
for i = 1:length(epochs)
    
    disp(['Epoch ' num2str(i) '...']);
    epoch = epochs(i);
    
    deviceParameters = map2struct(epoch.getDeviceParameters());
    lfpSampleRateHz = deviceParameters.lfpSampleRate;
    
    % Get the spike times (as indexes @ 1250Hz)
    analysisRecords = asarray(epoch.getAnalysisRecords(ctx.getAuthenticatedUser));
    spikeIndexRecord = [];
    for j = 1:length(analysisRecords)
        if(analysisRecords(j).getName().equals('Spikes'))
            spikeIndexRecord = analysisRecords(j);
            break;
        end
    end
    
    if(~isempty(spikeIndexRecord));
        
        spikeIndexes = nm2data(spikeIndexRecord.getOutputs().get('spike-index-lfp'));
        
        
        % Collect wheel run (CW) spike indexes:
        wheelRuns = {};
        
        timelineAnnotations = asarray(epoch.getUserTimelineAnnotations(ctx.getAuthenticatedUser()));
        for j = 1:length(timelineAnnotations)
            if(timelineAnnotations(j).getName().startsWith('wheel-runs-cw'))
                wheelRunAnnotation = timelineAnnotations(j);
                range = wheelRunAnnotation.getTimeRange();
                startIndex = (range.lowerEndpoint().getMillis() - epoch.getStart.getMillis())/1000 * lfpSampleRateHz;
                endIndex = (range.upperEndpoint().getMillis() - epoch.getStart.getMillis())/1000 * lfpSampleRateHz;
                
                wheelRuns{j} = spikeIndexes(startIndex <= spikeIndexes & spikeIndexes <= endIndex); %#ok<SAGROW>
            end
        end
        
        spikes{i} = wheelRuns; %#ok<SAGROW>
    end
end


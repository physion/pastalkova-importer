%% Wheel run data from all Epochs
% This file loads all spikes from segments in which the mouse was running
% CW in the wheel

%% Connect to database
ctx = NewDataContext('objectivity.int.janelia.org::/misc/ovation/pastalkova/pastalkova.connection');

%% Find the EpochGroup

% Get projects with name "Rat electrophysiology"
projects = ctx.getProjects('Rat experiments');
project = projects(1);

% Get all experiments from this project. You can retrieve experiments by
% date (see the documentation for project.getExperiments)
experiments = project.getExperiments();
experiment = experiments(1);

% Get all EpochGroups with the label "1-3 arm Alternation+wheel"
epochGroups = experiment.getEpochGroups('1-3 arm Alternation+wheel');
epochGroup = epochGroups(1);

% Get a list of Epochs from this EpochGroup
epochs = epochGroup.getEpochs();


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
    
    % Get the spike times (as indexes @ 1250Hz)
    spikeDerivedResponses = epoch.getDerivedResponses('spike-index-lfp');
    % If there was more than one spike-index-lfp derived response (i.e.
    % from more than one user, you would have to choose which one to use,
    % or use yours with getMyDerivedResponse('spike-index-lfp')
    assert(length(spikeDerivedResponses) == 1, 'For this demo, we expect only one. If there are more, you should choose which one to use');
    spikeDerivedResponse = spikeDerivedResponses(1);
    spikeIndexes = spikeDerivedResponse.getFloatingPointData();
    
    
    % Collect wheel run (CW) spike indexes:
    wheelRuns = {};
    
    wheelRunAnnotations = epoch.getTimelineAnnotations('wheel-runs-cw');
    for j = 1:length(wheelRunAnnotations)
        wheelRunAnnotation = wheelRunAnnotations(j);
        startIndex = wheelRunAnnotation.getOwnerProperty('lfpStartIndex');
        endIndex = wheelRunAnnotation.getOwnerProperty('lfpEndIndex');
        
        wheelRuns{j} = spikeIndexes(startIndex <= spikeIndexes & spikeIndexes <= endIndex); %#ok<SAGROW>
    end
    
    spikes{i} = wheelRuns; %#ok<SAGROW>
end


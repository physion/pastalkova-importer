function epoch = importEpoch(group, params, data, epochDescriptor)
    import ovation.*;
    
    protocolParams = params.epochGroup.protocol;
    protocolParams.wheelDirectionChoice = data.Laps.whlDirChoice(epochDescriptor.trialNumber);
    
    epoch = group.insertEpoch(group.getStartTime().plusSeconds(epochDescriptor.startTimeSeconds),...
        group.getStartTime().plusSeconds(epochDescriptor.endTimeSeconds),...
        ['org.hhmi.pastalkova.' char(group.getLabel())],...
        struct2map(protocolParams));
    
    
    
    importResponses(epoch, group, params, data, epochDescriptor);
    importDerivedResponses(epoch, params, data, epochDescriptor);
    importAnnotations(epoch, params, data, epochDescriptor);
    
end

function epoch = importAnnotations(epoch, params, data, epochDescriptor) %#ok<INUSL>
    
    cwStarts = data.Laps.WhlLfpIndStartCW{epochDescriptor.trialNumber} - data.Laps.startLfpInd(epochDescriptor.trialNumber);
    cwStops = data.Laps.WhlLfpIndEndCW{epochDescriptor.trialNumber} - data.Laps.startLfpInd(epochDescriptor.trialNumber);
    
    importWheelRuns(epoch, 'cw', 'Wheel Run CW', cwStarts, cwStops, data);
    
    ccwStarts = data.Laps.WhlLfpIndStartCCW{epochDescriptor.trialNumber} - data.Laps.startLfpInd(epochDescriptor.trialNumber);
    ccwStops = data.Laps.WhlLfpIndEndCCW{epochDescriptor.trialNumber} - data.Laps.startLfpInd(epochDescriptor.trialNumber);
    
    importWheelRuns(epoch, 'ccw', 'Wheel Run CCW', ccwStarts, ccwStops, data);
end

function epoch = importWheelRuns(epoch, tagSuffix, text, starts, stops, data)
    
    assert(all(size(starts) == size(stops)));
    
    for i = 1:numel(starts)
        
        startTime = epoch.getStartTime().plusMillis(1000 * starts(i) / data.xml.lfpSampleRate);
        endTime = epoch.getStartTime().plusMillis(1000 * stops(i) / data.xml.lfpSampleRate);
        
        annotation = epoch.addTimelineAnnotation(text,...
            ['wheel-runs-' tagSuffix],...
            startTime,...
            endTime);
        
        annotation.addTag(['wheel-run-' tagSuffix '-' num2str(i)]);
        annotation.addProperty('lfpStartIndex', starts(i));
        annotation.addProperty('lfpEndIndex', stops(i));
        
        if(i == numel(starts))
            annotation.addTag(['last-wheel-run-' tagSuffix]);
        end
    end
end

function epoch = importDerivedResponses(epoch, params, data, epochDescriptor)
    import ovation.*;
    
    % EEG
    epoch.insertDerivedResponse('eeg',...
        NumericData(data.Track.eeg(epochDescriptor.lfpStartIndex:epochDescriptor.lfpEndIndex)),...
        'unknown',... %TODO units
        struct2map(struct()),... % TODO Derivation parameters?
        {'downsampled eeg'});
    
    % Behavior type
    derivedResponses.Laps.behavType = derivedResponseDescriptor('n/a', 1, 'trial^{-1}', IResponseData.NUMERIC_DATA_UTI, epochDescriptor.trialNumber, 'assesment');
    
    
    % Tracking derived responses
    nlapcw = unique(data.Laps.NLapCW(epochDescriptor.lfpStartIndex:epochDescriptor.lfpEndIndex));
    if(~all(nlapcw == epochDescriptor.trialNumber | nlapcw == 0))
        error('pastalkova:ovation:import',...
            'NLapCW does not agree with Epoch trial number.');
    end
    
    nlapccw = unique(data.Laps.NLapCCW(epochDescriptor.lfpStartIndex:epochDescriptor.lfpEndIndex));
    if(~all(nlapccw == epochDescriptor.trialNumber | nlapccw == 0))
        error('pastalkova:ovation:import',...
            'NLapCCW does not agree with Epoch trial number.');
    end
    
    distanceUnits = '?'; % TODO units
    speedUnits = '?'; % TODO units
    derivedResponses.Laps.WhlDistCW = derivedResponseDescriptor(distanceUnits,...
        data.xml.lfpSampleRate, 'Hz', IResponseData.NUMERIC_DATA_UTI, epochDescriptor.lfpStartIndex:epochDescriptor.lfpEndIndex, 'distance');
    derivedResponses.Laps.WhlLapsDistCW = derivedResponseDescriptor(distanceUnits,...
        data.xml.lfpSampleRate, 'Hz', IResponseData.NUMERIC_DATA_UTI, epochDescriptor.lfpStartIndex:epochDescriptor.lfpEndIndex, 'distance');
    derivedResponses.Laps.WhlSpeedCW = derivedResponseDescriptor(speedUnits,...
        data.xml.lfpSampleRate, 'Hz', IResponseData.NUMERIC_DATA_UTI, epochDescriptor.lfpStartIndex:epochDescriptor.lfpEndIndex, 'spped');
    
    
    derivedResponses.Laps.WhlDistCCW = derivedResponseDescriptor(distanceUnits,...
        data.xml.lfpSampleRate, 'Hz', IResponseData.NUMERIC_DATA_UTI, epochDescriptor.lfpStartIndex:epochDescriptor.lfpEndIndex, 'distance');
    derivedResponses.Laps.WhlLapsDistCCW = derivedResponseDescriptor(distanceUnits,...
        data.xml.lfpSampleRate, 'Hz', IResponseData.NUMERIC_DATA_UTI, epochDescriptor.lfpStartIndex:epochDescriptor.lfpEndIndex, 'distance');
    derivedResponses.Laps.WhlSpeedCCW = derivedResponseDescriptor(speedUnits,...
        data.xml.lfpSampleRate, 'Hz', IResponseData.NUMERIC_DATA_UTI, epochDescriptor.lfpStartIndex:epochDescriptor.lfpEndIndex, 'speed');
    
    mmUnits = 'mm'; %TODO check
    derivedResponses.Track.xMM = derivedResponseDescriptor(mmUnits,...
        data.xml.lfpSampleRate,...
        'Hz',...
        IResponseData.NUMERIC_DATA_UTI,...
        epochDescriptor.lfpStartIndex:epochDescriptor.lfpEndIndex,....
        'distance');
    
    derivedResponses.Track.yMM = derivedResponseDescriptor(mmUnits,...
        data.xml.lfpSampleRate,...
        'Hz',...
        IResponseData.NUMERIC_DATA_UTI,...
        epochDescriptor.lfpStartIndex:epochDescriptor.lfpEndIndex,....
        'distance');
    
    derivedResponses.Track.mazeSect = derivedResponseDescriptor('n/a',...
        data.xml.lfpSampleRate,...
        'Hz',...
        IResponseData.NUMERIC_DATA_UTI,...
        epochDescriptor.lfpStartIndex:epochDescriptor.lfpEndIndex,....
        'section');
    
    derivedResponses.Track.speed_MMsec = derivedResponseDescriptor('mm/s',...
        data.xml.lfpSampleRate,...
        'Hz',...
        IResponseData.NUMERIC_DATA_UTI,...
        epochDescriptor.lfpStartIndex:epochDescriptor.lfpEndIndex,....
        'speed');
    
    derivedResponses.Track.accel_MMsecSq = derivedResponseDescriptor('mm/s^2',...
        data.xml.lfpSampleRate,...
        'Hz',...
        IResponseData.NUMERIC_DATA_UTI,...
        epochDescriptor.lfpStartIndex:epochDescriptor.lfpEndIndex,....
        'acceleration');
    
    derivedResponses.Track.headDirDeg = derivedResponseDescriptor('degrees',...
        data.xml.lfpSampleRate,...
        'Hz',...
        IResponseData.NUMERIC_DATA_UTI,...
        epochDescriptor.lfpStartIndex:epochDescriptor.lfpEndIndex,....
        'direction');
    
    derivedResponses.Track.realDistMM = derivedResponseDescriptor(mmUnits,...
        data.xml.lfpSampleRate,...
        'Hz',...
        IResponseData.NUMERIC_DATA_UTI,...
        epochDescriptor.lfpStartIndex:epochDescriptor.lfpEndIndex,....
        'distance');
    
    derivedResponses.Track.linXMM = derivedResponseDescriptor(mmUnits,...
        data.xml.lfpSampleRate,...
        'Hz',...
        IResponseData.NUMERIC_DATA_UTI,...
        epochDescriptor.lfpStartIndex:epochDescriptor.lfpEndIndex,....
        'distance');
    
    derivedResponses.Track.linYMM = derivedResponseDescriptor(mmUnits,...
        data.xml.lfpSampleRate,...
        'Hz',...
        IResponseData.NUMERIC_DATA_UTI,...
        epochDescriptor.lfpStartIndex:epochDescriptor.lfpEndIndex,....
        'distance');
    
    derivedResponses.Track.linXPix = derivedResponseDescriptor('pixels',...
        data.xml.lfpSampleRate,...
        'Hz',...
        IResponseData.NUMERIC_DATA_UTI,...
        epochDescriptor.lfpStartIndex:epochDescriptor.lfpEndIndex,....
        'distance');
    
    derivedResponses.Track.linYPix = derivedResponseDescriptor('pixels',...
        data.xml.lfpSampleRate,...
        'Hz',...
        IResponseData.NUMERIC_DATA_UTI,...
        epochDescriptor.lfpStartIndex:epochDescriptor.lfpEndIndex,....
        'distance');
    
    derivedResponses.Track.linDistMM = derivedResponseDescriptor(mmUnits,...
        data.xml.lfpSampleRate,...
        'Hz',...
        IResponseData.NUMERIC_DATA_UTI,...
        epochDescriptor.lfpStartIndex:epochDescriptor.lfpEndIndex,....
        'distance');
    
    thetaUnits = '?'; %TODO Units
    derivedResponses.Track.thetaPhHilb = derivedResponseDescriptor(thetaUnits,...
        data.xml.lfpSampleRate,...
        'Hz',...
        IResponseData.NUMERIC_DATA_UTI,...
        epochDescriptor.lfpStartIndex:epochDescriptor.lfpEndIndex,....
        'theta'); %TODO label
    
    derivedResponses.Track.thetaPhLinInterp = derivedResponseDescriptor(thetaUnits,...
        data.xml.lfpSampleRate,...
        'Hz',...
        IResponseData.NUMERIC_DATA_UTI,...
        epochDescriptor.lfpStartIndex:epochDescriptor.lfpEndIndex,....
        'theta'); %TODO label
    
    
    derivedResponseGroupNames = fieldnames(derivedResponses);
    for i = 1:length(derivedResponseGroupNames)
        drGroupName = derivedResponseGroupNames{i};
        drGroup = derivedResponses.(drGroupName);
        
        derivedResponseNames = fieldnames(drGroup);
        for j = 1:length(derivedResponseNames)
            drName = derivedResponseNames{j};
            drDescriptor = drGroup.(drName);
            
            samples = data.(drGroupName).(drName)';
            if(~isempty(drDescriptor.ind))
                samples = samples(drDescriptor.ind);
            end
            
            derivationParameters = mergeStruct(params.device.camera,...
                params.device.maze);
            
            derivedResponse = epoch.insertDerivedResponse(drName,...
                NumericData(samples),...
                drDescriptor.units,...
                struct2map(derivationParameters),... % TODO Derivation parameters?
                {drDescriptor.dimLabel});
            
            derivedResponse.addProperty('samplingRate', drDescriptor.samplingRate);
            derivedResponse.addProperty('samplingUnits', drDescriptor.samplingUnits);
        end
    end
    
    % Theta
    startSeconds = (epoch.getStartTime().getMillis() - epoch.getEpochGroup().getStartTime().getMillis) / 1000;
    endSeconds = (epoch.getEndTime().getMillis() - epoch.getEpochGroup().getStartTime().getMillis) / 1000;
    
    
    
    derivationParameters = struct(); % TODO parameters
    
    insertThetaEvents(epoch,...
        derivationParameters,...
        data.Track.thetaPeak_tAmpl,...
        startSeconds,...
        endSeconds,...
        'Theta peak',...
        'thetaPeak');
    
    insertThetaEvents(epoch,...
        derivationParameters,...
        data.Track.thetaTrough_tAmpl,...
        startSeconds,...
        endSeconds,...
        'Theta trough',...
        'thetaTrough');
    
    insertThetaEvents(epoch,...
        derivationParameters,...
        data.Track.thetaPtoTZeros_tAmpl,...
        startSeconds,...
        endSeconds,...
        'Theta peak-to-trough 0-crossing',...
        'thetaPtoTZero');
    
    insertThetaEvents(epoch,...
        derivationParameters,...
        data.Track.thetaTtoPZeros_tAmpl,...
        startSeconds,...
        endSeconds,...
        'Theta trough-to-peak 0-crossing',...
        'thetaTtoPZeros');
    
    % SPW events
    insertSpwTimeEvents(epoch,...
        data,...
        epochDescriptor,...
        derivationParameters,...
        data.Track.spw_peakT,...
        'spw peak time',...
        'spw_peak');
    
    insertSpwTimeEvents(epoch,...
        data,...
        epochDescriptor,...
        derivationParameters,...
        data.Track.spw_startT,...
        'spw peak start',...
        'spw_start');
    
    insertSpwTimeEvents(epoch,...
        data,...
        epochDescriptor,...
        derivationParameters,...
        data.Track.spw_endT,...
        'spw peak end',...
        'spw_end');
    
    values = data.Track.spw_shpwPeakAmplSD(epochDescriptor.lfpStartIndex <= data.Track.spw_peakT & ...
        data.Track.spw_peakT <= epochDescriptor.lfpEndIndex);
    if(~isempty(values))
        epoch.insertDerivedResponse('spw_shpwPeakAmplSD',...
            NumericData(values),...
            'uknown^2',... %TODO units
            struct2map(derivationParameters),...
            {'shpw peak amplitude SD'});
    end
    
    values = data.Track.spw_ripPeakAmplSD(epochDescriptor.lfpStartIndex <= data.Track.spw_peakT & ...
        data.Track.spw_peakT <= epochDescriptor.lfpEndIndex);
    if(~isempty(values))
        epoch.insertDerivedResponse('spw_ripPeakAmplSD',...
            NumericData(values),...
            'uknown^2',... %TODO units
            struct2map(derivationParameters),...
            {'rip peak amplitude SD'});
    end
        
    
    % Spikes
    spikeIdx = find(epochDescriptor.lfpStartIndex <= data.Spike.res & ...
        data.Spike.res <= epochDescriptor.lfpEndIndex);
    
    derivationParameters = struct();
    for i = 1:length(data.xml.SpkGrps)
        derivationParameters.(['spike_group_' num2str(i)]) = data.xml.SpkGrps(i);
        if(isfield(derivationParameters.(['spike_group_' num2str(i)]), 'clu'))
            error('pastalkova:ovation:import',...
                'Spike derivation parameters alread has a .clu field');
        end
        derivationParameters.(['spike_group_' num2str(i)]).clu = data.Clu;
    end
    
    spikeLfpIndex = data.Spike.res(spikeIdx) - epochDescriptor.lfpStartIndex;
    epoch.insertDerivedResponse('spike-index-lfp',...
        NumericData(spikeLfpIndex),...
        'index',...
        struct2map(derivationParameters),...
        {'spike time index'});
    
    spikeTimeSeconds = spikeLfpIndex / data.xml.lfpSampleRate;
    epoch.insertDerivedResponse('spike-lfp-time-seconds',...
        NumericData(spikeTimeSeconds),...
        's',...
        struct2map(derivationParameters),...
        {'spike time seconds'});
    
    
    rawStartIndex = floor(epochDescriptor.lfpStartIndex * data.xml.SampleRate / data.xml.lfpSampleRate);
    spikeRawIndex = data.Spike.res20kHz(spikeIdx) - rawStartIndex;
    epoch.insertDerivedResponse('spike-index-20kHz',...
        NumericData(spikeRawIndex),...
        'index',...
        struct2map(derivationParameters),...
        {'spike time index'});
    
    spikeTimeSeconds = spikeRawIndex / data.xml.SampleRate;
    epoch.insertDerivedResponse('spike-time-seconds',...
        NumericData(spikeTimeSeconds),...
        's',...
        struct2map(derivationParameters),...
        {'spike time seconds'});
    
    epoch.insertDerivedResponse('spike-clu',...
        NumericData(data.Spike.clu(spikeIdx)),...
        'cluster index',...
        struct2map(derivationParameters),...
        {'spike cluster index'});
    
    
    epoch.insertDerivedResponse('spike-shank',...
        NumericData(data.Spike.shank(spikeIdx)),...
        'shank index',...
        struct2map(derivationParameters),...
        {'spike shank index'});
    
    
    epoch.insertDerivedResponse('spike-totClu',...
        NumericData(data.Spike.totclu(spikeIdx)),...
        'cluster index',...
        struct2map(derivationParameters),...
        {'spike total cluster index'});
    
    epoch.insertDerivedResponse('spike-IDBurst',...
        NumericData(data.Spike.IDBurst(spikeIdx)),...
        'burst index',...
        struct2map(derivationParameters),...
        {'spike burst index'});
    
    epoch.insertDerivedResponse('spike-burstLength',...
        NumericData(data.Spike.burstLength(spikeIdx)),...
        'spikes',...
        struct2map(derivationParameters),...
        {'spike burst length'});
    
    epoch.insertDerivedResponse('spike-orderInBurst',...
        NumericData(data.Spike.orderInBurst(spikeIdx)),...
        'ordinal',...
        struct2map(derivationParameters),...
        {'spike order in burst'});
    
    spikeIdx = spikeIdx(spikeIdx <= length(data.Spike.thPhaseHilb));
    epoch.insertDerivedResponse('spike-thPhaseHilb',...
        NumericData(data.Spike.thPhaseHilb(spikeIdx)),...
        'rad',... %TODO units
        struct2map(derivationParameters),...
        {'spike theta phase (hilbert)'});
    
    epoch.insertDerivedResponse('spike-thPhaseInterp',...
        NumericData(data.Spike.thPhaseInterp(spikeIdx)),...
        'rad',... %TODO units
        struct2map(derivationParameters),...
        {'spike theta phase (interp)'});
end

function insertThetaEvents(epoch, parameters, events, startSeconds, endSeconds, text, annotationGroup)
    
    import ovation.*;
    
    eventRows = events(startSeconds <= events(:,1) & events(:,1) <= endSeconds, :);
    for r = eventRows
        eventTime = epoch.getEpochGroup().getStartTime().plusMillis(r(1) * 1000);
        epoch.addTimelineAnnotation(text, annotationGroup, eventTime);
    end
    
    
    epoch.insertDerivedResponse([annotationGroup 'Time'],...
        NumericData(eventRows(:,1)),...
        's',...
        struct2map(parameters),...
        {'event'});
    
    epoch.insertDerivedResponse([annotationGroup 'Amplitude'],...
        NumericData(eventRows(:, 2)),...
        'unknown',... %TODO units
        struct2map(parameters),...
        {'event'});
end

function insertSpwTimeEvents(epoch, data, epochDescriptor, derivationParameters, events, text, annotationGroup)
    import ovation.*;
    
    epochEvents = events(epochDescriptor.lfpStartIndex <= events & events <= epochDescriptor.lfpEndIndex) - epochDescriptor.lfpStartIndex;
    eventMillis = zeros(1, length(epochEvents));
    for i = 1:length(epochEvents)
        eventMillis(i) = events(i) / data.xml.lfpSampleRate;
        eventTime = epoch.getStartTime().plusMillis(eventMillis(i));
        epoch.addTimelineAnnotation(text, annotationGroup, eventTime);
        
    end
    
    if(~isempty(eventMillis))
        if(~isjava(derivationParameters))
            derivationParameters = struct2map(derivationParameters);
        end
        
        epoch.insertDerivedResponse(annotationGroup,...
            NumericData(eventMillis / 1000),...
            's',...
            derivationParameters,...
            {'event'});
    end
    
end

function d = derivedResponseDescriptor(units, srate, srateUnits, uti, ind, dimLabel)
    d.units = units;
    d.samplingRate = srate;
    d.samplingUnits = srateUnits;
    d.uti = uti;
    d.ind = ind;
    d.dimLabel = dimLabel;
end

function epoch = importResponses(epoch, group, params, data, epochDescriptor)
    import ovation.*;
    
    % LFP Response
    lfpDeviceParameters.nBits = data.xml.nBits;
    lfpDeviceParameters.voltageRange = data.xml.VoltageRange;
    lfpDeviceParameters.amplification = data.xml.Amplification;
    lfpDeviceParameters.offset = data.xml.Offset;
    startIndex = floor(epochDescriptor.lfpStartIndex * data.xml.SampleRate / data.xml.lfpSampleRate);
    endIndex = floor(epochDescriptor.lfpEndIndex * data.xml.SampleRate / data.xml.lfpSampleRate);
    
    epoch.insertResponse(group.getExperiment().externalDevice('Recording System', params.device.RecSyst.manufacturer),... % TODO This can be externalDevice('channelX', params.device.probe(y).manufacturer)
        struct2map(lfpDeviceParameters),...
        NumericData(single(data.Track.eegRaw(startIndex:endIndex))),... %TODO 32-bit float?
        'unknown',... % TODO units
        'LFP',...
        data.xml.SampleRate,...
        'Hz',...
        IResponseData.NUMERIC_DATA_UTI);
    
    % Arduino Responses
    epoch.insertResponse(group.getExperiment().externalDevice('Direction Choice', params.device.maze.manufacturer),...
        struct2map(struct()),...
        NumericData(data.Laps.dirChoice(epochDescriptor.trialNumber)),...
        'n/a',... % TODO units
        'choice',...
        1,...
        '1/trial',...
        IResponseData.NUMERIC_DATA_UTI);
    
    if(data.Laps.corrChoice(epochDescriptor.trialNumber))
        epoch.addTag('correct');
    end
    
    % Tracking Response
    params.device.tracking.manufacturer = 'JFRC'; % TODO
    trackerParameters = params.device.tracking;
    epoch.insertResponse(group.getExperiment().getExternalDevice('Tracking xPix', params.device.tracking.manufacturer),...
        struct2map(trackerParameters),...
        NumericData(data.Track.xPix(epochDescriptor.lfpStartIndex:epochDescriptor.lfpEndIndex)),...
        'pixels',...
        'x-position',...
        data.xml.lfpSampleRate,...
        'Hz',...
        IResponseData.NUMERIC_DATA_UTI);
    
    epoch.insertResponse(group.getExperiment().getExternalDevice('Tracking yPix', params.device.tracking.manufacturer),...
        struct2map(trackerParameters),...
        NumericData(data.Track.yPix(epochDescriptor.lfpStartIndex:epochDescriptor.lfpEndIndex)),...
        'pixels',...
        'y-position',...
        data.xml.lfpSampleRate,...
        'Hz',...
        IResponseData.NUMERIC_DATA_UTI);
end
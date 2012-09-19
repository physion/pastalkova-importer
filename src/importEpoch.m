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
    
end

function epoch = importDerivedResponses(epoch, params, data, epochDescriptor) %#ok<INUSL>
    import ovation.*;
    
    derivedResponses.Laps.behavType = derivedResponseDescriptor('n/a', 1, '1/trial', IResponseData.NUMERIC_DATA_UTI, epochDescriptor.trialNumber, 'assesment');
    
%     if(~all(unique(data.Laps.NLapCW(epochDescriptor.lfpStartIndex:epochDescriptor.lfpEndIndex)) == epochDescriptor.trialNumber))
%         error('pastalkova:ovation:import',...
%             'NLapCW does not agree with Epoch trial number.');
%     end
%     
%     if(~all(unique(data.Laps.NLapCCW(epochDescriptor.lfpStartIndex:epochDescriptor.lfpEndIndex)) == epochDescriptor.trialNumber))
%         error('pastalkova:ovation:import',...
%             'NLapCCW does not agree with Epoch trial number.');
%     end
    
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
            
            derivedResponse = epoch.insertDerivedResponse([drName '_' date()],...
                NumericData(samples),...
                drDescriptor.units,...
                struct2map(struct()),... % TODO Derivation parameters?
                {drDescriptor.dimLabel});
            
            derivedResponse.addProperty('samplingRate', drDescriptor.samplingRate);
            derivedResponse.addProperty('samplingUnits', drDescriptor.samplingUnits);
        end
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
    lfpDeviceParameters = struct();
    epoch.insertResponse(group.getExperiment().externalDevice('Recording System', params.device.RecSyst.manufacturer),...
        struct2map(lfpDeviceParameters),...
        NumericData(data.Track.eeg(epochDescriptor.lfpStartIndex:epochDescriptor.lfpEndIndex)),...
        'mV',... % TODO units
        'LFP',...
        data.xml.lfpSampleRate,...
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
    params.device.tracking.manufacturer = 'Pastalkova'; % TODO
    trackerParameters = struct(); %TODO
    epoch.insertResponse(group.getExperiment().getExternalDevice('Tracking xPix', params.device.tracking.manufacturer),...
        struct2map(trackerParameters),...
        NumericData(data.Track.xPix(epochDescriptor.lfpStartIndex:epochDescriptor.lfpEndIndex)),...
        'pixel',... % TODO units
        'x-position',...
        data.xml.lfpSampleRate,...
        'Hz',...
        IResponseData.NUMERIC_DATA_UTI);
    
    epoch.insertResponse(group.getExperiment().getExternalDevice('Tracking yPix', params.device.tracking.manufacturer),...
        struct2map(trackerParameters),...
        NumericData(data.Track.yPix(epochDescriptor.lfpStartIndex:epochDescriptor.lfpEndIndex)),...
        'pixel',... % TODO units
        'y-position',...
        data.xml.lfpSampleRate,...
        'Hz',...
        IResponseData.NUMERIC_DATA_UTI);
end
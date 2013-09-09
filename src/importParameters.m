function [project, group] = importParameters(ctx, project, parameters, xml)
    import ovation.*;
    
    sourceMap = importSource(ctx, parameters); % 'brain' source
    
    exp = importExperiment(project, parameters, xml);
    
    group = importGroup(exp, parameters);
    
end

function group = importGroup(exp, epochGroupProtocol, parameters)
   
    protocolParameters.restrictionLengthHrs = parameters.epochGroup.restrictionLengthHrs;
    protocolParameters.animalWeight = parameters.epochGroup.animWeight;
    protocolParameters.blockID = parameters.epochGroup.blockID;
    
    group = exp.insertEpochGroup(parameters.epochGroup.description,...
        exp.getStartTime(),...
        epochGroupProtocol,...
        protocolParameters,...
        []);
    
    group.addNote(group.getStart(), parameters.epochGroup.notes);
end

function exp = importExperiment(project, parameters, xml)
    
    purpose = parameters.experiment.purpose;
    startDate = parseDateTime(parameters.experiment.startDate,...
        parameters.experiment.timezone);
    
    itr = project.getExperiments().iterator();
    while(itr.hasNext())
        existingExperiment = itr.next();
        if(existingExperiment.getStart().equals(startDate))
            warning('pastalkova:ovation:import',...
                ['An experiment already exists for ' char(startDate)]);
        end
    end
    
    exp = project.insertExperiment(purpose, startDate);
    
    % TODO equipment setup replaces external devices
    exp.addProperty('nChTotal', parameters.experiment.nChTotal);
    exp.addProperty('nProbes', parameters.experiment.nProbes);
    exp.addProperty('nHeadstages', parameters.experiment.nHeadstages);
    exp.addProperty('originalFile', xml.FileName);
    importDevices(exp, parameters, xml);
end

function importDevices(exp, params, xml)
    import ovation.*;
    
    probes = importDeviceCollection(exp, params.device.probe, 'probe');
    nShankTotal = 1;
    for i = 1:length(probes)
        nShanks = params.device.probe(i).nShank;
        startShankIndex = nShankTotal;
        endShankIndex = nShankTotal + nShanks - 1;
        nShankTotal = nShankTotal + nShanks;
        
        shanks = xml.AnatGrps(startShankIndex:endShankIndex);
        for j = 1:length(shanks)
            shankDevice = exp.externalDevice(['shank' num2str(startShankIndex + j - 1)], params.device.probe(i).manufacturer);
            shankDevice.addProperty('channels', NumericData(int16(shanks(j).Channels)));
            shankDevice.addProperty('skip', NumericData(int8(shanks(j).Skip)));
            shankDevice.addProperty('probe', probes(i));
            
            channels = shanks(j).Channels;
            for k = 1:length(channels)
                channelDevice = exp.externalDevice(['channel' num2str(channels(k))], params.device.probe(i).manufacturer);
                channelDevice.addProperty('shank', shankDevice);
            end
        end
    end
    
    headstages = importDeviceCollection(exp, params.device.headstage, 'headstage');
    
    assert(length(probes) == length(headstages));
    
    for i = 1:length(probes)
        probes(i).addProperty('headstage', headstages(i));
    end
    
    dev = importDevice(exp, params.device.RecSyst, 'Recording System');
    
    cable = importDevice(exp, params.device.cable, 'Recording System Cable');
    dev.addProperty('cable', cable);
    
    for i = 1:length(headstages)
        headstages(i).addProperty('recording-system', dev);
    end
    
    params.device.tracking.manufacturer = 'JFRC'; %TODO
    trackXPix = importDevice(exp, params.device.tracking, 'Tracking xPix');
    trackYPix = importDevice(exp, params.device.tracking, 'Tracking yPix');
    camera = importDevice(exp, params.device.camera, 'camera');
    
    trackXPix.addProperty('camera', camera);
    trackYPix.addProperty('camera', camera);
    
    arduino = importDevice(exp, params.device.maze, 'Arduino');
    dirChoice = exp.externalDevice('Direction Choice', 'JFRC');
    dirChoice.addProperty('arduino', arduino);
end

function devices = importDeviceCollection(exp, deviceParams, prefix)
    for i = 1:length(deviceParams)
        devParam = deviceParams(i);
        devices(i) = importDevice(exp, devParam, [prefix num2str(i)]); %#ok<AGROW>
    end
end

function dev = importDevice(exp, devParam, name, prefix)
    if iscell(devParam.manufacturer)
        manufacturer = devParam.manufacturer{1};
    else
        manufacturer = devParam.manufacturer;
    end
    
    if(nargin > 3 && ~isempty(prefix))
        devName = [prefix name];
    else
        devName = name;
    end
    
    dev = exp.externalDevice(devName, manufacturer);
    fnames = fieldnames(devParam);
    for j = 1:length(fnames)
        fname = fnames{j};
        
        if(iscell(devParam.(fname)))
            assert(length(devParam.(fname)) == 1);
            value = devParam.(fname){1};
        else
            value = devParam.(fname);
        end
        
        try
            dev.addProperty(fname, value);
        catch ME %#ok<NASGU>
            warning('pastalkova:ovation:import',...
                ['Unable to import device property ' fname]);
        end
        
    end
end


function brain = importSource(ctx, parameters)
    import ovation.*;
    
    src = asarray(ctx.getSources(parameters.source.ID,...
        parameters.source.ID));
    
    if(isempty(src))
        src = ctx.insertSource(parameters.source.ID,...
            parameters.sourceID);
        src.addProperty('specie',...
            parameters.source.specie);
        src.addProperty('strain',...
            parameters.source.strain);
        src.addProperty('sex',...
            parameters.source.sex);
        src.addProperty('lightCycle',...
            parameters.source.lightCyc);
        
        %TODO brain protocol
        brain = src.insertSource('brain');
    else
        brains = src.getChildren('brain');
        assert(length(brains) == 1);
        brain = brains(1);
    end
    
    
    %TODO brainAreaLayer protocol
    %TODO return map {area : source}
    for i = 1:length(parameters.epochGroup.brainAreaLayer)
        label = parameters.epochGroup.brainAreaLayer{i};
        brain.insertSource(label);
    end
end
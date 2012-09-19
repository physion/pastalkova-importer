function [project, group] = importParameters(dsc, parameters, xml)
    import ovation.*;
    
    ctx = dsc.getContext();
    
    project = importProject(ctx, parameters);
    
    source = importSource(ctx, parameters); % 'brain' source
    
    exp = importExperiment(project, parameters, xml);
    
    group = importGroup(source, exp, parameters);
    
end

function group = importGroup(source, exp, parameters)
   
    group = exp.insertEpochGroup(source,...
        parameters.epochGroup.description,...
        exp.getStartTime());
    
    group.addProperty('restrictionLengthHrs',...
        parameters.epochGroup.restrictionLengthHrs);
    group.addProperty('animalWeight',... %TODO units?
        parameters.epochGroup.animWeight);
    group.addProperty('blockID',...
        parameters.epochGroup.blockID);
    
    group.addNote(parameters.epochGroup.notes, 'experiment-notes');
end

function exp = importExperiment(project, parameters, xml)
    
    purpose = parameters.experiment.purpose;
    startDate = parseDateTime(parameters.experiment.startDate,...
        parameters.experiment.timezone);
    
    existing = project.getExperiments(startDate);
    if(~isempty(existing))
        warning('pastalkova:ovation:import',...
            ['An experiment already exists for ' char(startDate)]);
    end
    
    exp = project.insertExperiment(purpose, startDate);
    
    exp.addProperty('nChTotal', parameters.experiment.nChTotal);
    exp.addProperty('nProbes', parameters.experiment.nProbes);
    exp.addProperty('nHeadstages', parameters.experiment.nHeadstages);
    exp.addProperty('originalFile', xml.FileName);
    
    importDevices(exp, parameters, xml);
end

function importDevices(exp, params, xml)
    
    probes = importDeviceCollection(exp, params.device.probe, 'probe');
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
    
    params.device.tracking.manufacturer = 'Pastalkova'; %TODO
    trackXPix = importDevice(exp, params.device.tracking, 'Tracking xPix');
    trackYPix = importDevice(exp, params.device.tracking, 'Tracking yPix');
    camera = importDevice(exp, params.device.camera, 'camera');
    
    trackXPix.addProperty('camera', camera);
    trackYPix.addProperty('camera', camera);
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

function project = importProject(ctx, parameters)
    projects = ctx.getProjects(parameters.project.name);
    
    if(length(projects) > 1)
        disp(['Multiple project with name ' projectName ':']);
        for i=1:length(projects)
            disp([num2str(i) '. ' char(projects(i).getStartTime().toString())]);
        end
        
        targetProject = -1;
        while (targetProject < 1 || targetProject > length(projects))
            targetProject = input('Import data into project: ');
        end
        
        project = projects(targetProject);
    elseif(length(projects) == 1)
        project = projects(1);
    else
        
        startDate = parseDateTime(parameters.experiment.startDate,...
            parameters.experiment.timezone);
        
        project = ctx.insertProject(parameters.project.name,...
            parameters.experiment.purpose,...
            startDate);
    end
end

function brain = importSource(ctx, parameters)
    import ovation.*;
    [src,isNew] = sourceForInsertion(ctx,...
        {parameters.source.ID},...
        {'ID'},...
        {parameters.source.ID});
    
    if(isNew)
        src.addProperty('specie',...
            parameters.source.specie);
        src.addProperty('strain',...
            parameters.source.strain);
        src.addProperty('sex',...
            parameters.source.sex);
        src.addProperty('lightCycle',...
            parameters.source.lightCyc);
        
        brain = src.insertSource('brain');
    else
        brains = src.getChildren('brain');
        assert(length(brains) == 1);
        brain = brains(1);
    end
    
    
    for i = 1:length(parameters.epochGroup.brainAreaLayer)
        label = parameters.epochGroup.brainAreaLayer{i};
        brain.insertSource(label);
    end
end
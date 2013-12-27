function [project, group, sourceMap] = importParameters(ctx,...
        project,...
        parameters,...
        xml,...
        expProtocol,...
        srcProtocol,...
        srcProtocolParameters,...
        srcDeviceParameters)
    
    
    import ovation.*;
    
    if(~verLessThan('matlab', '8.2'))
        narginchk(8, 8);
    end
    
    
    disp('  Importing Experiment...');
    exp = importExperiment(project, parameters, xml);
    
    
    disp('  Importing EpochGroup...');
    group = importGroup(exp, expProtocol, parameters); %TODO group protocol
    
    disp('  Importing Sources...');
    sourceMap = importSource(ctx,...  % 'brain' source
        parameters,...
        group,...
        srcProtocol,...
        srcProtocolParameters,...
        srcDeviceParameters);
    
end

function group = importGroup(exp, epochGroupProtocol, parameters)
   
    protocolParameters.restrictionLengthHrs = parameters.epochGroup.restrictionLengthHrs;
    protocolParameters.animalWeight = parameters.epochGroup.animWeight;
%     protocolParameters.blockID = parameters.epochGroup.blockID;
% changed 12-6-2013
    
    group = exp.insertEpochGroup(parameters.epochGroup.description,...
        exp.getStart(),...
        epochGroupProtocol,...
        ovation.struct2map(protocolParameters),...
        []);
    
    group.addNote(group.getStart(), parameters.epochGroup.notes);
end

function exp = importExperiment(project, parameters, xml)
    import ovation.*;
    
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
    
    equipment = parameters.device;
    
%     % Collect Probes under headstages
%     assert(length(equipment.headstage) == length(equipment.probe),...
%         'Expected parameters.device.headstange and parameters.device.probe to be equal length');
%     
%     for i = 1:length(equipment.headstage)
%         equipment.headstage(i).probe = equipment.probe(i);
%     end

 % Collect Probes under headstages
 
 % MADE A CHANGE TO ELIMINATE NEED FOR EQUAL NUMBER HEADSTAGE/PROBES
 % BRL 12-6-2013
    
    
    for i = 1:length(equipment.probe)
        equipment.headstage(i).probe = equipment.probe(i);
    end
    
    equipment = rmfield(equipment, 'probe');
    
    % Collect channels under probes
    % In-place access for c = equipment.channel(i):
    %   equipment.headstage(c.probeID).probe.channel(c.localChID)
    for i = 1:length(equipment.channel)
        channel = equipment.channel(i);
        channel.channelID = i;
        equipment.headstage(channel.probeID).probe.channel(channel.localChID) = channel;
    end
    
    
    
    equipment.nChTotal = parameters.experiment.nChTotal;
    equipment.nProbes = parameters.experiment.nProbes;
    equipment.nHeadstages = parameters.experiment.nHeadstages;
    equipment.arduino.version = '<unkown>'; %TODO arduino properties?
    
    equipmentDetails = struct2map(equipment);
    exp.setEquipmentSetupFromMap(equipmentDetails);
    
    exp.addProperty('nChTotal', parameters.experiment.nChTotal);
    exp.addProperty('nProbes', parameters.experiment.nProbes);
    exp.addProperty('nHeadstages', parameters.experiment.nHeadstages);
    exp.addProperty('originalFile', xml.FileName);
end


function sourceMap = importSource(ctx,...
        parameters,...
        epochGroup,...
        srcProtocol,...
        srcProtocolParameters,...
        srcDeviceParameters)
    
    import ovation.*;
    import com.google.common.base.Optional;
    
    src = asarray(ctx.getSources(parameters.source.ID,...
        parameters.source.ID));
    assert(length(src) <= 1);
    if(length(src) == 1)
        src = src(1);
    end
    
    if(isempty(srcProtocolParameters))
        srcProtocolParameters = struct2map(struct());
    elseif(isstruct(srcProtocolParameters))
        srcProtocolParameters = struct2map(srcProtocolParameters);
    end
    
    if(isempty(srcDeviceParameters))
        srcDeviceParameters = struct2map(struct());
    elseif(isstruct(srcDeviceParameters))
        srcDeviceParameters = struct2map(srcDeviceParameters);
    end
    
    
    if(isempty(src))
        src = ctx.insertSource(parameters.source.ID,...
            parameters.source.ID);
        src.addProperty('specie',...
            parameters.source.specie);
        src.addProperty('strain',...
            parameters.source.strain);
        src.addProperty('sex',...
            parameters.source.sex);
        src.addProperty('lightCycle',...
            parameters.source.lightCyc);
        
        %TODO brain protocol
        brain = src.insertSource(epochGroup,...
            epochGroup.getStart(),...
            epochGroup.getStart(),...
            srcProtocol,...
            srcProtocolParameters,...
            com.google.common.base.Optional.of(srcDeviceParameters),...
            'brain',...
            parameters.source.ID);
    else
        children = asarray(src.getChildrenSources());
        brains = {};
        for i = 1:length(children)
            if(children(i).getLabel().equals('brain'))
                brains{end+1} = children(i); %#ok<AGROW>
            end
        end
        
        if(isempty(brains))
            %TODO brain protocol
            brain = src.insertSource(epochGroup,...
                epochGroup.getStart(),...
                epochGroup.getStart(),...
                srcProtocol,...
                srcProtocolParameters,...
                com.google.common.base.Optional.of(srcDeviceParameters),...
                'brain',...
                parameters.source.ID);
        else 
            brain = brains{1};
        end
    end
    
    sourceMap = java.util.HashMap();
    sourceMap.put('mouse', src);
    sourceMap.put('brain', brain);
    
    %TODO epochGroup.brainArealayer does not match
    %  params.device.probe.targetBrainArea... should they match??
    for i = 1:length(parameters.epochGroup.brainAreaLayer)
        label = parameters.epochGroup.brainAreaLayer{i};
        
        
        src = brain.insertSource(epochGroup,...
            epochGroup.getStart(),...
            epochGroup.getStart(),...
            srcProtocol,...
            srcProtocolParameters,...
            com.google.common.base.Optional.of(srcDeviceParameters),...
            label,...
            parameters.source.ID);
        sourceMap.put(label, src);
    end
end
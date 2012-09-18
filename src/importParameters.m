function [project, group] = importParameters(dsc, parameters)
    import ovation.*;
    
    ctx = dsc.getContext();
    
    project = importProject(ctx, parameters);
    
    source = importSource(ctx, parameters);
    
    exp = importExperiment(project, parameters);
    
    group = importGroup(source, exp, parameters);
    
end

function group = importGroup(source, exp, parameters)
   
    group = exp.insertEpochGroup(source, 'test', exp.getStartTime());
end

function exp = importExperiment(project, parameters)
    
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

function src = importSource(ctx, parameters)
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
    end 
end
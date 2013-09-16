%% Context
ctx = NewDataContext();

%% Fixture
params = load('test/fixtures/A543-20120422-01-param.mat');
data = load('test/fixtures/A543-20120422-01_BehavElectrData.mat');


%% Project
% project = ctx.insertProject('Pastalkova Import', 'Testing Pastalkova Lab importer', datetime());

project = ctx.getObjectWithURI('ovation://788934fe-b240-44ea-9a1f-24ecc27dfc83/');

%% Protocols

% srcProtocol = ctx.insertProtocol('Source Protocol',...
%     'Source derivation protocol mouse => brain area');

srcProtocol = ctx.getObjectWithURI('ovation://f0d9ab41-ae91-435c-a76c-9a197396ae8e/');

% expProtocol = ctx.insertProtocol('Experiment Protocol',...
%     'Exp protocol');

expProtocol = ctx.getObjectWithURI('ovation://93b8833e-3526-4c3e-8b83-980e5588c622/');


% epochProtocol = ctx.insertProtocol('Epoch Protocol',...
%     'Epoch protocol');

epochProtocol = ctx.getObjectWithURI('ovation://7539d9fc-754b-45fc-85d3-27174da619e4/');

% analysisProtocol = ctx.insertProtocol('Analysis Protocol',...
%     'Analysis Protocol');

analysisProtocol = ctx.getObjectWithURI('ovation://f5798530-e1c7-4f9f-ae7b-420e0be47b36/');


%% Parameters
[~, grp, sourceMap] = importParameters(ctx,...
    project,...
    params,...
    data.xml,...
    expProtocol,...
    srcProtocol,...
    [],...
    []);

%% Epoch
 d = splitEpochs(data.Laps);
 
ind = 4;
epoch = importEpoch(grp,...
    epochProtocol,...
    params, ...
    data,...
    d(ind),...
    sourceMap,...
    analysisProtocol);

%% All Epochs

group = ctx.getObjectWithURI('ovation://3594bd3c-5aba-4a5a-a169-f0d3742c3f7a/');
inputSources = java.util.HashMap();
inputSources.put('EC-deep', ctx.getObjectWithURI('ovation://f36fc4b9-5c1b-42e8-a734-f9fbaae45ae9/'));
inputSources.put('CA1', ctx.getObjectWithURI('ovation://9d6265eb-d878-4499-9878-ca3022258c0c/'));
inputSources.put('mouse', ctx.getObjectWithURI('ovation://4d2c5c10-c83e-4905-a797-b14bd6cf9df4/'));
inputSources.put('brain', ctx.getObjectWithURI('ovation://e7710daf-fe74-4b3d-80cb-6d9ef438dbcb/'));

ImportEpochs(group, params, data, inputSources, epochProtocol, analysisProtocol);
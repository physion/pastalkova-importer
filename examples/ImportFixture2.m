%% Connect
import ovation.*
context = NewDataContext();

%% Retrieve the Project object

% OPTION 1: From the DataContext's list of Projects
projects = asarray(context.getProjects()); % As array converts Ovation's Iterable result into a Matlab array
project = projects(1); % Assumes there's only one Project in the database

% OPTION 2: From URI
% Select the Project object in the Ovation application, then choose "Copy"
% from the "Edit" menu. Return to Matlab and paste the URI as a string
% below


project = context.getObjectWithURI('ovation://47988cfc-dfcd-4780-927e-6f1ec6cee80c/'); % get this from ovation right click


%% Load the Parameters and Data MAT
params = load('test/fixtures/A498-20120807-01-param.mat');
data = load('test/fixtures/A498-20120807-01_BehavElectrData.mat');

%% Find or create the experimental protocol

% Replace this protocol name with the correct name for your Experimental
% protocol.
protocolName = 'A498-20120807-01 DAT_MUSCIMOL';

% Retrieve the named protocol
protocol = context.getProtocol(protocolName);
if(isempty(protocol)) % protocol does not exist yet
    
    % Replace the second parameter with your protocol's description, using
    % {VARIABLE_NAME} to denote variables/parameters in the protocol. This
    % protocol should describe 
    protocol = context.insertProtocol(protocolName, '...Delayed Alternation Task...');
end

%% Find or create the Source protocol

% The source protocol is used to describe the procedure for deriving a
% brain region Source from the animal Source. In other words, how do you
% get an electrode into a brain region of an animal?

% Replace this protocol name with the correct name for your Experimental
% protocol.
protocolName = 'A498-20120807-01 Electrode Placement';

% Retrieve the named protocol
srcProtocol = context.getProtocol(protocolName);
if(isempty(srcProtocol)) % protocol does not exist yet
    
    % Replace the second parameter with your protocol's description, using
    % {VARIABLE_NAME} to denote variables/parameters in the protocol.
    srcProtocol = context.insertProtocol(protocolName, '...recording from CA1 cannula in Medial Septum...');
end

srcDerivationParameters = struct(); % Any parameters of this protocol for placing an electrode?
srcDerivationDeviceParameters = struct(); % Any device parameters for placing an electrode?

%% Find or create the analysis protocol

% The analysis protocol describes the code/procedure for automated analysis
% of Epoch raw data (e.g. spike clustering, phase analysis, etc.)

protocolName = 'A498-20120807-01 Analysis Stuff';

% Retrieve the named protocol
analysisProtocol = context.getProtocol(protocolName);
if(isempty(analysisProtocol)) % protocol does not exist yet
    
    % Replace the second parameter with your protocol's description, using
    % {VARIABLE_NAME} to denote variables/parameters in the protocol. For
    % code-based protocols, provide the top-level function, and the
    % (GitHub) URL and revision number of the repository.
    analysisProtocol = context.insertProtocol(protocolName,...
        '...Protocol document here...',...
        '...Top level function name here...',...
        '...Code (GitHub) URL here...',...
        '...Code (Git) revision here...'...
        );
end

%% Run the import

[experiment,epochs] = ImportExperiment(context,...
    project,...
    params,...
    data,...
    protocol,...
    analysisProtocol,...
    srcProtocol,...
    struct2map(srcDerivationParameters),...
    struct2map(srcDerivationDeviceParameters));
    
% init script to run OSU Workshop SLRT code

clearvars; close all; clc;


%% === constants ==========================================================
createBusObj;
createDefinitions;

Ts = 1/1000;    % SLRT loop rate

tgName = 'EGIBaseline1';

mdlName = 'osuWorkshop';
appFileName = 'workshopApp';

fileDecimation = 5; % 5 -> 200Hz at 1kHz Fs

appDecimation = 200; % decimation of app (200 = 5Hz at 1kHz Fs)
appDecimationReduced = 1000;
appDecimationAxes = 100;

axesDt = 20;

slBuildDir = 'c:\simulink\build2022b'; % built directory; this is where the App gets the RT excecutable from
slCacheDir = 'c:\simulink\cache2022b'; % cache directory

lb2N = 4.44822;
lodCellMaxLb = 100;

loadCellMaxN = lodCellMaxLb * lb2N; 

loadCellCal = 2.1887; % mV/V

el3751PhysicalRange = 32; % mV/V
el3751DigitalRange = double(0x773594); % corresponds to 32 mV/V
el3751Scale = el3751DigitalRange / el3751PhysicalRange; % reading per mV/V

loadCellScale = loadCellMaxN/(el3751Scale*loadCellCal); % from digital reading to N

el5101SetCounterCmd = uint8(0x4);       % bit 2 rising edge sets counter
el5101CounterInitVal = uint32(2^31);    % set counter mid-way; for realistic motions, this will not overflow

encoderPosGain = 10e-6/4/64; % resolution of 10um, factor 4 for quad decoding; factor 64 - check SDOs?

ctrlSignalScale = 10/3; % 3A -> 10V;
% =========================================================================

%% === Setup SDI ==========================================================
Simulink.sdi.clear;                     % clear old data from SDI
Simulink.sdi.setRecordData(true);       % needs to be true to enable later data import
Simulink.sdi.setAutoArchiveMode(false); % set archive to false to avoid SDI DB growing
% =========================================================================

%% == set build/cache paths ===============================================
if ~strcmpi(get_param(0,'CacheFolder'),slCacheDir) || ...
        ~strcmpi(get_param(0,'CodeGenFolder'),slBuildDir)
    resp = questdlg({['Simulink build and cache folders not set to ', ...
                        slBuildDir,' and ',slCacheDir,'.'],...
                    'Would you like to set these now?', ...
                    'Disregarding may result in unintended behavior.'}, ...
                    'Simulink build settings','Yes');

    if isempty(resp) || strcmp(resp,'Cancel')
        disp('Stopping build')
        return
    end

    if strcmp(resp,'Yes')
        if ~exist(slCacheDir,'dir')
            mkdir(slCacheDir);
        end
        if ~exist(slBuildDir,'dir')
            mkdir(slBuildDir);
        end
        set_param(0,'CacheFolder',slCacheDir)
        set_param(0,'CodeGenFolder',slBuildDir)
    end
end
% =========================================================================

%% === build code =========================================================
resp = questdlg({'Would you like to rebuild the model?'},'Perform Build?','Yes');

if isempty(resp) || strcmp(resp,'Cancel')
    disp('InitCtrl cancelled by user.')
    return
end

if strcmp(resp,'Yes')
   
    fprintf('*** Build Simulink RT (Speedgoat) code ...\n\n')
    load_system(mdlName);
    set_param(mdlName, 'RTWVerbose', 'off');
  
    % build model
    slbuild(mdlName)

    % === setting app options, see https://www.mathworks.com/matlabcentral/answers/1813580-why-does-it-take-so-long-to-stop-a-real-time-application-running-on-speedgoat-if-my-model-contains-m
    rtApp = slrealtime.Application(mdlName);
    updateAutoSaveParameterSetOnStop(rtApp,false);

else
    fprintf('*** Skipping Simulink Build Proceedure. Using cached model.\n\n')
end
% =========================================================================

%% === create a timestamped copy of the model =============================
currentTime = datetime;
currentTime.Format = 'yyyy_MM_dd_HH_mm_ss';
timeStr = char(currentTime); 
mdlNameTs = [mdlName,'_',timeStr];

src = fullfile(slBuildDir,[mdlName,'.mldatx']);
dest = fullfile(slBuildDir,[mdlNameTs,'.mldatx']);

copyfile(src,dest);
fprintf('Copied model to %s.\n',dest)
% =========================================================================

%% === test Speedgoat connection ==========================================
tg = slrealtime(tgName);
try 
   tg.connect
catch ME
   fprintf('\n*** Target %s not connected. Stopping program. Check connection.\n',tgName)
   fprintf('\n*** Matlab error \n %s \n\n',ME.getReport)   
   return  
end

if tg.isConnected 
   fprintf('\n*** Target %s is connected at IP address %s. Starting app ...\n\n',tg.TargetSettings.name,tg.TargetSettings.address)
end
% ========================================================================= 

%% === start the app ======================================================
run(appFileName)
% =========================================================================  


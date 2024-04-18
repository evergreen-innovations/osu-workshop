

%% === EtherCAT status bus ================================================
clear eCatStatusStruct;
eCatStatusStruct.eCatErr = int32(0);
eCatStatusStruct.eCatLastErr = int32(0);
eCatStatusStruct.eCatState = int32(0);
eCatStatusStruct.eCatDcErr = int32(0);
eCatStatusStruct.eCatMnClkDiff = int32(0);
eCatStatusStruct.eCatDcInit = int32(0);
eCatStatusStruct.eCatNsClkDiff = int32(0);

eCatStatusBusInfo = Simulink.Bus.createObject(eCatStatusStruct);
eCatStatusBus = evalin('base',eCatStatusBusInfo.busName);
% =========================================================================

%% ==== Actuator status bus ===============================================
clear actuatorStatusStruct;

actuatorStatusStruct.opEnabled = logical(false);
actuatorStatusStruct.homed = logical(false);
actuatorStatusStruct.warning = logical(false);
actuatorStatusStruct.error = logical(false);

actuatorStatusStruct.rawCounter = uint32(0); % raw encoder counter value
actuatorStatusStruct.position_m = 0.0;
actuatorStatusStruct.velocity_m_s = 0.0;
actuatorStatusStruct.force_N = 0.0;

actuatorStatusBusInfo = Simulink.Bus.createObject(actuatorStatusStruct);
actuatorStatusBus = evalin('base',actuatorStatusBusInfo.busName);
% =========================================================================

%% === Control bus ========================================================
clear ctrlStruct;

ctrlStruct.state = uint32(0); % internal state
ctrlStruct.switchOn = logical(false);
ctrlStruct.home = logical(false);
ctrlStruct.specialMode = logical(false);
ctrlStruct.acknError = logical(false);
ctrlStruct.counterCtrl = uint8(0);
ctrlStruct.counterVal = uint32(0);

ctrlStruct.current_A = 0.0; % might change to vel ctrl?
ctrlStruct.forceSetpoint_N = 0.0;

ctrlBusInfo = Simulink.Bus.createObject(ctrlStruct);
ctrlBus = evalin('base',ctrlBusInfo.busName);
% =========================================================================




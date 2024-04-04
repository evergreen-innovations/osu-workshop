% init script to run OSU Workshop SLRT code

clearvars; close all; clc;

Ts = 1/1000;    % SLRT loop rate

lb2N = 4.44822;
lodCellMaxLb = 100;

loadCellMaxN = lodCellMaxLb * lb2N; 

loadCellCal = 2.1887; % mV/V

el3751PhysicalRange = 32; % mV/V
el3751DigitalRange = double(0x773594); % corresponds to 32 mV/V
el3751Scale = el3751DigitalRange / el3751PhysicalRange; % reading per mV/V

loadCellScale = loadCellMaxN/(el3751Scale*loadCellCal); % from digital reading to N

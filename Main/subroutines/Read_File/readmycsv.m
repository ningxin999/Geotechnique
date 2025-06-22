function [tarray_observation,tvector_stagetime] = readmycsv(csvpath, readObservation,stagetime)
% ADDME: Reads observation and stage time data from CSV files.
% This function reads observation data and stage time information from
% specified CSV files in a given directory. It supports multiple observation
% files and an optional stage time file.
% Example Usage:
% [obsData, stageTime] = readmycsv('path/to/data', true, true);

% Inputs:
%   csvpath - Path to the folder containing the CSV files.
%   readObservation - Boolean flag to determine if observation files should be read.
%   stagetime - Boolean flag to determine if stage time file should be read.
%
% 
% Outputs:
%   tarray_observation - Cell array containing observation data as arrays.
%                        If readObservation is false, returns 'null'.
%   tvector_stagetime - Array containing stage time data.
%                       If stagetime is false, returns 'null'.


%% Step 1: Initialize Outputs
tarray_observation = 'null';
tvector_stagetime = 'null';


%% Step 2: Read Observation Data
if readObservation
    filePattern = 'Observation*.csv';
    
    % Get a list of files in the folder
    observationFiles  = dir(fullfile(csvpath, filePattern));
    
    % Count the number of observationFiles 
    numObservations = numel(observationFiles);    % Number of observation observationFiles 

    if numObservations == 0
        error('No observation files found in directory: %s', csvpath);
    else
        tarray_observation = cell(1, numObservations);
        for i = 1:numObservations
            filename = fullfile(csvpath, sprintf('Observation%d.csv', i));
            % Read the table from the CSV file
            observationTable  = readtable(filename);            
            % Convert the table to array
            tarray_observation{i} = table2array(observationTable);
        end
    end
end

%%  Step 3: Read Stage Time Data
if stagetime
    % Read stage time file
    stageTimeFile = fullfile(csvpath, 'StageTime.csv');
    if ~isfile(stageTimeFile)
        error('StageTime.csv file not found in directory: %s', csvpath);
    else
        tvector_stagetime = readtable(stageTimeFile,ReadRowNames=true);        
        % Convert table to array
        tvector_stagetime = table2array(tvector_stagetime);
    end

end
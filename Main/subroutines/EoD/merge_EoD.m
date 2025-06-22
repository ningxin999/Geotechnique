function [ coord, EDarray_Summary, FEcell_output_Summary,FE_stageTime] = merge_EoD(AnParam)
% merge_EoD: Merge different EoD results from the 'EoD_FE_summary' directory.
% This function loads the finite element (FE) results, processes them, and merges them 
% into summary structures.
%
% Input:
%   AnParam - Analysis parameters, including directory and output field information.
%
% Output:
%   coord - FE output coordinate data
%   EDarray_Summary - Merged EoD summary data.
%   FEcell_output_Summary - Merged finite element cell output data.
%   FE_stageTime - FE output stage time data (if available).


% Step 1: Define the subfolder where EoD FE summary files are stored
    subfolder = fullfile(AnParam.directory.exportmat,'EoD_FE_summary');

% Step 2: Find all .mat files in the subfolder
    files = dir(fullfile(subfolder, '*.mat'));
    if isempty(files)
        error('Please provide at least one FE result!!!');
    end


% Step 3: Initialize the data structures for merging
    % Initialize FEcell_output_Summary as a cell array of empty cells   
    for ii = 1:AnParam.N_outputfields
        for jj = 1:AnParam.N_FE_stage
            FEcell_output_Summary{ii}{jj}= [];
        end
    end
    % Initialize EDarray_Summary as an empty array
    EDarray_Summary = [];

% Step 4: Loop through each file and merge the data
    for kk = 1:numel(files)
        load(fullfile(subfolder,files(kk).name));    
        for ii = 1:AnParam.N_outputfields
            for jj = 1:AnParam.N_FE_stage
                FEcell_output_Summary{ii}{jj}= vertcat(FEcell_output_Summary{ii}{jj},FEcell_output{ii}{jj});
            end
        end
        EDarray_Summary = vertcat(EDarray_Summary,EDarray);
    end	

end
function AnParam = read_error_weight(AnParam)
% AddME: Read surrogate error and weight vector, noise covariance,


% Input:
%   AnParam - Structure containing analysis parameters, including the field 'N_outputfields'
%             which specifies the number of output fields (e.g., dimensions).

%
% Output:
%   AnParam - Updated AnParam structure that now includes:
%             - AnParam.surrogateerror: Surrogate error matrix.
%             - AnParam.w_LL: Weight vector for importance assignment.
%             - AnParam.COVdata: noise covariance if it exists

% get the working directory
directory = AnParam.directory;

% Step 1: Load Observation Noise Covariance Matrix
matCOVfile = 'observationNoise.mat';% File name for observation noise covariance matrix
matcov_dir = fullfile(directory.inputmat, matCOVfile);% Full path
[AnParam.COVdata, ~] = load_and_check_file(AnParam,matcov_dir, 'COVALL', AnParam.N_outputfields);



% Step 2: Load Surrogate Error Matrix (must be available)
mat_surrogateerror_file = 'SEmatrix.mat';% file name
mat_surrogateerror_dir = fullfile(directory.inputmat, mat_surrogateerror_file);% file path
[AnParam.surrogateerror, ~] = load_and_check_file(AnParam,mat_surrogateerror_dir, 'SEmatrix', AnParam.N_outputfields);


% Step 3: Load Weight LL Matrix (must be available)
wLL_file = 'wLL.mat';% file name
mat_wLL_dir = fullfile(directory.inputmat, wLL_file);% file path
[AnParam.w_LL, ~] = load_and_check_file(AnParam,mat_wLL_dir, 'wLL', AnParam.N_outputfields);


end




function [data, success] = load_and_check_file(AnParam,filePath, expectedField, N_outputfields)
    % This function checks if the file exists, loads it, and verifies that the 
    % number of fields matches N_outputfields.
    % 
    % Input:
    %AnParam - Structure containing analysis parameters,
    %   - filePath: The full path to the .mat file.
    %   - expectedField: The field name inside the .mat file to check.
    %   - N_outputfields: The expected number of output fields.
    %
    % Output:
    %   - data: The loaded data from the .mat file.
    %   - success: Boolean indicating whether the operation was successful.

    success = false;
    data = [];
    
    if isfile(filePath)  % Check if the file exists using isfile
        % Load the .mat file
        tempData = load(filePath);       

        % Verify the number of fields matches N_outputfields
        if N_outputfields == numel(tempData.(expectedField))
            data = tempData.(expectedField);
            success = true;
            disp([expectedField, ' file exists and loaded successfully.']);
        else
            error([expectedField, ' file has an incorrect number of fields.']);
        end

    else
        % Handle missing files by creating default data
        switch expectedField
            case 'COVALL'
                warning([expectedField, ' file does not exist, now doing inference for this!']);

            case 'SEmatrix'
                warning([expectedField, ' file does not exist, create default file in ', filePath]);
                %create SEmatrix file
                for ii = 1: AnParam.N_outputfields
                    for jj = 1:AnParam.N_Obs_stage  
                        coord_N = round(AnParam.N_coord(ii)/AnParam.N_Exp); % coord number
                        SEmatrix{1,ii}{1,jj}= zeros(coord_N,coord_N);
                    end
                end
                %save the MDmatrix file to filePath
                save(filePath,expectedField);data = SEmatrix;
                
            case 'wLL'
                warning([expectedField, ' file does not exist, create default file in ', filePath]);
                %create MDmatrix file
                for ii = 1: AnParam.N_outputfields
                    for jj = 1:AnParam.N_Obs_stage  
                        wLL{1,ii}{1,jj}= ones(round(AnParam.N_coord(ii)/AnParam.N_Exp),1);
                    end
                end
                %save the MDmatrix file to filePath
                save(filePath,expectedField);data = wLL;
        end


    end
end

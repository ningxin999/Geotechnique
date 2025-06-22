function AnParam = read_obs_error(AnParam,directory)
%ADDME: read (1 )observation noise matrix (2) modelling error (3) surrogate error
%               if it exist in .mat file

% Input: AnParam structure
% Output: AnParam--save the all results into the AnParam structure
%           including: AnParam.COVdata,AnParam.modelerror,
%           AnParam.surrogateerror




% tell if the observation noise COV matrix exist or not
matCOVfile = 'observationNoise.mat';% file name
matcov_dir = fullfile(directory.inputmat, matCOVfile);% file path
if exist(matcov_dir,'file') == 2% if COV noise matrix exists,'2' means existing
    % read  observation noise COV
    AnParam.COVdata = load(matcov_dir);

    %disp the information on the panel
    disp('Observation noise file exist...');
    
    % check the N_outputfields consistent with number of COV field
    if AnParam.N_outputfields ~= numel(AnParam.COVdata.COVALL)
        error('Observation noise Covariance number is wrong, please check!');
    end
else
    disp('Observation noise file doesnot exist, and will do inference!');
end


% tell if the model error vectors exist or not
mat_modelerror_file = 'modelError.mat';% file name
mat_modelerror_dir = fullfile(directory.inputmat, mat_modelerror_file);% file path
if exist(mat_modelerror_dir,'file') == 2% if model error exists,'2' means existing
    % read  model error
    AnParam.modelerror = load(mat_modelerror_dir);

    %disp the information on the panel
    disp('Modelling errorfile exist...');
    
    % check the N_outputfields consistent with number of model error field
    if AnParam.N_outputfields ~= numel(AnParam.modelerror.MDmatrix)
        error('Model error number is wrong, please check!');
    end
else
    error('Model error file doesnot exist, please provide!');
end



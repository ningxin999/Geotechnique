function [myPCEcell,PCAcell] = surrogate_train(AnParam, EDarray, FEcell_output)  
% ADDME:   surrogate training and exporting 
%tell a surrogate folder is existing or not: if exist, skip this subroutine; 
% if not, contine to train the surrogate

%Input:   AnParam-Analysis structure with parameters
%         experimentaldesign-Training data and test data are predifined 
%                             : test data = AnParam.TestDataRun (e.g., 10 runs)
%                             : training data = TrainRun = rangePerc * (Allrun - TestDataRun);
%         FEoutput-FE output
%         jj-th stage number

% Output:myPCEcell,PCAcell : e.g., PCE-PCA combined structure or ANN


% surrogateName and surrogatepath setting
mainfolder = fullfile(pwd,'trained_surrogate');

%two cases: Case one: existing folder, load the surrogate trained;
%           Case two: no such folder, continue to the next code to
%           create/save
surrogateName = 'trained_surrogate.mat';
surrogatepath  = fullfile(mainfolder,'model',surrogateName);
if exist(mainfolder, 'dir')
    load(surrogatepath)
    return;
else
    if isfolder(mainfolder) == 0
        mkdir(mainfolder);
    end
end

%% start surrogate traning
myPCEcell = cell(1, AnParam.N_Obs_stage);
PCAcell = cell(1, AnParam.N_Obs_stage);

for jj = 1:AnParam.N_Obs_stage
    %create/prepare the PCEPCA structure  for FE prediction
    [myPCEcell{jj}, PCAcell{jj}]  = PCEPCA(AnParam, EDarray, FEcell_output, jj);
end

mainfolder_model = fullfile(pwd,'trained_surrogate','model');
if isfolder(mainfolder_model) == 0
    mkdir(mainfolder_model);
end
save(surrogatepath, 'myPCEcell','PCAcell','-v7.3');


end
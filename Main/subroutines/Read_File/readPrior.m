function [Prior_hyperdiscrep,Prior_EoD,priorObj] = readPrior(AnParam)
%ADDME: create priors for Prior_hyperdiscrep, Prior_EoD

% Inputs:  
%       directory: directory path for input and output (.csv) 

%Output: AnParam structure containing:
%       Prior_hyperdiscrep: predictive prior for observation discrepancy error parameter 
%       Prior_EoD: prior for surrogate construction 
%       priorObj: prior object

%create obj PriorClass
directory = AnParam.directory;
priorObj = PriorClass(directory);

%%=====================printing Prior_hyperdiscrep for ===========
Prior_hyperdiscrep = priorObj.Prior_hyperdiscrep;
numOutputs = numel(Prior_hyperdiscrep); 
%loop through displaying for debug (optional)
for ii = 1:numOutputs
    disp(['Hyper parameter (Gaussian-type observation error) for outputfield ' num2str(ii)])
    readtable(fullfile(directory.inputcsv,[ 'hyper_obs_discrepancy' num2str(ii) '.csv']), ...
                                    TextType="string", VariableNamingRule="preserve")
end

%%=====================create Prior_EoD for ===========
Prior_EoD = priorObj.Prior_EoD;
disp('Parameter priors for experimental design')
Prior_EoD % display for debug (optional)

end



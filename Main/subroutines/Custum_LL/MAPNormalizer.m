function Y  = MAPNormalizer(AnParam,Posterior,BayesAnalysis,jj)
%ADDME: Different QoIs loglikelihood cannot be merge together easily,
%       beacuse the LL values magnitutes are far different. We need to
%       normalized the LL with LL_MAP (LL values at MAP)
%       Main idea: find the MAP values and get the LL_MAP and save them

%Input:   AnParam: Analysis structure with parameters
%         Posterior: from stage one to current stage jj 
%         directory: directory structure for input/output folders

%Output: No output required, only save the MAP to the folder 

%No output required 
Y = 'Null';

%if the switich for LL_Normalizer is on, read the MAP saved calculate the normalized LL and return;
%if the switich for LL_Normalizer is off, we need to calculate MAP for preparation
if AnParam.LL_Normalizer == "on"  
    % %calculate the normalized MAP LL evaluations at new MAP values
    % X_MAP_new = BayesAnalysis.Results.PostProc.PointEstimate.X{1, 1};
    % LL_eva_new = BayesAnalysis.LogLikelihood(X_MAP_new);
    %     MAP_folder = fullfile(pwd,'MAPNormalizer');
    %     MAP_flie = fullfile(MAP_folder,'MAP.csv');
    %     MAP_table = table2array(readtable(MAP_flie));
    %     AnParam.MAPforLL = MAP_table(jj,:);
    % X_MAP_old = X_MAP_new ;
    % X_MAP_old(1:6) = AnParam.MAPforLL ;
    % LL_eva_old = BayesAnalysis.LogLikelihood(X_MAP_old);
    % LL_norm = LL_eva_new./ abs(LL_eva_old);
    % 
    % %saving to 'MAPNormalizer' folder
    % Print_MAP_new = array2table(Posterior_summary_MAP);
    % Print_MAP_new.Properties.VariableNames(1:AnParam.N_parameters) = AnParam.Name;
    % writetable(Print_MAP,filepath);%exporting MAP.csv
    return;
else
    %folder name
    MAP_folder = fullfile(pwd,'MAPNormalizer');
    
    %two cases: Case one: existing folder,meaning MAP already existed, skip;
    %           Case two: no such folder, continue to the next code to save MAP
    filename = 'MAP.csv';
    filepath  = fullfile(MAP_folder,filename);
    if ~exist('MAPNormalizer', 'dir')
        mkdir(MAP_folder);
    end
    
        
    % extract the MAP values in each stage posterior
    for ii = 1: AnParam.N_parameters                      
        N_posterior = size(Posterior,2);% number of  components in posterior cell
    
        Posterior_summary_MAP = [];% loop to concatenate all MAP values
        for mm = 1:N_posterior
            Posterior_summary_MAP = [Posterior_summary_MAP; cell2mat({Posterior{mm}.MAP})];
        end
       
    end
    
    
    
    %print/save the MAP
    Print_MAP = array2table(Posterior_summary_MAP);
    Print_MAP.Properties.VariableNames(1:AnParam.N_parameters) = AnParam.Name;
    writetable(Print_MAP,filepath);%exporting MAP.csv

end




    

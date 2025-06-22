function Y = LL_MAP_test(BayesAnalysis,AnParam, jj)
%ADDME: Test LL values at MAP values
%       It is difficult to understand the discrepancy terms and
%       its contribution to LL values. A easy way to run different
%       outputfields separetely and have a look at their MAP absolute
%       values

%Input: BayesAnalysis: results containing posterior and MAP
%       AnParam: passing structure

%No output required
Y = 'Null';


% tell switch for LL_save on or off
if AnParam.LL_MAP_test == "off"
    return;
end

%calculate the LL evaluations at MAP values
X_MAP = BayesAnalysis.Results.PostProc.PointEstimate.X{1, 1};
LL_eva = BayesAnalysis.LogLikelihood(X_MAP);


%% saving
% get the full path to create a 'savedResults' folder         
path_savedFigure = fullfile(pwd(), 'savedResults'); 
if isfolder(path_savedFigure) == 0
    mkdir(path_savedFigure);
end

% get the full path to create a 'LL_MAP_eval' folder       
outputfolder = fullfile(path_savedFigure,'LL_MAP_eval');
if jj==1 & isfolder(outputfolder) == 0
    mkdir(outputfolder);
end


%Name and save as a 'LL_MAP_eval.csv'
filename = 'LL_MAP_eval.csv';
filepath  = fullfile(outputfolder,filename); 
writematrix(LL_eva,filepath,'WriteMode','Append');%exporting LL_MAP_eval.csv





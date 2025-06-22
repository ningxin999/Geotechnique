
function [myPCEcell,PCAcell] = surrogate_check(AnParam, EDarray, FEcell_output)  
% ADDME:   We already have the surrogate trained. We wanna know the
%          surrogate performance: PCA reconstruction figs and PCE-PCA test performance 

%Input:   AnParam-Analysis structure with parameters
%         experimentaldesign-Training data and test data are predifined 
%                             : test data = AnParam.TestDataRun (e.g., 10 runs)
%                             : training data = TrainRun = rangePerc * (Allrun - TestDataRun);
%         FEoutput-FE output
%         jj-th stage number

% Output:No output required



[myPCE, PCA]  = PCEPCA(AnParam, EDarray, FEcell_output_interp, ll);



end
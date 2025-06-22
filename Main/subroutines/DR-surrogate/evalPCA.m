
function PCA = evalPCA(PCA, FE_output, explainedvariance_threshold)  
% ADDME  Calculates PCs based on an array of FE output to a minimum explained vairance.
%
% Inputs:  
% PCA structures for an observation field                             (structure)
% Array of doubles containing FE output. m runs; n number of outputs  (array of double) 
% Percentage variance explained by PCA components                     (1x1 double)  
% 
% Output:
% Modified PCA structure                                              (structure)
%
% 

if ~iscell(FE_output)
    [m,n]   = size(FE_output);                            % Calculate the rows and coloums of FE_output
else
    FE_output = FE_output{1};
    [m,n]   = size(FE_output);
end


%-------------Step 1: do PCA -----------------% 
    %%%%%% Note: pca build-in function in matlab doesnot require normalization

    %PCA.V : V stands for eigen vector (eigen vector means new axis to be projected)
    %PCA.S : S stands for score (score means PCs in new coordinates),
             %not required
    %latent: absolute variance contribution for every PC in full PCs space, can be
    %        converted to PCA.E
    %PCA.E: explain contribution percentage in PC space, sum(PCA.E) is 100
    %PCA.cumE: cumulative explain contribution in PC space
    
    PCA.dataprocess = FE_output;
    % dont print warning
    evalc('[PCA.V,PCA.score,latent,~,PCA.E,PCA.mv] = pca(FE_output,''Economy'',false);');
    
       

%-------------Step 2: calculate the cumulative contribution  -----------------% 
    tep         = PCA.E./sum(PCA.E);% normalized the contribution percentage
    PCA.cumE    = cumsum(tep);      % calculate the cumulative contribution percentage
    PCA.number  = find(PCA.cumE>explainedvariance_threshold,1);% find the minimum PCs number required
    
%------------- Step 3: Set a minimum PC components (in case minimumPC is not a number) -----------------%
    if PCA.number < PCA.minimumPC
        PCA.number = PCA.minimumPC;
    end	

	

end
function Posterior = BI_postprocess(jj,BayesAnalysis,AnParam,Posterior,gtarray,myPriorDist,Prior_forward)
%ADDME: Burn in 70% posterior samples and extract posterior samples for data preparation 
%       for next stage priors. Plot corner plots for posterior samples
 

%Input: 
%       jj-the jj-th number of stage jj <----1,2,...,AnParam.N_FE_stage 
%       AnParam-structure of analysis parameters
%       BayesAnalysis-result strcuture, all posterior information is stored in this.
%       gtarray: known ground truth parameters
%       Posterior: posterior cells
%       myPriorDist: prior strcuture
%       Prior_forward: experimental design strcuture


%Output:Posterior structure after burn-in and updating 


% Burn in 70% for BayesAnalysis
    uq_postProcessInversionMCMC(BayesAnalysis,'pointEstimate','MAP','burnin',0.7);
    
    
% Extract samples from the BayesAnalysis strcuture and reshape into a vector
%store all results in Posterior cell
    for ll = 1: AnParam.N_parameters                
        temp =  BayesAnalysis.Results.PostProc.PostSample(:,ll,:);
        Posterior{jj}(ll).samples = reshape(permute(temp, [2 1 3]), size(temp, 2), [])';
        Posterior{jj}(ll).mv = BayesAnalysis.Results.PostProc.Percentiles.Mean(:,ll);
        Posterior{jj}(ll).st = BayesAnalysis.Results.PostProc.Percentiles.Var(:,ll)^0.5;
        Posterior{jj}(ll).LB = BayesAnalysis.Results.PostProc.Percentiles.Values(1,ll);
        Posterior{jj}(ll).UB = BayesAnalysis.Results.PostProc.Percentiles.Values(2,ll);
        Posterior{jj}(ll).MAP = BayesAnalysis.Results.PostProc.PointEstimate.X{:}(ll);
    end   


%plot the posterior corner scatter plotting 
    if AnParam.Switch_corner_scatter == "on"
        if jj ==1
            cornerplot_scatter(Prior_forward,Posterior,gtarray,jj,AnParam,myPriorDist);
        else 
            cornerplot_scatter(Prior_forward,Posterior,gtarray,jj,AnParam);
        end
    end

    
end


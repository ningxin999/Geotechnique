function pred_vectorPlot(varargin)
%ADDME: A seperate function to plot prior/posterior predictive vector output figs

%get the input parser number of varargin
N_parser = length(varargin);
% two cases
if N_parser == 9, casename = 'prior'; else, casename = 'posterior'; end

%=====================================================================
%=====================Two cases=======================================
if isequal(casename  ,'prior')

    %Gather out the inputs
    [AnParam,Prior_samples,coord,ll,kk,obs_eachfield, gtarray,myPCE, PCA] = varargin{:};

    % Prediction step
    %(1) prior samples prediction on FE output
    FE_predict = makePrediction(AnParam, Prior_samples, ll, myPCE, PCA, kk);
    %(2) gtarray sample prediction on FE output
    if  isnumeric(gtarray)
        FE_pred_gt = makePrediction(AnParam, gtarray, ll, myPCE, PCA, kk);
    else
        FE_pred_gt = 'Null';
    end
    %(3) plotting
    plotPrediction(coord, FE_predict, obs_eachfield, FE_pred_gt, ll, AnParam, [], kk);


else
    %Gather out the inputs
    [AnParam,post_samples, coord,ll,kk,obs_eachfield,jj, gtarray,Posterior,myPCE, PCA] = varargin{:};
    
    % calculate posterior samples FE prediction
    FE_predict = makePrediction(AnParam, post_samples, ll, myPCE, PCA, kk);
    % calculate MAP samples FE prediction if it exists
    FE_MAP_predict = makePrediction(AnParam, [Posterior{jj}.MAP], ll, myPCE, PCA, kk);
    if  isnumeric(gtarray)
        FE_pred_gt = makePrediction(AnParam, gtarray, ll, myPCE, PCA, kk);
    else
        FE_pred_gt = 'Null';
    end

    plotPrediction(coord, FE_predict, obs_eachfield, FE_pred_gt, ll, AnParam, FE_MAP_predict, kk);


		
end
end









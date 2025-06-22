function logL = LL(params, y, PCA, myPCE, n,N_start,N_end,coord,AnParam,covdata,SE,wLL)
%ADDME: User-defined log-likelihood.  


% Inputs:  
% params: an array of MCMC parameter set (including forward/discrepancy paramerters)(array of doubles)
% y: matrix of observation data (could be one or multiple observations)             (array of doubles)
% PCA: structures based on output field                                             (structure)
% myPCE: surrogate based on reduced PCA space                                       (custom class uq_model)
% n: AnParam.N_parameters-forward paramters                                         (integer)
% N_start: starting offset position for hyperparameters (dynamic changing)          (integer)  
%          This dynamic changing position is from missing observations sometime
% N_end: ending offset position for hyperparameters                                 (integer)  
% coord: spatial coordination                                                       (vector/scalar)
% AnParam: a structure containing the analysis parameters                           (structure)

% Output:logL 


%% Gather out:model response from PCs space to real output space
% get the forward model parameters and MAP_norm (if required)
    X_val  = params(:,1:n);% forward parameters
  

% get the discrepancy hyperparamters (depened on basis choice and iid assumption made)
    hyper_Legendre_parameters = params(:,n+N_start:n+N_end);
    N_hyper = size(hyper_Legendre_parameters,2);% number of hyperparameters
    w = hyper_Legendre_parameters(:,1:end);


%Evalution of YPCE (gathering out process)
%case one: DR; case two: without DR
    if AnParam.DR == "on"
        % make prediction YPCE for PCs 
        if AnParam.Surrogate == "custom"
        temp = custom_predict(X_val, myPCE.psin, myPCE.psout, myPCE.lstmnet);
        YPCE = temp(:,AnParam.jj);
        else
        PCA_PCE =  uq_evalModel(myPCE,X_val);    
        % reconstruct the output        
        YPCE = PCA_PCE * PCA.V(:, 1:PCA.number)' + PCA.mv;
        end

    else
        YPCE =  uq_evalModel(myPCE,X_val);
    end

%% Observation error discrepancy setting

%evaluate the legendre polynomials on the interval [-1,1] (polynomil index starting from 0)
%N_end - N_start-1: considering starting from 0      
    poly_index = N_end - N_start;%poly index
    polys = legendrePolynomialBasis(poly_index,coord);% polynomial basis


%% Loop trough chains/sets of observations
    % y may contain AnParam.N_Exp sets of Exp; change the observation vector y into
    % observation matrix y : [exp1 exp2 exp3 ...]--> [exp1; exp2; exp3;...]
    y = reshape(y,[],AnParam.N_Exp)'; 
	%get rid of zeros in the observations
	y(y == 0) = 1e-15;
    nExp = size(y,1);% sets number of observations
    logL=zeros(size(params,1),1);% initial setting zeros for logL
	

    %Loop 1 to get every chain's logLikelihood, Loop 2 is to consider different sets 
    %of the experiments   
    for ii = 1:size(params,1)  
        %get the sigma matrix
        wCurr = w(ii,:)';


        if ~isempty(AnParam.COVdata)
            mustBeScalarOrEmpty(wCurr);   %  wCurr can only have one hyperparameter and should be close to 1.0
            C = diag(diag(covdata)).*abs(wCurr)+ 1e-10*eye(numel(coord));% 1e-10 to avoid the definite positive error  
        else
            D = polys*wCurr;        
            Diagonal_sigma = diag(D);

               
            % calculate the R matrix            
			R = 1;
            C = Diagonal_sigma*R*Diagonal_sigma + 1e-15*eye(numel(coord));% 1e-10 to avoid the definite positive error      
        end

        L = chol(C,'lower');
        %L = nearestSPD(C);
        Linv = inv(L);
        Cinv = Linv'*Linv;
        logCdet = 2*trace(log(L));
            
        % Loop 2  to get the sum of logL
        logLikeli = 0;% for each chain LL sum
        for jj = 1:nExp    

            % Calculate the log-likelihood
            deltay = y(jj,:) - YPCE(ii,:);    % Prediction error (observation minus surrogate prediction)
            
            % Normalize surrogate model error covariance by the observation magnitude
            SE_norm_diag = diag(diag(SE)) ./ y(jj,:);
            
            % Define a scaling factor for surrogate model error:
            % Take the maximum of normalized surrogate errors
            coe_SE = max(SE_norm_diag(:))+1;  
            
            % Update the log-likelihood
            logLikeli = logLikeli ...
                - 0.5 * logCdet ...                       % Term from covariance determinant
                - 0.5 * (deltay .* wLL') * (Cinv .* coe_SE) * (deltay' .* wLL);  % Mahalanobis distance term
        end

        %consider N_exp and length of coord
        logL(ii) = logLikeli/AnParam.N_Exp/numel(coord);%/N_length_obs /N_exp
         
    end



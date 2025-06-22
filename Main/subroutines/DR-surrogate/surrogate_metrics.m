function surrogate_metrics(varargin)  
% SURROGATE_METRICS - Evaluates surrogate model performance metrics.
%
% Metrics include:
%   - PCA reconstruction error (if DR is enabled).
%   - Test error (validation set performance).
%   - Training error (training set performance).
%
% Inputs (via varargin):
%   AnParam, PCA, kk, jj, PCE_train_dataset, myPCE, 
%   experimentaldesign, FEoutput, N_test, N_train



% Extract input variables
[AnParam, PCA, kk, jj, PCE_train_dataset, myPCE, ...
experimentaldesign, FEoutput, N_test, N_train] = varargin{:};

%% PCA Reconstruction Error (if DR is enabled)
if AnParam.Switch_surrogatePlot == "on" && AnParam.DR == "on"
    PCA_reconstruct_plotter(AnParam, PCA, kk, PCE_train_dataset, jj);
end

%% Test Error (Validation Set Performance)
YPCE_test = evaluateSurrogate(myPCE{kk}, experimentaldesign(end-N_test+1:end,:), ...
            PCA{kk}, AnParam.DR, N_test, 'Test');

if AnParam.Switch_surrogatePlot == "on"
    test_Surrogate_plotter(AnParam, N_test, YPCE_test, FEoutput, kk, jj); 
end


%% Training Error (Training Set Performance)
YPCE_train = evaluateSurrogate(myPCE{kk}, experimentaldesign(1:N_train,:), ...
              PCA{kk}, AnParam.DR, N_train, 'Train');

if AnParam.Switch_surrogatePlot == "on"
    train_Surrogate_plotter(AnParam, N_train, YPCE_train, FEoutput, kk, jj); 
end




end




%% Helper Function
function YPCE = evaluateSurrogate(model, design, PCA, DR, N, evalType)
% EVALUATESURROGATE - Evaluates surrogate model with/without DR.
%
% Inputs:
%   model   - Surrogate model (PCE/PCK/SSE).
%   design  - Input design points.
%   PCA     - PCA structure (if DR is enabled).
%   DR      - Dimensionality reduction flag ("on"/"off").
%   N       - Number of samples.
%   evalType- Evaluation type ('Test' or 'Train').

temp = uq_evalModel(model, design);

if DR == "on"
    % Reconstruct output using PCA
    YPCE = temp * PCA.V(:, 1:PCA.number)' + PCA.mv;  
else
    % Direct surrogate evaluation
    YPCE = temp;
end

fprintf('%s evaluation completed for %d samples.\n', evalType, N);
end
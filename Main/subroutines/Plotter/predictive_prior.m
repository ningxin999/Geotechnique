function predictive_prior(varargin)
% PRIOR_PREDICTIVE_PLOTS Generate prior predictive distribution visualizations
%
% Inputs (via varargin):
%   AnParam - Analysis parameters structure
%   coord - FE output coordinates (cell array)
%   observationsarray - Observation data (cell array)
%   gtarray - Ground truth data (optional)
%   observation_stageTime - Time points for observation stages
%   myPriorDist - Prior distribution structure
%   jj_first - Stage index (must be 1 for prior prediction)
%   myPCEcell, PCAcell - Pretrained surrogate models (cell arrays)


%Notation for LOOP variables:
%                           :   field_idx-number of outputfield
%                           :   jj_first : only for 1st stage for prior
%                                          predictive plotting
%                           :   stage_idx-current stage for N_obs stage


%gathering out input variables
[AnParam,coord,observationsarray, gtarray,observation_stageTime,...
myPriorDist,jj_first,myPCEcell,PCAcell] = varargin{:};

% Early return if predictive plotting is disabled or not in first stage
if AnParam.Switch_Predictive == "off" || jj_first ~= 1
    return;              
end

% Setup output directory        
path_savedFigure = fullfile(pwd(), 'savedResults'); 
if isfolder(path_savedFigure) == 0
    mkdir(path_savedFigure);
end

% Generate prior samples 
uq_selectInput(myPriorDist)%select input prior
temp = uq_getSample(100,'LHS');
Prior_samples = temp(:,1:length(AnParam.Name));

% Main processing loop for each output field
for field_idx = 1:AnParam.N_outputfields
% ========== Vector Output Processing ==========
    if ~isscalar(coord{field_idx})    
        for stage_idx = 1:AnParam.N_Obs_stage 
            % create new figure without displaying
            fig_save = figure('visible','off');

            % Get appropriate surrogate model
            if AnParam.Surrogate == "custom" 
                myPCE = myPCEcell{1, 1}.Data;PCA  = PCAcell{1, 1};
            else
                myPCE = myPCEcell{stage_idx};PCA  = PCAcell{stage_idx};
            end
            % Generate and save plot
            pred_vectorPlot(AnParam,Prior_samples, ...
                         coord,stage_idx,field_idx,observationsarray{field_idx}, gtarray,myPCE, PCA);                
            figureExportPredictive(field_idx,path_savedFigure,stage_idx,fig_save,AnParam,'priorPredictive');                
        end    
    end

% ========== Scalar Output Processing ==========
    if isscalar(coord{field_idx})
        % create new figure without displaying
        fig_save = figure('visible','off');% create new figure        
        Y_predict_all = [];% create Y_predict_all to restore all results

        % Add PY curve if applicable
        hold on;
        directory = AnParam.directory;
        [~] = py_curve(directory,jj_first,observation_stageTime);

        % Process each stage 
        for stage_idx = 1:AnParam.N_Obs_stage
            % Get appropriate surrogate model
            if AnParam.Surrogate == "custom" 
                myPCE = myPCEcell{1, 1}.Data;PCA  = PCAcell{1, 1};
            else
                myPCE = myPCEcell{stage_idx};PCA  = PCAcell{stage_idx};
            end

            % Generate predictions 
            Y_predict = makePrediction(AnParam, Prior_samples, stage_idx, myPCE, PCA, field_idx);
            %Handle ground truth if available
            Y_gt_pred = 'Null';
            if  isnumeric(gtarray)
                Y_gt_pred = makePrediction(AnParam, gtarray, stage_idx, myPCE, PCA, field_idx);               
            end

            %box plotting data preparation
            Y_predict_all = horzcat(Y_predict_all,Y_predict);
            
            % Plot observations and ground truth
            plot_args  = {AnParam,stage_idx,field_idx,observationsarray,gtarray, ...
                        Y_gt_pred,observation_stageTime};
            [h_gt,h_obs,~] = MAP_GT_Obs_predictive(plot_args);     
        end

        % Create boxplot and finalize figure
        hold on;
        Boxplot(Y_predict_all,field_idx,observation_stageTime); 

        %add legend
        %Addlegend(h_gt,h_obs,'Null');

        % export scalar outputs figs if required
        figureExportPredictive(field_idx,path_savedFigure,fig_save,AnParam,'priorPredictive'); 
    end
        
end


end

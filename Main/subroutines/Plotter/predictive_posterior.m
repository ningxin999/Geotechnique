function predictive_posterior(Posterior,AnParam,jj,EDarray,FEcell_output,coord,observationsarray, ...
                                    gtarray,observation_stageTime,myPCEcell,PCAcell)
%ADDME: Plot the predictive posterior figures  



%Input: Posterior: Posterior stored (till current jj-stage)
%       AnParam: Analysis parameters
%       jj: jj-th stage, passed in as current time
%       EDarray: experimental design array
%       FEcell_output: FE output cell after interpolation and trim
%       coord: FE output coordinate cell after trim
%       observationsarray： observation array for different outputfields
%       gtarray: ground truth (may not exist for real projects)
%       observation_stageTime
%       myPCEcell,PCAcell: pretrained surrogate

%Notation for LOOP variables:
%                           :   kk-number of outputfield
%                           :   ll-number of loading stages
%                           :   jj-current stage



%% switch for the predictive posterior
if AnParam.Switch_Predictive == "off"
    return;        
end

%% create new folders to save figs
% get the full path to create a 'savedResults' folder         
path_savedFigure = fullfile(pwd(), 'savedResults'); 

% create new empty file 'savedResults';
% Switch_Predict_prior is "off"
if isfolder(path_savedFigure) == 0        
    mkdir(path_savedFigure);
end



%% extract the post_samples from current posterior (Note: All predictive posterior
% are based on jj-th posterior samples)
for tt = 1:AnParam.N_parameters   
    post_allsamples(:,tt) = Posterior{jj}(tt).samples;
end    
post_samples = post_allsamples(randperm(size(post_allsamples, 1), 100), :);

%% plot predictive posterior for different source of outputfields
for kk = 1:AnParam.N_outputfields

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%predictive posterior on vector outputs%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ~isscalar(coord{kk})
        %Loop to plot predictive posterior 
        for ll = 1:AnParam.N_Obs_stage 

            % call the PCEPCA structure trained for FE prediction
            myPCE = myPCEcell{ll};PCA  = PCAcell{ll};


            % create new figure without displaying
            fig_save = figure('visible','off');

            % single plotting 
            pred_vectorPlot(AnParam,post_samples, ...
                         coord,ll,kk,observationsarray{kk},jj, gtarray,Posterior,myPCE, PCA);


            % export vector outputs figures if required
            figureExportPredictive(jj,kk,path_savedFigure,ll,fig_save,AnParam,'posteriorPredictive');                
        end  
                
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%predictive posterior on scalar outputs %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if isscalar(coord{kk})
        % create new figure
        fig_S = figure('visible','off');

        FE_pred_summary = [];% create FE_pred_summary to restoure all results

        % Add py curve (only for pisa pile scalar output)
        hold on;        
        [~] = py_curve(AnParam.directory,jj,observation_stageTime);


        %loop to plot all scalar predictive posterior for all stages
        for ll = 1:AnParam.N_Obs_stage
            % call the PCEPCA structure trained for FE prediction
            if AnParam.Surrogate == "custom" 
                myPCE = myPCEcell{1, 1}.Data;PCA  = PCAcell{1, 1};
            else
                myPCE = myPCEcell{ll};PCA  = PCAcell{ll};
            end
            
            % single plotting 
            Y_predict_CI = makePrediction(AnParam, post_samples, ll, myPCE, PCA, kk);
            if  isnumeric(gtarray)
                Y_predict_gt = makePrediction(AnParam, gtarray, ll, myPCE, PCA, kk);
            else
                Y_predict_gt = 'Null';
            end

            Y_predict_MAP = makePrediction(AnParam, [Posterior{jj}.MAP], ll, myPCE, PCA, kk);

  
            FE_pred_summary = horzcat(FE_pred_summary,Y_predict_CI);

            % h_obs,h_gt,h_MAP plotting for scalar predictive outputs
            %Two types of plotting can be chosen:"stageNumber" or "stageValue"
            varCelltemp5 = {AnParam,ll,jj,kk,observationsarray,gtarray, ...
                                    Y_predict_gt,Y_predict_MAP,observation_stageTime};
            [h_gt,h_obs,h_MAP] = MAP_GT_Obs_predictive(varCelltemp5);


        end

        %box plotting for FE prediction
        %Two types of plotting can be chosen:"stageNumber" or "stageValue"
        %Note: This switch cannot be merged with above one-different loop
        hold on;
        Boxplot(FE_pred_summary,kk,observation_stageTime,jj);

		
        %add legend for FE scalar predictive output
        Addlegend(h_gt,h_obs,h_MAP);

        % export scalar outputs figs if required
        figureExportPredictive(jj,kk,path_savedFigure,fig_S,AnParam,'posteriorPredictive');

    end
        
end

%cutting line for output in matlab live script
disp(['<strong>Analysis for Stage ' num2str(jj) ' is finished!<strong>'])
disp('╔═══╗───────╔╗──────╔╗');
disp('║╔══╝───────║║──────║║');
disp('║╚══╦╦═╗╔╦══╣╚═╦══╦═╝║');
disp('║╔══╬╣╔╗╬╣══╣╔╗║║═╣╔╗║');
disp('║║──║║║║║╠══║║║║║═╣╚╝║');
disp('╚╝──╚╩╝╚╩╩══╩╝╚╩══╩══╝');
disp(['==========================================================================' ...
    '============================================================================']);
hold off;


end






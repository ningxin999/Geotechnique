function [h_gt,h_obs,h_MAP] = MAP_GT_Obs_predictive(varCell)
%ADDME: Include [h_obs,h_gt,h_MAP] predictions into 
%       the prior/posterior predictive  figures created above 


%Input: varCell-input parameters assembled previously as a cell
%       Prior predictive inputs: [AnParam,ll,kk,observationsarray,gtarray, Y_predict_gt,observation_stageTime]
%       Posterior predictive inputs: [AnParam,ll,jj,kk,observationsarray,gtarray,
%                                       Y_predict_gt,Y_predict_MAP,observation_stageTime]



%count the how many components in the cell
N_cell = size(varCell,2);

%=====================================================================
%=====================Two cases=======================================

switch N_cell

    % =====================================================================
    % =============Case one-Prior predicive================================
    case 7
    
        %Prior predicive doesnot have observations and MAP
        h_MAP = "Null";
    
    
        %Gather out input paramters from the cell
        [AnParam,ll,kk,observationsarray,gtarray, Y_predict_gt,observation_stageTime] = varCell{1:N_cell};
    
    
        hold on; 
        %plot observation if it exists
        %ploting observation to current time jj
        if ~anynan(observationsarray{kk}(:,ll))
        h_obs = scatter(observation_stageTime(ll),observationsarray{kk}(:,ll),80,'blue','x','LineWidth',1.5);  
        end
        
        % plot ground truth predictive FE if gtarray exists
        if isnumeric(gtarray)
        h_gt = scatter(observation_stageTime(ll),Y_predict_gt,80,'black','x','LineWidth',1.5);
        else
        h_gt = 'Null';
        end
            



    % =====================================================================
    % =============Case one-Predictive predicive===========================
    case 9
        
        %Gather out input paramters from the cell
        [AnParam,ll,jj,kk,observationsarray,gtarray,Y_predict_gt,Y_predict_MAP,observation_stageTime] = varCell{1:N_cell};
           
	    hold on; 
	    %plot observation if it exists
	    %ploting observation to current time jj
    
        if ~anynan(observationsarray{kk}(:,ll))
            if ll <= jj
            h_obs = scatter(observation_stageTime(ll),observationsarray{kk}(:,ll),80,'blue','x','LineWidth',1.5); 
            end
            h_obs = plot(nan, 'b-x');%empty plotting just for legend preparation
        else
            h_obs = 'Null';  
        end

	    
	    % plot ground truth predictive FE if gtarray exists
        if isnumeric(gtarray)
            h_gt = scatter(observation_stageTime(ll),Y_predict_gt,80,'black','x','LineWidth',1.5);
        else
            h_gt = 'Null'; 
        end
    
	    % plot MAP predictive FE 
	    h_MAP = scatter(observation_stageTime(ll),Y_predict_MAP,80,'red','o','LineWidth',1.5);

			
end






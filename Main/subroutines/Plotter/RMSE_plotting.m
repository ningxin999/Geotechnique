function RMSE_plotting(BayesAnalysis,AnParam,jj,myPCE,PCA,EDarray,observationsarray,gtarray,N_mesh)

%AddME: plotting Response surface/root mean square error for 1D or 2D 
%       To see: (1) if surrogate model contructed has multiple solutions except ground 
%       truth. (2) to ensure MAP is consistent with the lowest point with RMSE



% Input:    BayesAnalysis: output structure to extract MAP
%           AnParam: AnParam structure
%           jj: jj-th stage
%           myPCE: PCE structure on PCs space at jj-th stage for kk-th output field
%           PCA: PCA structure at jj-th stage for kk-th output field
%           EDarray: experiment of design
%           observationsarray: obesrvation at jj-th stage for kk-th output field
%           gtarray: ground truth array if it exists
%           N_mesh: mesh points to be divided


%% if there are N_Exp sets of observationsarray, take avaerage
observationsarraytemp = {};
for vv = 1: AnParam.N_outputfields
    for pp = 1:AnParam.N_Obs_stage  
    tempObs_Exp = reshape(observationsarray{vv}(:,pp),[],AnParam.N_Exp);
    tempObs_Exp_average = mean(tempObs_Exp,2);
    observationsarraytemp{vv}(:,pp) = tempObs_Exp_average;
    end

end

observationsarray = observationsarraytemp;



%% tell the switch for RMSE plotting is "1D" or "2D" or "off"
    % RMSE plotting doesnot exist if gtarray is not existing
    if  ( AnParam.Switch_RMSE =="1D" || AnParam.Switch_RMSE =="2D" ) &&  isnumeric(gtarray)
        % do nothing and continue    
    else
        warning(['No ground truth file available or RMSE switch is not open,' ...
                ' RMSE plotting is not supported!!!']);
        return;
    end


    %% create new folders to save figs
    % get the full path to create a 'savedResults' folder         
    path_savedFigure = fullfile(pwd(), 'savedResults'); 
    
    % create new empty file 'savedResults';
    % Switch_Predict_prior is 'off'
    if isfolder(path_savedFigure) == 0        
        mkdir(path_savedFigure);
    end



    %% Burn in 70% for BayesAnalysis
    % Extract samples from the BayesAnalysis strcuture and calculate the MAP
    % kernel density (wrong answer, right answer should be MAP in UQLAB)
    % MAP_parameters = [];
    % uq_postProcessInversionMCMC(BayesAnalysis,'burnin',0.7);
    % for ll = 1: AnParam.N_parameters                
    %     temp =  BayesAnalysis.Results.PostProc.PostSample(:,ll,:);
    %     Post_samples = reshape(permute(temp, [2 1 3]), size(temp, 2), [])';
    %     %calculate the MAP
    %     [f,xi] = ksdensity(Post_samples);
    %     [~,index_id] = max(f);
    %     MAP_parameters = [MAP_parameters xi(index_id)];
    % end   
    uq_postProcessInversionMCMC(BayesAnalysis,'pointEstimate','MAP','burnin',0.7);
    MAP_parameters = BayesAnalysis.Results.PostProc.PointEstimate.X{:}(1:AnParam.N_parameters);


    %loop to RMSE plotting for the different output fields
    for kk = 1:AnParam.N_outputfields    
        %if observationsarray for kk-th outputfield at jj-th stage is empty. No Bayesian inference
        %involved. No need to plot RMSE
        if isnan(observationsarray{kk}(:,jj)) 
            warning(['When plotting RSM-response surface for outputfield ', ...
                    num2str(kk),', no observation for this stage!!']);
            continue;       
        end


        % RMSE figures plotting
        [h_gt, h_MAP,fig] = single_plot(EDarray,N_mesh,gtarray,myPCE{1,kk},PCA{1,kk},kk,jj, ...
                                    observationsarray,AnParam,MAP_parameters);


  
        %sgtitle for RSM plotting
        title_name = ['Response surface - RMSE for outputfield ' num2str(kk) ' - Stage ' num2str(jj)];
        sgtitle(title_name,'fontweight','bold','FontSize',11);  
        Lgnd = legend([ h_gt h_MAP ],{  'Ground truth','MAP'},'FontSize',10,'Location',...
                                        'NorthOutside','Orientation','Horizontal') ;
        Lgnd.Layout.Tile = 'North'; 


        %% saving figs or display figures
        outputfolder = fullfile(path_savedFigure,'RMSE');
        if isfolder(outputfolder) == 0
            mkdir(outputfolder);
        end
      
        %Name and export figures 
        filename = ['Stage' num2str(jj) AnParam.figsExport];
        filepath  = fullfile(outputfolder,filename);
        exportgraphics(fig,filepath,...
                   'BackgroundColor','white','Resolution',300);


    end




end




function [h_gt, h_MAP,fig] = single_plot(EDarray,N_mesh,gtarray,myPCE,PCA,kk,jj, ...
                                    observationsarray,AnParam,MAP_parameters)

%ADDME: single plot for different patterns RMSE "1D" or "2D"
% Choose which pattern RMSE we should use. 2D mesh is expensive but
% figures are pretty; 1D is simple, but quick

%figure handle creating
fig = figure('visible','off');




% "1D" RMSE plotting
if AnParam.Switch_RMSE == "1D"
    
    % create a empty figure to restore all subplots for all
    % possible model parameters RMSE combinations
    % and set tilelayout style
    t = tiledlayout('flow','TileSpacing',"tight"); 
    
    %loop to plot all subplots for  all possible model parameters combinations   
    for qq = 1:size(EDarray,2)   
        %begin plotting                       
        nexttile(t);
    
        % assign variable numbers
        N_var = qq;            
        
        % find the boundary for expermental design
        LB = min(EDarray(:,N_var));
        UB = max(EDarray(:,N_var));

        % divide the space range into N_mesh points and mesh
        Space = linspace(LB, UB, N_mesh)';

        %prepare EoD  mesh for calculation 
        EoD_mesh  = repmat(gtarray,N_mesh,1);   
        EoD_mesh(:,N_var)= Space;                
        
        %Calculate the FE output using surrogate constructed (with/without DR)
        if AnParam.DR == "on"
            % make prediction YPCE for PCs 
            if AnParam.Surrogate == "custom"
            temp = custom_predict(EoD_mesh, myPCE.psin, myPCE.psout, myPCE.lstmnet);
            FE_output = temp(:,AnParam.jj);
            else
            PCA_PCE =  uq_evalModel(myPCE,EoD_mesh);    
            % reconstruct the output        
            FE_output = PCA_PCE * PCA.V(:, 1:PCA.number)' + PCA.mv;
            end
    
        else
            FE_output =  uq_evalModel(myPCE,EoD_mesh);
        end

        %%calculate the  Residual 
        observation = observationsarray{kk}(:,jj)';
        expNum = size(observation,1);% experiment number  N
        Npoint = size(observation,2);% number of z [z1,z2,...,z28,z29]
        Residual = []; % intitail value for Residual
        ResidualSum = [];% intitail value for ResidualSum
        error=(observation - FE_output).^2;
        Residual =sum(error,2);

        %Divide the number of experiment expNum  and monitored points
        ResidualSum = log(sum(Residual,2)/expNum/Npoint);
     

        %plot the response surface for True    
        hold on;
        plot(Space,ResidualSum,'--','linewidth',2);

        %plot ground truth
        X_gt = gtarray(N_var);
        h_gt = xline(X_gt,'--k','linewidth',1);

        %plot MAP
        X_MAP = MAP_parameters(N_var);
        h_MAP =  xline(X_MAP,'--r','linewidth',1);

        labelx = AnParam.Name{N_var};
        xlabel(labelx);ylabel('Residual');   
        %set(gca,'ygrid','on','gridlinestyle','--','Gridalpha',0.4);                                
        grid on; 
        hold off;            
    end
end



% "2D" RMSE plotting
if AnParam.Switch_RMSE == "2D" 
    %nchoosek to get all possible figures
    list =1:size(EDarray,2);
    list_all = nchoosek(list,2);
    
    % create a empty figure to restore all subplots for all
    % possible model parameters RMSE combinations
    % and set tilelayout style
    t = tiledlayout('flow','TileSpacing',"tight"); 
    
    %loop to plot all subplots for  all possible model parameters combinations   
    for qq = 1:size(list_all,1)    
        %begin plotting                       
        nexttile(t);
    
        % assign variable numbers
            N_var1 = list_all(qq,1);
            N_var2 = list_all(qq,2);

        % find the boundary for expermental design
            LB_1 = min(EDarray(:,N_var1));
            LB_2 = min(EDarray(:,N_var2));
            UB_1 =  max(EDarray(:,N_var1));
            UB_2 =  max(EDarray(:,N_var2));

        % divide the space range into N_mesh points and mesh
            Space_1 = linspace(LB_1, UB_1, N_mesh);
            Space_2 = linspace(LB_2, UB_2, N_mesh);
            [Space_1_grid, Space_2_grid]=meshgrid(Space_1,Space_2); 
        
        %prepare EoD  mesh for calculation 
            EoD_mesh  = repmat(gtarray,N_mesh*N_mesh,1);
            Space_1_grid_reshape = reshape(Space_1_grid,[],1);
            Space_2_grid_reshape = reshape(Space_2_grid,[],1);
            EoD_mesh(:,N_var1)= Space_1_grid_reshape;
            EoD_mesh(:,N_var2)= Space_2_grid_reshape;

        %Calculate the FE output using surrogate constructed (with/without DR) 
        if AnParam.DR == "on"
            % make prediction YPCE for PCs 
            if AnParam.Surrogate == "custom"
            temp = custom_predict(EoD_mesh, myPCE.psin, myPCE.psout, myPCE.lstmnet);
            FE_output = temp(:,AnParam.jj);
            else
            PCA_PCE =  uq_evalModel(myPCE,EoD_mesh);    
            % reconstruct the output        
            FE_output = PCA_PCE * PCA.V(:, 1:PCA.number)' + PCA.mv;
            end
    
        else
            FE_output =  uq_evalModel(myPCE,EoD_mesh);
        end


        %%calculate the  Residual 
            observation = observationsarray{kk}(:,jj)';
            expNum = size(observation,1);% experiment number  N
            Npoint = size(observation,2);% number of z [z1,z2,...,z28,z29]
            Residual = []; % intitail value for Residual
            ResidualSum = [];% intitail value for ResidualSum
            error=(observation - FE_output).^2;
            Residual(:,1) =sum(error,2);

        %Divide the number of experiment expNum  and monitored points
            ResidualSum(:,1) = log(sum(Residual(:,1),2)/expNum/Npoint);
            row = size(Space_1_grid,1);
            col = size(Space_1_grid,2);
            ResidualSum = reshape(ResidualSum,row,col);

        %plot the response surface for True    
            hold on;
            mesh(Space_1_grid,Space_2_grid,ResidualSum);
            colorbar;
            X_gt = [gtarray(N_var1);gtarray(N_var1)];
            Y_gt = [gtarray(N_var2);gtarray(N_var2)];
            Z_gt =  [min(ResidualSum,[],'all');max(ResidualSum,[],'all')];
            h_gt = plot3(X_gt,Y_gt,Z_gt,'--kx');
    
            X_MAP = [MAP_parameters(N_var1);MAP_parameters(N_var1)];
            Y_MAP = [MAP_parameters(N_var2);MAP_parameters(N_var2)];
            Z_MAP =  [min(ResidualSum,[],'all');max(ResidualSum,[],'all')];
            h_MAP =  plot3(X_MAP,Y_MAP,Z_MAP,'--ro');
    
            labelx = AnParam.Name{N_var1};
            labely = AnParam.Name{N_var2};
            xlabel(labelx);ylabel(labely);zlabel('Residual');
            set(gca,'ygrid','on','gridlinestyle','--','Gridalpha',0.4);
            view([140 30]);
            grid on;
            hold off;            
    end

end


end

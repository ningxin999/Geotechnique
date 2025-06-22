function Sobol_indices_plotting(AnParam, jj,observation_stageTime,observationcoord,myPCEcell,PCAcell)
%ADDME: plotting sobol's indice temporal and spatially
%       Two cases exists: (1) scalar output changing with stage (2) vector
%       output changing with stage and coordination 

%Input:   AnParam: Analysis structure with parameters 
%         FEcell_output_interp: FE output after fitting with observation 
%         EDarray: experimental design
%         jj: jj-th stage
%         observation_stageTime: within the FE stage time
%         observationcoord： spatial coordination 
%         myPCEcell,PCAcell: pretrained surrogate

%Output: No output required(plotting sobol figures)

% note: kk -- the number of outputfield
%       jj-- the number of stage
%       ll-- the number of current working stage

    %create new folders to save figs
    % get the full path to create a 'savedResults' folder         
    path_savedFigure = fullfile(pwd(), 'savedResults'); 

    % tell if the switch for sobol plotting is on or not 
    % only plot /export this at stage one
    if AnParam.Switch_Sobol == "on" &  jj == 1
        % ==================================================Plot Vector/Scalar output ===============================
        %=================================================================================================
        for kk = 1:AnParam.N_outputfields
            % to see the observation vector or scalar
            if isscalar(observationcoord{kk})
                plot_sobol_scalar(AnParam, observation_stageTime,path_savedFigure,kk,myPCEcell,PCAcell);
            else
                plot_sobol_vector(AnParam, observationcoord,path_savedFigure,kk,myPCEcell,PCAcell);
            end
    
        end
    end





end





%% function to plot/export sobol_vector
function Y = plot_sobol_vector(AnParam, observationcoord,path_savedFigure,kk,myPCEcell,PCAcell)
% Addme: plot vector sobol
% Input: AnParam, FEcell_output_interp,EDarray,observationcoord,path_savedFigure
% Output: No output

%No output required
Y = 'Null';

    % Loop to plot sobol figures for different outputfields
    %define a empty cell to restore all the sobol's indices results
    %for loop starting figures plotting

    % get all stages sobols indices for single outputfield    
    for ll =1 : AnParam.N_Obs_stage 
        % call the PCEPCA structure trained for FE prediction
        myPCE = myPCEcell{ll};PCA  = PCAcell{ll};

        % since sobol indice for PCEPCA/PCE is diffferent, we need use two
        % cases: (1) Sobol for PCEPCA; (2) Sobol for PCE                    
        fig = figure('visible','off');%figure handle creating
        if AnParam.DR == "on"
            % create myMdl structure to save the PCA and PCE indices prepared
            % for sobol plotting
            myMdl = [];
            myMdl.PCA.T = PCA{1, kk}.V(:,1:PCA{1, kk}.number);% prepare the PCA score
            myMdl.PCE = myPCE{1, kk};% prepare the PCE model
                % calculate the total sobol and normalized to 0-1
            tic
            [S_tot,~]=uq_PCA_Sobol(myMdl);
            toc
        else
            S_tot = PCA{1, kk}.sobol_indice.Results.Total';
        end
        %nomalized the S_tot to 1.0
        S_tot = S_tot./sum(S_tot,2);


        %area plotting
        area(observationcoord{kk},S_tot,'FaceAlpha',0.7,'EdgeAlpha',1.0);% area plotting
        xlim([min(observationcoord{kk}) max(observationcoord{kk})]);ylim([0 1]);
       
        %lengend and title plotting 
        title_name = ['Outputfield '  num2str(kk) '-stage' num2str(ll)]; %title(title_name);
        lg_name = AnParam.Name;legend(lg_name,'Location','northeastoutside','Interpreter','latex');
        pbaspect([1 0.75 0.02]);box on; grid on;
        %color default ordering for first 6 parameters following
        %Wagner's color scheme
        newcolors = [139 213 244
                     166 201 120
                     170 119 180
                     89 163 212
                     243 204 110
                     230 143 105
                     255 127 80    % Coral
                     60 179 113    % Medium Sea Green
                     255 105 180   % Hot Pink
                     72 61 139     % Dark Slate Blue
                     240 128 128   % Light Coral
                     255 165 0     % Orange
                    ] ./ 256;                    
        colororder(newcolors);
 
    % 🎨 Beautify Axis Labels
    xlabel('Depth (m)', 'Interpreter', 'latex', 'FontSize', 16, 'FontWeight', 'normal', 'Color', 'k');
    ylabel('Normalized total Sobol', 'Interpreter', 'latex', 'FontSize', 16, 'FontWeight', 'normal', 'Color', 'k');
    
    % 🎨 Improve Axis Appearance
    ax = gca; % Get current axis
    set(ax, 'FontSize', 16, 'FontWeight', 'normal', 'LineWidth', 1.0); % General axis styling
    set(ax.XAxis, 'Color', 'k', 'TickLength', [0.02 0.02], 'LineWidth', 1.0); % X-axis
    set(ax.YAxis, 'Color', 'k', 'TickLength', [0.02 0.02], 'LineWidth', 1.0); % Y-axis
    
    % 🏗️ Add Grid, Box & Aspect Ratio
    grid on; box on; % Ensure both are visible
    
    % 🎨 Fine-tune Tick Labels
    ax.XMinorTick = 'on'; % Enable minor ticks
    ax.YMinorTick = 'on';
    ax.TickDir = 'in'; % Make ticks point outward for a cleaner look
    ax.XColor = 'k'; % Set tick color
    ax.YColor = 'k';
    ax.YRuler.Exponent = 0;



    % saving figs or display figures  % Create kk-th outputfield folder
    outputfolder = fullfile(path_savedFigure,'Sobol',['outputfield' num2str(kk)]);
    if isfolder(outputfolder) == 0
        mkdir(outputfolder);
    end
  
    %Name and export figures 
    filename = ['Outputfield' num2str(kk)  '-stage' num2str(ll) AnParam.figsExport ];
    filepath  = fullfile(outputfolder,filename);
    exportgraphics(fig,filepath,...
               'BackgroundColor','white','Resolution',1200);
    end



end


%% function to plot/export sobol_scalr
function Y = plot_sobol_scalar(AnParam, observation_stageTime,path_savedFigure,kk,myPCEcell,PCAcell)
% Addme: plot scalar sobol
% Input: AnParam, FEcell_output_interp,EDarray,observation_stageTime,path_savedFigure
% Output: No output

%No output required
Y = 'Null';

    Sobol_summary = {};%define a empty cell to restore all the sobol's indices results


    %create a empty list to restore single outputfield sobol's results
    Sobol_single = [];
    % get all stages sobols indices for single outputfield    
    for ll =1 : AnParam.N_Obs_stage 
        % call the PCEPCA structure trained for FE prediction
        myPCE = myPCEcell{ll};PCA  = PCAcell{ll};
        extract_sobol = PCA{kk}.sobol_indice.Results.Total(:,1);%extract sobol only for first PC
                                                                     % (Note: this procedure disgards the rest PCs. Not good choice)
        extract_sobol = extract_sobol./sum(extract_sobol);%normalize the sobol indices into one
        Sobol_single = horzcat(Sobol_single,extract_sobol);% horizontal concatenate
    end

    %figure handle creating
    fig = figure('visible','off');

    
    Sobol_summary{kk} = (Sobol_single);
    %note the area function format in matlab should be :
    %           Sobol index for parameter one 	Sobol index for parameter two 	…
    % stage 1	            0.2	                                0.5	            …
    % stage 2	            0.2	                                0.6	            …
    % stage 3	            0.3	                                0.5         	…

    %area plotting
    area(observation_stageTime,Sobol_summary{kk}','FaceAlpha',0.7,'EdgeAlpha',1.0);% area plotting
    ax = gca;
    ax.XTick = observation_stageTime;
    xlim([min(observation_stageTime) max(observation_stageTime)]);ylim([0 1]);
    xtickangle(45);
    XLabel_cell=num2cell(observation_stageTime);
    Xlabel_name=cellfun(@num2str,XLabel_cell,'un',0);
    set(gca,'XTickLabel',Xlabel_name);% change x label to stage time        

    %label and limit                    
    xlabel('Stage'); ylabel('Normalized total indices');

    %lengend and title plotting 
    title_name = ['Outputfield '  num2str(kk)];
    lg_name = AnParam.Name; legend(lg_name,'Location','northeastoutside','Interpreter','latex');
    pbaspect([1 0.75 0.02]); box on; grid on;
    %color default ordering for first 6 parameters following
    %Wagner's color scheme
        newcolors = [139 213 244
                     166 201 120
                     170 119 180
                     89 163 212
                     243 204 110
                     230 143 105
                     255 127 80    % Coral
                     60 179 113    % Medium Sea Green
                     255 105 180   % Hot Pink
                     72 61 139     % Dark Slate Blue
                     240 128 128   % Light Coral
                     255 165 0     % Orange
                    ] ./ 256;                      
    colororder(newcolors);
    % 🎨 Beautify Axis Labels
    xlabel('Stage', 'Interpreter', 'latex', 'FontSize', 16, 'FontWeight', 'normal', 'Color', 'k');
    ylabel('Normalized total Sobol', 'Interpreter', 'latex', 'FontSize', 16, 'FontWeight', 'normal', 'Color', 'k');
    
    % 🎨 Improve Axis Appearance
    ax = gca; % Get current axis
    set(ax, 'FontSize', 16, 'FontWeight', 'normal', 'LineWidth', 1.0); % General axis styling
    set(ax.XAxis, 'Color', 'k', 'TickLength', [0.02 0.02], 'LineWidth', 1.0); % X-axis
    set(ax.YAxis, 'Color', 'k', 'TickLength', [0.02 0.02], 'LineWidth', 1.0); % Y-axis
    
    % 🏗️ Add Grid, Box & Aspect Ratio
    grid on; box on; % Ensure both are visible
    
    % 🎨 Fine-tune Tick Labels
    ax.XMinorTick = 'on'; % Enable minor ticks
    ax.YMinorTick = 'on';
    ax.TickDir = 'in'; % Make ticks point outward for a cleaner look
    ax.XColor = 'k'; % Set tick color
    ax.YColor = 'k';
    ax.YRuler.Exponent = 0;
    %saving figs or display figures    % Create kk-th outputfield folder
        outputfolder = fullfile(path_savedFigure,'Sobol',['outputfield' num2str(kk)]);
        if isfolder(outputfolder) == 0
            mkdir(outputfolder);
        end
      
        %Name and export figures 
        filename = ['Outputfield' num2str(kk) AnParam.figsExport ];
        filepath  = fullfile(outputfolder,filename);
        exportgraphics(fig,filepath,...
                   'BackgroundColor','white','Resolution',1200);



end





function cornerplot_scatter(Prior_forward,Posterior,gtarray,jj,AnParam,myPriorDist)
%ADDME: Plot the all posterior figures at jj-th stage against prior
%       sampling. Also denote the MAP and ground truth (if exist)
%       If jj <-- 1, plot the initial plotting against prior
%       If jj <--2, 3, 4,... plot the subsequet against posterior j-1
%       Note: initial plotting is based on initial priors, subsequent 
%       plotting prior is based on inference from last posterior

%Input: Posterior: Posterior at 1st-jjth stages
%       jj: jj-th stage
%       gtarray: ground truth array
%       myPriorDist: prior structure. only used for initial sampling,
%                    because since jj = 2, the prior is the posterior from 1st stage
%       Prior_forward: experimental design struct


%% create new folders to save figs
% get the full path to create a 'savedResults' folder         
path_savedFigure = fullfile(pwd(), 'savedResults');
if isfolder(path_savedFigure) == 0
    mkdir(path_savedFigure);
end



%% create empty figure f_handle to store all subplots
fig_sum = figure('visible','off','Position', [1, 1, 1000, 1000]);


%%
%choose which pattern to plot: initial plotting or subsequent posterior plotting
switch nargin 

    %initial plotting
    %============================================================================
    %===========================jj = 1 ==========================================
    case 6   
        
        %get the number of inferred parameters of concerned 
        N_parameters = size(Posterior{jj},2);        
        
        %extract all smaples from posterior (after 70% burn-in, the left samples) at jj-th stage
        Post_samples = cell2mat({Posterior{jj}(:).samples});    

        %get the prior samples   
        uq_selectInput(myPriorDist)%select input prior
        Prior_samples = uq_getSample(size(Post_samples,1),'LHS');
        Prior_samples = Prior_samples(:,1:N_parameters);


    %subsequent posterior plotting
    %============================================================================
    %===========================jj = 2, 3, 4, ... ===============================
    case 5        
        %get the number of inferred parameters of concerned 
        N_parameters = size(Posterior{jj},2);        
        
        %extract all smaples from jj-th and jj-1 posterior (after 70% burn-in, the left samples) at jj-th stage
        Post_samples = cell2mat({Posterior{jj}(:).samples});
        Prior_samples = cell2mat({Posterior{jj-1}(:).samples});    
end
%% begin plotting: histogram + corner posterior
%set the limitation for plot based on the prior forward
lowerLim = {Prior_forward(:).parameter1};
upperLim = {Prior_forward(:).parameter2};

%extract all MAP of the posterior at jj-th stage
MAP_parameters = cell2mat({Posterior{jj}(:).MAP});

%initialize counting plotting number
N_plot = 0;

% calculate the lower triangle index tilelayout
% create handle
f_handle = tiledlayout(N_parameters,N_parameters,'Padding','loose','TileSpacing','none');

% for loop for subplot 
for ii = 1:N_parameters % ii-th row
    for kk = 1: N_parameters % kk-th column
        

        if ii == kk % histogram plotting
            %create subplot empty space
            %N_plot = N_plot +1;
            %f_handle = subplot(N_parameters,N_parameters,N_plot);
            nexttile(f_handle,N_parameters*(ii-1)+ii); 
            
            

            %histogram plotting
            h_prior = histogram(Prior_samples(:,ii),40, 'FaceColor','black','normalization', 'probability', 'edgecolor', 'black');
            hold on;
            h_post = histogram(Post_samples(:,ii), 40, 'FaceColor',[78 94 247]./256,'normalization', 'probability',  'edgecolor', [78 94 247]./256);
            
            % add ground truth
            if isnumeric(gtarray)
                h_gt = xline(gtarray(ii),'--k','LineWidth',1);
            end 

            %add the MAP 
            xline(MAP_parameters(ii),'--r','LineWidth',1);

            hold off;

            % set limit for x-axis
            xlim([lowerLim{ii} upperLim{ii}]);
            axis normal;
            xtickangle(0);ytickangle(0);
            % ax = gca;
            % if ii ==3
            %     ax.YAxis.Exponent = 5;ax.XAxis.Exponent = 5;
            % end            
            xtickangle(45);ytickangle(45);set(gca,'xtick',[]);set(gca,'ytick',[]);

        elseif ii > kk% scatter plotting 
            %create subplot empty space
            %N_plot = N_plot +1;
            %f_handle = subplot(N_parameters,N_parameters,N_plot); 
            nexttile(f_handle,N_parameters*(ii-1)+kk); 
      
            %scatter plotting (including the ground truth and MAP)
            dscatter(Post_samples(:,kk),Post_samples(:,ii)); 
            freezeColors;
            hold on;
            %colormap([200 200 198]./256);
            brighten(0.01);
            %dscatter(Prior_samples(:,kk),Prior_samples(:,ii)); 
            scatter(Prior_samples(:,kk),Prior_samples(:,ii),10,'MarkerFaceColor', ...
                    [200 200 198]./256,'MarkerEdgeColor',[200 200 198]./256,'MarkerFaceAlpha',.1,'LineWidth',1e-10);
            %put the posterior plotting at the top layer                
            h = get(gca,'Children');set(gca,'Children',[h(2) h(1)]);
                          
            % scatter ground truth
            if isnumeric(gtarray)
                xline(gtarray(kk),'--k','LineWidth',1);% scatter ground truth
                yline(gtarray(ii),'--k','LineWidth',1);% scatter ground truth
            end

            % scatter MAP of the posterior
            scatter(MAP_parameters(kk),MAP_parameters(ii),50,'o','MarkerEdgeColor','red','LineWidth',1.5);  
            h_MAP = plot(nan,50, 'r--o');%empty plotting just for legend preparation
            box on;  
            % add limitation for x-axis and y-axis
            xlim([lowerLim{kk} upperLim{kk}]);
            ylim([lowerLim{ii} upperLim{ii}]);
            hold off;axis normal;
            % ax = gca;
            % if ii ==3 & kk == 1
            %     ax.YAxis.Exponent = 5;ax.XAxis.Exponent = 0;
            % end            
            xtickangle(45);ytickangle(45);set(gca,'xtick',[]);set(gca,'ytick',[]);
          

            % Low triangle subplot, make upper triangle plots invisible
            % if ii < kk
            %     set(f_handle,'Visible','off');
            %     set( get(f_handle,'Children'),'Visible','off');
            % end    
        end


        %label setting for corner plot
        if ii >= kk 
            % Add variable names to the left or bottom of the figure
            ylabelText = Prior_forward(ii).Input_name;
            xlabelText = Prior_forward(kk).Input_name;

            % Set the left-side label
            ylabel(texlabel(ylabelText), 'FontSize',25,'FontWeight', 'bold', 'Visible', kk == 1,'interpreter','latex');

            % Set the bottom label
            xlabel(texlabel(xlabelText), 'FontSize',25,'FontWeight', 'bold', 'Visible', ii == N_parameters,'interpreter','latex');

            % Hide unnecessary tick labels
            if kk ~= 1
                set(gca, 'YTickLabel', []);
            end
            if ii ~= N_parameters
                set(gca, 'XTickLabel', []);
            end
            if ii ==1 & kk ==1
                set(gca, 'YTickLabel', []);
                ylabel('');
            end

        end


    end
end


%legend for histogram, MAP and ground truth
if isnumeric(gtarray)
   Lgnd = legend([ h_prior h_post  h_MAP h_gt ],{  'prior $\pi(x)$','posterior $\pi(x|\mathcal{G})$','$x^{MAP}$', 'Ground truth'},'FontSize',25,'Interpreter','latex') ;
else       
   Lgnd = legend([h_prior h_post h_MAP],{'prior $\pi(x)$','posterior $\pi(x|\mathcal{G})$','$x^{\mathrm{MAP}}$'},'FontSize',25,'Interpreter','latex') ;
end
Lgnd.Position(1) = 0.62;
Lgnd.Position(2) = 0.75;
%set(gcf, 'Position', get(0, 'Screensize'));

%% saving figs or display figures
outputfolder = fullfile(path_savedFigure,'Cornerplot');
if isfolder(outputfolder) == 0
    mkdir(outputfolder);
end

%Name and export figures 
filename = ['Stage' num2str(jj) AnParam.figsExport];
filepath  = fullfile(outputfolder,filename);
exportgraphics(fig_sum,filepath,...
           'BackgroundColor','white','Resolution',300);


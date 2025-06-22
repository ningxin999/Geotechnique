
function Y = train_Surrogate_plotter(AnParam,N_train,  YPCE, FEoutput, kk, jj)  
% ADDME  Plot PCAPCE training surrogate error: Ysurrogate vs Yoriginal
%
% Inputs:   kk: kk-th outputfield
%           N_train: training run number
%           PCE_train_dataset: training dataset
%           jj: jj-th (loading) stage
%           FEoutput: Original outputs Y
 
%plotting Yval vs YPCE 
close all;fig = figure('visible','off');
Y_pred = YPCE; Y_test = FEoutput{kk}{:,jj}(1:N_train,:);
plotregression(Y_test, Y_pred,'Training error');
ax = gca; % Get current axis
hold on;

% 🎨 Beautify labels
xlabel('True Values', 'FontSize', 16, 'FontWeight', 'bold', ...
    'Color', 'k', 'Interpreter', 'latex');
ylabel('Predicted Values', 'FontSize', 16, 'FontWeight', 'bold', ...
    'Color', 'k', 'Interpreter', 'latex');

% 🎨 Enhance plot aesthetics
set(ax, 'FontSize', 14, 'LineWidth', 1.0, 'Box', 'on'); % Improve axis
set(findall(ax, 'Type', 'Line'), 'LineWidth', 1.0); % Make lines bolder
set(findall(ax, 'Type', 'Text'), 'FontSize', 14, 'FontWeight', 'normal','FontWeight', 'normal'); % Improve text clarity
grid on; % Enable grid
colormap(turbo); % Use a modern colormap
hold off;  


% get the full path to create a 'savedResults' folder         
outputfolder = fullfile(pwd(),'trained_surrogate','Train_error');
if isfolder(outputfolder) == 0
    mkdir(outputfolder);
end

%Name and export figures 
filename = ['Stage' num2str(jj)  'Outputfield' num2str(kk) AnParam.figsExport ];
filepath  = fullfile(outputfolder,filename);
exportgraphics(fig,filepath,...
           'BackgroundColor','white','Resolution',300);


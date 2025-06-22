
function PCA_reconstruct_plotter(AnParam,PCA, kk,PCE_train_dataset,jj)  
% PCA_RECONSTRUCT_PLOTTER - Plots PCA reconstruction against original data and saves figure
%
% Inputs:
%   AnParam           - Analysis parameters struct (must contain figsExport field)
%   PCA               - PCA struct array (must contain score, V, mv, number fields)
%   kk                - Output field index (positive integer)
%   PCE_train_dataset - Original training data matrix
%   jj                - Stage number (positive integer)


% Reconstruct data to original space
PCA_reconstructed = PCA{kk}.score(:, 1:PCA{kk}.number) * ...
                   PCA{kk}.V(:, 1:PCA{kk}.number)' + ...
                   PCA{kk}.mv;       
%plotting   
close all;fig = figure('visible','off');hold on;
plotregression(PCE_train_dataset,PCA_reconstructed,'PCA reconstruction loss');
hold off; pbaspect([1 0.75 0.02]);box on; grid on;

%export the figs
% get the full path to create a 'savedResults' folder         
outputfolder = fullfile(pwd(), 'trained_surrogate', 'Reconstr');
if isfolder(outputfolder) == 0
    mkdir(outputfolder);
end

%Name and export figures 
filename = ['Stage' num2str(jj)  'Outputfield' num2str(kk) AnParam.figsExport ];
filepath  = fullfile(outputfolder,filename);
exportgraphics(fig,filepath,...
           'BackgroundColor','white','Resolution',300);



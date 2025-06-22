function figureExportPredictive(varargin)
% FIGUREEXPORTPREDICTIVE Export figure functions for prior/posterior predictions
%   Inputs:
%       - kk: kk-th outputfield number
%       - path_savedFigure: path to folder 'savedFigure'
%       - ll: stage number
%       - fig_save: figure handle
%       - predictive_name: 'prior_Predictive'/'posterior_Predictive'
%       - jj: jj-th stage (for posterior predictive only)
%       - AnParam: AnParam structure
%       - choice_for_predictive: 'priorPredictive'/'posteriorPredictive' (must be last argument)
%
%   Notice: 
%       (1) Handles both scalar output or vector outputs
%       (2) Handles both prior/posterior predictive export

% Common parameters
bgColor = 'white';
resolution = 1200;
choice_for_predictive = varargin{end};

% Switch between prior and posterior predictive
switch choice_for_predictive
    case 'priorPredictive'
        if nargin == 5 % Scalar case
            [kk,path_savedFigure,fig_save,AnParam] = varargin{1:end-1};
            filename = ['Outputfield' num2str(kk) 'Allstages' AnParam.figsExport ];
        elseif nargin == 6 % Vector case
            [kk,path_savedFigure,ll,fig_save,AnParam] = varargin{1:end-1};
            filename = ['Outputfield' num2str(kk) '-' 'Stage' num2str(ll) AnParam.figsExport ];
        end

    case 'posteriorPredictive'
        if  nargin == 6 % Scalar case
            [jj,kk,path_savedFigure,fig_save,AnParam] = varargin{1:end-1};
            filename = ['currentStage' num2str(jj) '-Outputfield' num2str(kk) 'Allstages' AnParam.figsExport ];
        elseif  nargin == 7 % Vector case
            [jj,kk,path_savedFigure,ll,fig_save,AnParam] = varargin{1:end-1};
            filename = ['currentStage' num2str(jj) '-Outputfield' num2str(kk) '-' 'Stage' num2str(ll) AnParam.figsExport ];
        end
end

% Create output folder structure
outputFolder = fullfile(path_savedFigure, choice_for_predictive, ['outputfield' num2str(kk)]);
if ~isfolder(outputFolder)
    mkdir(outputFolder);
end

% Export the figure
filepath = fullfile(outputFolder, filename);
exportgraphics(fig_save, filepath, 'BackgroundColor', bgColor, 'Resolution', resolution);






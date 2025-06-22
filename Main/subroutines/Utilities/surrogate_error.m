function surrogate_error( AnParam, jj, FEoutput,myPCE,experimentaldesign,PCA)
%ADDME: this func is used to calculate the surrogate error and export as
%       .mat file; also this will calculate the YPCE vs Yval using DR or
%       not using DR (export cov heatmap)

%Input:   AnParam-Analysis structure with parameters
%         kk-th:N_outputfields 
%         jj: loading stage number
%         myPCE:structure
%         PCA: structure
%         FEoutput: output QoI
%         experimentaldesign: EoD for input space
%         kk: which outputfield we want to calculate the surrogate error

%Output: No output required
Y = 'Null';

% export the surrogate error if necessary
if AnParam.SE == "on" 
    % continue
else
    return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get the training dataset number
N_test = AnParam.TestDataRun;
N_train = floor(AnParam.TrainDataPerc*(AnParam.N_RUN - N_test));
if AnParam.N_RUN < N_test
    error('Test runs input is more than FE runs, give a smaller test number!');
end


% get the path for the savedResults folder
path_savedFigure = fullfile(pwd(), 'savedResults'); 


%% loop for kk-th outputfield output
% calculate the surrogate error and its COV
for kk = 1: AnParam.N_outputfields
    YFE = FEoutput{kk}{:,jj}(1:N_train,:);
    if AnParam.DR == "on"
        pcagatherout = uq_evalModel(myPCE{kk},experimentaldesign(1:N_train,:)); 
        Ysurrogate = pcagatherout * PCA{kk}.V(:, 1:PCA{kk}.number)' + PCA{kk}.mv; 
    else
        Ysurrogate = uq_evalModel(myPCE{kk},experimentaldesign(1:N_train,:)); 
    end 
    SE_error = YFE - Ysurrogate;
    SE_COV = cov(SE_error);
    fig_save = figure('visible','off'); figuretitle = 'Surrogate error covariance $\Sigma_{T}$';
    heatmap_NY(SE_COV, figuretitle);
    
    % creat the folder to restore figs if not existed
    outputfolder = fullfile(path_savedFigure,'surrogate_error_COV');
    if isfolder(outputfolder) == 0
        mkdir(outputfolder);
    end
    
    %Name and export figures 
    filename = ['Outputfield' num2str(kk) '-' 'Stage' num2str(jj) '.png' ];
    filepath  = fullfile(outputfolder,filename);
    exportgraphics(fig_save,filepath,...
               'BackgroundColor','white');
    
    
    % % only save COV for AnParam.DR == "on" is off
    % if AnParam.DR == "on"
    %     % do nothing
    % else
    %     % calculate the heatmap for COV heatmap for YPCE and Yval
    %     % create the heatmap for COV heatmap using PCE coeficients
    %     fig_YPCE = figure('visible','off'); 
    %     COV_YPCE = zeros(size(Ysurrogate,2),size(Ysurrogate,2));
    %     for uu = 1: size(Ysurrogate,2)
    %         for nn = 1:size(Ysurrogate,2)
    %             coef_uu = myPCE{1, kk}.PCE(uu).Coefficients(2:end);
    %             coef_nn = myPCE{1, kk}.PCE(nn).Coefficients(2:end);
    %             maxLength = max(length(coef_uu), length(coef_nn));
    %             %in case two coef vectors are not equal length
    %             coef_uu = [coef_uu; zeros(maxLength - length(coef_uu),1)];
    %             coef_nn = [coef_nn; zeros(maxLength - length(coef_nn),1)];
    %             COV_YPCE(uu,nn) = dot(coef_uu,coef_nn);
    %         end
    %     end
    %     heatmap_NY(COV_YPCE, '$\tilde{\mathcal{M}}$ covariance');
    %     filename = ['Outputfield' num2str(kk) '-' 'Stage' num2str(jj) '-YPCECOV.png' ];
    %     filepath  = fullfile(outputfolder,filename);
    %     exportgraphics(fig_YPCE,filepath,...
    %                'BackgroundColor','white');
    % 
    %     %create the COV heatmap using FE outputs
    %     fig_YFE = figure('visible','off'); 
    %     COV_YFE = cov(YFE);
    %     heatmap_NY(COV_YFE, '$\mathcal{M}$ covariance');
    %     filename = ['Outputfield' num2str(kk) '-' 'Stage' num2str(jj) '-YFECOV.png' ];
    %     filepath  = fullfile(outputfolder,filename);
    %     exportgraphics(fig_YFE,filepath,...
    %                'BackgroundColor','white');
    % end
end

   
    %save SE_COV SE_COV;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%












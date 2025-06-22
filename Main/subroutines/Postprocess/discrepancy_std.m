function discrepancy_std(BayesAnalysis,AnParam,coord,N,jj)
%ADDME: Burn in 70% posterior samples and get the discrepancy/errors samples
 

%Input: 
%       AnParam-structure of analysis parameters
%       BayesAnalysis-result strcuture, all posterior information is stored in this.
%       coord: spatial coordination
%       N: number of hyperparameters for specific field

%Output: plotting the inferred discrepancy/errors std 

% if COV is not given, we can plot inferred the discrepancy; otherwise
% return
if ~isempty(AnParam.COVdata)
    return;
end

%% 70% burnin and 90%CI
uq_postProcessInversionMCMC(BayesAnalysis,'pointEstimate','MAP','percentiles',[0.05,0.95],'burnin',0.7);

    
%% Extract discrepancy hyperparameters poseterior samples
%from the BayesAnalysis strcuture and reshape into a vector
N_discreParam = N; % discrepancy parameter number

% get the discrepancy hyperparameter posterior samples from the BayesAnalysis structure
samplesTotal = [];
for ll =  AnParam.N_parameters + 1: AnParam.N_parameters + N_discreParam              
    temp =  BayesAnalysis.Results.PostProc.PostSample(:,ll,:);
    samplestemp = reshape(permute(temp, [2 1 3]), size(temp, 2), [])';
    samplesTotal = horzcat(samplesTotal,samplestemp);
end   


% reshuffle samples
[m,n] = size(samplesTotal) ;
idx = randperm(m) ; %shuffle the samples by row
temp1  = samplesTotal ;
samplesTotal(idx,:) = temp1(1:m,:);  % arranged randomly by row

% create the polys basis based on the number of N_discreParam
polys = legendrePolynomialBasis(N_discreParam-1, coord);

%% sample and reconstruct the discrepancy/error std
SampleN = 5000;% sample number
fig = figure('position', [300, 0, 400, 400]);% create new figure

discrepSummary = [];% to store reconstructed errors 
%loop to plot the realization based on the samples
for ii = 1:SampleN
    ploy_w = samplesTotal(ii,:)'; % get the smaples for ploynomial coeficients w
    sigma = abs(polys*ploy_w); % reconstruct the std 
    %plot the error std
    h_sigma = plot(coord',sigma,'Color',[0 0 0 0.2],'LineWidth',0.1);
    discrepSummary = [discrepSummary;sigma'];
    hold on;
end
xlabel('Coordination','Interpreter','latex','FontSize',14);
ylabel('$\varepsilon$ (m)','Interpreter','latex','FontSize',14);
box on;grid on;

%scatter the MAP line 
discrep_map = [];
% for loop the get the most dense point
for ii = 1: size(discrepSummary,2)
    % calculate kernel density
    [f, xi] = ksdensity(discrepSummary(:,ii));  
    % get the most dense point
    [~, maxIdx] = max(f);
    mostDensePoint = xi(maxIdx);
    % store in discrep_map
    discrep_map(ii) =  mostDensePoint;
end
plot(coord,discrep_map,'-ro','LineWidth',2.0);
%legend([h_sigma h_mv], {'Samples', 'Mean'},'Location','southwest');
title(['Stage ' num2str(jj)],'FontSize',14);%ylim([0 1e-3]);
xlim([85 130]); xticks(85:5:130);
set(gca,'FontSize',14);view([90 -90]);pbaspect([2 1 1]);hold off;


% export figs
filename = sprintf('figure-observation%d.png',jj);
exportgraphics(fig,filename,...
           'BackgroundColor','white','Resolution',300);





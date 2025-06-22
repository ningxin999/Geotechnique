function heatmap_NY(COVdata, figuretitle)
%Addme: heatmap figure setting-following Ningxin Yang's style

%Input: COVdata: covariance matrix
%       figuretitle: title for the heatmap

% create heamap figure
h = heatmap(COVdata);
%h.Interpreter = 'latex';
%Customize the heatmap appearance
h.Colormap = jet; % Change the colormap
h.ColorbarVisible = 'on'; % Display the colorbar
h.GridVisible = 'off'; % Hide the grid
h.FontSize = 14; % Increase font size for readability
h.Title = figuretitle; % Add a title
% h.XLabel = ''; % Remove x-axis label
% h.YLabel = ''; % Remove y-axis label
h.XDisplayLabels = repmat({''}, size(COVdata, 1), 1); % Hide x-axis tick labels
h.YDisplayLabels = repmat({''}, size(COVdata, 1), 1); % Hide y-axis tick labels
h.ColorLimits = [min(COVdata(:)), max(COVdata(:))]; % Set color limits

% exportgraphics(h,'figure-heatmap.png',...
%            'BackgroundColor','white','Resolution',1200);
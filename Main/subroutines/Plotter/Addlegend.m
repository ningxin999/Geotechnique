function Addlegend(h_gt, h_obs, h_MAP)

% AddMe: Add legend 

% Initialize legend handles and labels
legend_handles = {};
legend_labels = {};

% Check each input and add it to the legend list
if ~strcmp(h_MAP, 'Null')
    legend_handles{end+1} = h_MAP;
    legend_labels{end+1} = '$\tilde{\mathcal{M}}(  \bf{\textit{x}}^{\rm{MAP}})$';
end

if ~strcmp(h_gt, 'Null')
    legend_handles{end+1} = h_gt;
    legend_labels{end+1} = '$\tilde{\mathcal{M}}(  \bf{\textit{x}}^{\rm{GT}})$';
end

if ~strcmp(h_obs, 'Null')
    legend_handles{end+1} = h_obs;
    legend_labels{end+1} = '$\mathcal{Y}_{obs}$';
end

% Create legend only if there are valid handles
if ~isempty(legend_handles)
    legend([legend_handles{:}], legend_labels, ...
        'FontSize', 10, 'Location', 'northeastoutside', 'interpreter', 'latex');
end

end

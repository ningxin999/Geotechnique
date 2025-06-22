
% Helper function for plotting
function plotPrediction(coord, FE_predict, obs_eachfield, FE_pred_gt, ll, AnParam, FE_MAP_predict, kk)
    hold on;
    % Nature-style color palette
    colors = struct(...
        'gray',    [0.4 0.4 0.4],...      % Primary gray for elements
        'blue',    [0.00 0.45 0.74],...    % Observation color
        'red',     [0.85 0.33 0.10],...    % MAP prediction highlight
        'lightgray', [0.7 0.7 0.7 0.3],... % Transparent background lines
        'black',   [0 0 0]);               % Ground truth color
    
    % Set default interpreters for LaTeX rendering
    set(groot, 'defaultAxesTickLabelInterpreter','latex');
    set(groot, 'defaultTextInterpreter','latex');

    % Plot predictive range if FE_predict is available
    plot(coord{kk}, FE_predict, '-',...
        'Color', colors.lightgray(1:3),...
        'LineWidth', 0.3);
    %2. Plot observations if they exis
    if ~anynan(obs_eachfield(:,ll))
        obs_data = reshape(obs_eachfield(:, ll), [], AnParam.N_Exp);
        scatter(coord{kk},obs_data,10,'bx','LineWidth',0.5');
        box on; grid on;pbaspect([2 1 1]);colororder("glow12");set(gca, 'FontSize', 14);

        %calculate the mean and remove 
        % obs_mv = mean(obs_data,2);
        % plot(coord{kk},obs_mv,'-k','LineWidth',2.0);
    end   

    % Plot predictive range and MAP prediction if FE_MAP_predict is not empty
    if ~isempty(FE_MAP_predict)
        h = plot(coord{kk}, FE_MAP_predict,  '-',...
            'Color', colors.red,...
            'LineWidth', 1.0);
        %uistack(h, 'top');
    end

    %3. Plot ground truth if exists
    if isnumeric(FE_pred_gt)
        plot(coord{kk},FE_pred_gt,'-',...
            'Color', colors.black,...
            'LineWidth', 1.8,...
            'LineStyle', ':'); 
    end        

    %4. Customize plot settings
    view([90 -90]);
    %subtitle(['Stage ' num2str(ll)],'FontSize',14);
    ax = gca; 
    ax.YAxis.Exponent = -3; % Set Y-axis exponent
    ax.XAxis.Exponent = 0;  % Set X-axis exponent
    
    % 🎨 Beautify Axis Labels
    xlabel('Depth (m)', 'Interpreter', 'latex', 'FontSize', 16, 'FontWeight', 'normal', 'Color', 'k');
    ylabel('$\mathcal{Y}$ (m)', 'Interpreter', 'latex', 'FontSize', 16, 'FontWeight', 'normal', 'Color', 'k');
    
    % 🎨 Improve Axis Appearance
    set(ax, 'FontSize', 16, 'FontWeight', 'normal', 'LineWidth', 1.0); % General axis styling
    set(ax.XAxis, 'Color', 'k', 'TickLength', [0.02 0.02], 'LineWidth', 1.0); % X-axis
    set(ax.YAxis, 'Color', 'k', 'TickLength', [0.02 0.02], 'LineWidth', 1.0); % Y-axis
    
    % 🏗️ Add Grid, Box & Aspect Ratio
    grid on; box on; % Ensure both are visible
    pbaspect([3 1.5 1]); % Adjust aspect ratio
    
    % 🎨 Fine-tune Tick Labels
    ax.XMinorTick = 'on'; % Enable minor ticks
    ax.YMinorTick = 'on';
    ax.TickDir = 'in'; % Make ticks point outward for a cleaner look
    ax.XColor = 'k'; % Set tick color
    ax.YColor = 'k';
    ax.YRuler.Exponent = 0;

end

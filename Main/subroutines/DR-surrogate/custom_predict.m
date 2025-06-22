
function y = custom_predict(newdata, psin, psout, model)
    % Function to preprocess data, make predictions using a trained model, 
    % and revert the predictions to the original scale.
    %
    % Inputs:
    %   newdata - The input data for prediction (raw data, not normalized)
    %   psin - Preprocessing structure for input data (used for normalization)
    %   psout - Preprocessing structure for output data (used for denormalization)
    %   model - Trained model for making predictions
    %
    % Output:
    %   y - Predictions on the original scale of the output data

    % Normalize the input data using the provided preprocessing structure
    x = mapminmax('apply', newdata', psin);

    % Convert data format to cell array suitable for sequence input
    for i = 1:size(x, 2)
        x_new{i, 1} = x(:, i); % Each column of x becomes an individual sequence
    end

    % Use the trained model to predict the outputs
    pre = predict(model, x_new);

    % Reverse normalization to convert predictions back to the original scale
    y = mapminmax('reverse', pre', psout)';

    
end

function Y = py_curve(directory,jj,observation_stageTime)

%Warning: Be careful with this function

%ADDME:  Add scalar observation with time going if file exists
            %This is special part, only for PISA pile py-curve once
            %Update this PART next time when see this
            %Only used once for pisa pile


% No output required
    Y= 'Null';
    hold on;

    filePattern = 'CompleteObservation2*.csv';
    files = dir(fullfile(directory.inputcsv, filePattern));
    numOutputs = numel(files);% Count the number of files  
    if numOutputs ~= 0%tell whether file exists
        hold on; 
        py_curve=readtable(fullfile(directory.inputcsv,files.name));
        % Extracting columns 1 and 2
        disp_y = py_curve(:, 1);
        force_p = py_curve(:, 2);

        % Convert table variables to arrays
        disp_y = table2array(disp_y);
        force_p = table2array(force_p);


        %find the index for the current time 
        [value,idx]=min(abs(disp_y-observation_stageTime(jj)));

        % Plotting
        plot(disp_y(1:idx), force_p(1:idx), 'b','LineWidth',1.5); 
        plot(disp_y(idx+1:end), force_p(idx+1:end), ':b','LineWidth',1);
        hold off;
    end 

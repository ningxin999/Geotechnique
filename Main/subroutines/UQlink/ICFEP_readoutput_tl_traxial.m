function  Y = ICFEP_readoutput(outputfilename)
%ADDME:readoutput for only ICFEP results

%Input: outputfilename (with absolute path)
%Output:%coord: coordinates for output
        %output: output value

%global counting number for FE runs 
%only applicable for ICFEP
    global FE_ID
    FE_ID = FE_ID + 1;

%=================================data process============================
%=========================================================================
% Keyword that identify the requested output
    search_string = '           Number of ERROR   messages =     0';

%get the outputfile name
    [~,outputfilename,~] = fileparts(outputfilename);

%read all lines in outputfile 
    textinc = string(readlines([outputfilename,'.t']));

% find the initial  line started with 
    found = find(strcmp(textinc, search_string));

% Construct the path for the input file and read instructions
    rootdir = pwd;  % Get current directory
    path = fullfile(rootdir, 'input', 'csv', 'Fortran_Output.txt');  % Full path to the file
    Instructions = readlines(path);  % Read all lines from the file
    
    % Initialize an empty cell array to store the extracted variables
    instruction_cell = {};
    
    % Loop through the file content and process lines that start with a number or letter followed by ':'
    for i = 1:length(Instructions)
        line = strtrim(Instructions{i});  % Remove leading and trailing whitespace
        
        % Use a regular expression to match lines starting with a number or letter followed by ':'
        if ~isempty(regexp(line, '^[0-9]:', 'once'))
            % Extract the numeric values and any additional string after the numbers
            split_line = regexp(line, ':: *', 'split');  % Split at ': '
            
            % Split the remaining part into potential numeric values and a string
            parts = regexp(split_line{2}, ', *', 'split');  % Split at commas
            
            % Process the numeric values first
            num_values = [];
            for j = 1:length(parts)
                num_val = str2double(parts{j});
                if ~isnan(num_val)
                    num_values(end+1) = num_val;  % Collect the numeric values
                else
                    string_part = strjoin(parts(j:end), ', ');  % Capture the rest as a string
                    break;
                end
            end
            
            % Store the extracted numbers and optional string in the cell array
            if exist('string_part', 'var')
                instruction_cell{end+1} = {num_values, string_part};  % Store both numeric and string data
                clear string_part;  % Clear the string_part variable for the next iteration
            else
                instruction_cell{end+1} = {num_values};  % Only store numeric data if no string was found
            end
        end
    end
    
    % Step 3: Load the output file (replace 'output_file.txt' with the actual filename)
    file_content = string(readlines('list.t'));  % Reading the output file into a string array
    
    % Initialize an empty cell array to store the extracted variables

    

    % Loop over each instruction in instruction_cell and search for corresponding X and Y variable codes
    for k = 1:length(instruction_cell)
        % Extract the numeric values and optional string from instruction_cell
        data_entry = instruction_cell{k};
        values = data_entry{1};  % First element is always the numeric values
        
        % Extract the relevant variables from the numeric values
        type = values(1);            % 0 for scalar, 1 for vector
        first_stage = values(2);     % Starting stage (e.g., 50)
        last_stage = values(3);      % Ending stage (e.g., 320)
        increment = values(4);       % Increment (e.g., 10)
        x_var = values(5);           % X-axis variable code (e.g., 9401)
        y_var = values(6);           % Y-axis variable code (e.g., 4502)
        
        FE_stageTime = first_stage:increment:last_stage;
        N_stage = length(FE_stageTime);


        if length(data_entry) > 1
            string_info = data_entry{2};  % The second element is the string, if present
        end

        if type == 0 
            %{ 
                Type 0 is for scalar quantities. These only need to be
                extracted at the final stage. The command to print it only
                at the final stage is embedded in the ICFEP file itself. 

                The current file does not try and find the last stage. It
                be done if required. 
            %}
            % Dynamically create search strings for X and Y axis variable codes
            search_text_line1 = sprintf('X-axis variable code =  %d', x_var);
            search_text_line2 = sprintf('Y-axis variable code =  %d %s', y_var, string_info);
        
            % Step 4: Search for the exact text in the output file
            j = 0;
            for i = 1:length(file_content)
                if contains(file_content(i), search_text_line1)
                    if contains(file_content(i + 1), search_text_line2)
                        %====================  Outputs type 0 ======================
                        %===========================================================
                        % get the first line and last line including the outsput
                        First_line_1 = i+8; 
                        Last_line_1 = First_line_1 + 319;
                        % save results of interest
                        j=j+1;
                        t=str2double(split(file_content(First_line_1:Last_line_1))); 
                        
                        filter_values = first_stage:increment:last_stage;
                        tprime = t(ismember(t(:,4), filter_values), :);
                        
                        coord{k} = 0;  % s
                        % if all outputs for the quantity of interest are
                        % read at the bottom of the list.t file.
                        for qq = 1:N_stage  % length(tprime)
                            output{k}(:,qq)  = tprime(qq,5);  % y
                        end
                        
                        %break;  % Exit the loop after finding the first match for this instruction
                    end
                end    
            end
        end 

        if type == 1
            %====================  Outputs type 1 ======================
            %===========================================================
            j = 0; ll = 1;
                        
            incrementlist = {};
            for jj = first_stage:increment:last_stage
                incre_N = sprintf('%6d', jj);
                incrementlist{ll} = append('      *        INCREMENT PLOTTING DATA              INCREMENT:',incre_N,'      *');
                ll = ll + 1;
            end
            for i=1:length(file_content)
            % possible alternative. This reads the file until end where it 
            % returns a 1.
            % while ~feof(ftemp)
                % start with the every increment output beginning line 
                            % start with the every increment output beginning line 
                if  contains(file_content(i),incrementlist)
                    %====================Output one======================
                    %====================================================
                        % get the first line and last line including the output
                        First_line_1 = i+24; 
                        Last_line_1 = First_line_1 + 100;
                
                        % save results of interest
                        j=j+1;
                        t=str2double(split(file_content(First_line_1:Last_line_1))); 
%                         coord{k} = t(:,5)';  % coordinates for output1
                        coord{k} = reshape(t(:,5),1,[]);  % Might not be necessary
                        output{k}(:,j)=t(:,6)';  % output1 
                end
            end
        end
    end

%=====================export result=================================
%===================================================================

% create a new folder to save the results
    subfolder = 'output\mat\EoD_FE_current';
    if ~exist(subfolder, 'dir')
        mkdir(subfolder);
    end
% save result for output1 - output 1/finddata2 - output2
    fileNumber = sprintf('%03d', FE_ID);
    filename = [outputfilename fileNumber];
    %filename = outputfilename;
    save(fullfile(subfolder, filename),'coord','output','FE_stageTime');

    disp([filename  ' is finished!'])

%All result have been saved in file FE_Reuslt, no need for UQLAB output
    Y = 'Null';


end




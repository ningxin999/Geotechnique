function  Y = ABAQUS_readoutput(outputfilename)
%ADDME:readoutput for only ABAQUS results

%Input: outputfilename (with absolute path)
%Output:%coord_1: coordinate for output one
        %coord_2: coordinate for output two
        %output1: output value one
        %output2: output value two



%=================================data process=============================
%=========================================================================
% Keyword that identify the requested output
        %search_string = '      *        INCREMENT PLOTTING DATA              INCREMENT:   1        *';
        search_string = '                                                                                               STEP    1  INCREMENT    1';

%get the outputfile name
        [~,outputfilename,~] = fileparts(outputfilename);

%read all lines in outputfile 
        %textinc = string(readlines([outputfilename,'.t']));
        textinc = string(readlines([outputfilename,'.dat']));
% find the initial  line started with 
        found = find(strcmp(textinc, search_string));

% Shorten cell array to only after the search string.
        if isempty(found)
            %warning(['Search string "' search_string '" not found in file: .t']);
            warning(['Search string "' search_string '" not found in file: .dat']);
            return
        else
            textinc_shortened = textinc(found:end);
        end

% define the increment number and every increment starting line
% read the max increment
%         TPL_text = string(readlines(['Run1.t' '.tpl']));
        % Incre_Text = textinc(46); % Line containing the run inc data.
        % Split_incre = split(Incre_Text);
        % incre_max = Split_incre(3);
        % incre_max = strrep(incre_max,',','');
        % incre_max = str2num(incre_max);
        incre_max = 6;  %% The lines above are not trust worthy.

        inc = (1:incre_max);
        increment = string(inc);
        
        for k=1:size(inc,2)
            % incre_N = sprintf('%4d', k);
            % increment(k) = append('      *        INCREMENT PLOTTING DATA              INCREMENT:',incre_N,'        *');
            incre_N = sprintf('%5d', k);            
            increment(k) = append('                                                                                               STEP',incre_N,'  INCREMENT    1');
         
        end

        increment = increment(:,2:incre_max);

%loop to get the output and save the output the new file "FE_Result"

%count number for total increment
        j = 0;% j for output1
%initial data for output        


% for loop1 to get the results
        
        for i=1:length(textinc_shortened)
        % possible alternative. This reads the file until end where it 
        % returns a 1.
        % while ~feof(ftemp)
            % start with the every increment output beginning line 
            if  contains(textinc_shortened(i),increment)
                %====================Output one======================
                %====================================================
                    % get the first line and last line including the output1
                    First_line_1 = i+115; 
                    Last_line_1 = First_line_1 + 20;
            
                    % save results of interest
                    j=j+1;
                    t=str2double(split(textinc_shortened(First_line_1:Last_line_1))); 
                    coord{1} = t(:,6)';  % coordinates for output1                    
                    output{1}(:,j)=t(:,3);  % output1


                %====================Output two======================
                %====================================================
                %====================================================
                    % get the first line and last line including the output2
                    First_line_2 = Last_line_1+15; 
                    Last_line_2 = First_line_2 + 20;
                    % save results of interest
                    t=str2double(split(textinc_shortened(First_line_2:Last_line_2))); 
                    coord{2} = t(6,6)';  % coordinates for output2
                    str_inc = extractBetween(textinc_shortened(i),'STEP    ','INCREMENT    1');
                    FE_stageTime(:,j) = str2double(str_inc) -1; % stage time 
                    output{2}(:,j)=t(6,3);  % output2


                %====================Coodinate ascending arrangement======================
                %====================================================
                %====================================================
                % make sure the coordinate is ascending order
                for kk = 1:2
                    [coord{kk},index] = sort(coord{kk});
                    temp = output{kk}(:,j);
                    temp = temp(index);% sort output{kk}(:,j) based on [coord{kk},index]
                    output{kk}(:,j)   = temp; 
                end

            end
        end


%=====================export result=================================
%===================================================================

% create a new folder to save the results
    subfolder = fullfile(pwd,'data','output', 'mat','EoD_FE_current' ); 
	    if ~exist(subfolder, 'dir')
        mkdir(subfolder);
    end
% save result for output1 - output 1/finddata2 - output2
    filename = outputfilename;
    save(fullfile(subfolder, filename),'coord','output','FE_stageTime');

disp([filename  ' is finished!'])

%All result have been saved in file FE_Reuslt, no need for UQLAB output
Y = 'Null';


end




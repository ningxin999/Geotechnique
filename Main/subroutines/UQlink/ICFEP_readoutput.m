function  Y = ICFEP_readoutput(outputfilename)
%ADDME:readoutput for only ICFEP results

%Input: outputfilename (with absolute path)
%Output:%coord_1: coordinate for output one
        %coord_2: coordinate for output two
        %output1: output value one
        %output2: output value two
        %coord_0: coordination for su profile
        %output_0: su profile for visulization

%glbal counting number for FE runs 
%only applicable for ICFEP
        global FE_ID
        FE_ID = FE_ID + 1;


%=================================data process=============================
%=========================================================================
% Keyword that identify the requested output
        search_string = '      *        INCREMENT PLOTTING DATA              INCREMENT:   1        *';
%         search_string = '                                                                                               STEP    1  INCREMENT    1';

%get the outputfile name
        [~,outputfilename,~] = fileparts(outputfilename);

%read all lines in outputfile 
        textinc = string(readlines([outputfilename,'.t']));
%         textinc = string(readlines([outputfilename,'.dat']));
% find the initial  line started with 
        found = find(strcmp(textinc, search_string));

% Shorten cell array to only after the search string.
        if isempty(found)
            warning(['Search string "' search_string '" not found in file: .t']);
%             warning(['Search string "' search_string '" not found in file: .dat']);
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
        incre_max = 70;  %% The lines above are not trust worthy.

        inc = (1:incre_max);
        increment = string(inc);
        
        for k=1:size(inc,2)
            incre_N = sprintf('%4d', k);
            increment(k) = append('      *        INCREMENT PLOTTING DATA              INCREMENT:',incre_N,'        *');
%             incre_N = sprintf('%5d', k);            
%             increment(k) = append('                                                                                               STEP',incre_N,'  INCREMENT    1');
         
        end


%loop to get the output and save the output the new file "FE_Result"

%count number for total increment
        j = 0;% j for output1
%initial data for output        
        coord_0 = [];
        %coord_1 = [];
        %coord_2 = [];
        output0=zeros(0,0);
        %output1=zeros(0,0);% output1 for output1
        %output2=zeros(0,0);% findata for output2



% extract Su profile (only performed once, completed at 0th stage)
        for i=1:length(textinc)
            str = "      GRAPH TYPE  5219 COMMENCES.";
            if  contains(textinc(i), str)
                First_line_0 = i+14;
                Last_line_0 = First_line_0 + 100;
                t=str2double(split(textinc(First_line_0:Last_line_0))); 
                coord_0 = t(:,5);  % coordinates for output0
                output0(:,1)=t(:,7);  % output0
            end
        end
% plot(output0(:,1),coord_0)

% for loop1 to get the results
        jump_inc = 0;
        
        for i=1:length(textinc_shortened)
        % possible alternative. This reads the file until end where it 
        % returns a 1.
        % while ~feof(ftemp)
            % start with the every increment output beginning line 
                        % start with the every increment output beginning line 
            if  contains(textinc_shortened(i),increment)
                %====================Output one======================
                %====================================================
                    % get the first line and last line including the output
                    First_line_1 = i+19; 
                    Last_line_1 = First_line_1 + 100;
            
                    % save results of interest
                    j=j+1;
                    t=str2double(split(textinc_shortened(First_line_1:Last_line_1))); 
                    coord{1} = t(:,5)';  % coordinates for output1
                    output{1}(:,j)=t(:,7);  % output1
                %====================Output two======================
                %====================================================
                %output 2 only for the last increment
                %if j == max(inc)
                % get the first line and last line including the output

                    First_line_2 = Last_line_1+55 + jump_inc;                   

                    str_inc = extractBetween(textinc_shortened(i),'INCREMENT:','        *');
                    Last_line_2 = First_line_2 + str2double(str_inc) ; 
                    jump_inc = str2double(str_inc) ;
            
                % save results of interest
                    t=str2double(split(textinc_shortened(First_line_2:Last_line_2))); 
                    coord{2} = 0; % coordinates for output2
                    FE_stageTime(:,j) = t(end,4); % stage time 
                    output{2}(:,j)=t(end,5);  % output2
                %end
        
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
    save(fullfile(subfolder, filename),'coord','coord_0','output0','output','FE_stageTime');

disp([filename  ' is finished!'])

%All result have been saved in file FE_Reuslt, no need for UQLAB output
Y = 'Null';


end




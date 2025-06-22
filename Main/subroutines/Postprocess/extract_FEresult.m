function extract_FEresult(filename,directory,AnParam,EDarray)

%ADDME function one: Extra the results from the .mat file and rearrange
%Input: filename: setting in the UQlink modulue
%		directory-working directory structure
%		AnParam strcuture
%Output: Y = 'Null', no output required


%The format of raw_output is as:
%======================Cell one====================================================Cell two==================== …
% Run one												||	Run two											…
% Coordinate 	coord1	coord2	coord3	coord4	coord5	||	Coordinate 	coord1	coord2	coord3	coord4	coord5	…
% Stage1		XXX		XXX		XXX		XXX		XXX		||	Stage1		XXX		XXX		XXX		XXX		XXX		…
% Stage2		XXX		XXX		XXX		XXX		XXX		||	Stage2		XXX		XXX		XXX		XXX		XXX		…
% …				…		…		…		…		…	    ||	…   		…  		…  		…  		…  		…		…
% Stage100		XXX		XXX		XXX		XXX		XXX		||	Stage100	XXX		XXX		XXX		XXX		XXX		…


%The format of FEcell_output is as:
%======================Cell one====================================================Cell two==================== …
% Stage one												||	Stage two											…
% Coordinate 	coord1	coord2	coord3	coord4	coord5	||	Coordinate 	coord1	coord2	coord3	coord4	coord5	…
% Run1			XXX		XXX		XXX		XXX		XXX		||	Run1		XXX		XXX		XXX		XXX		XXX		…
% Run2			XXX		XXX		XXX		XXX		XXX		||	Run2		XXX		XXX		XXX		XXX		XXX		…
% …				…		…		…		…		…	    ||	…   		…  		…  		…  		…  		…		…
% Run100		XXX		XXX		XXX		XXX		XXX		||	Run100		XXX		XXX		XXX		XXX		XXX		…

    %No output required
    Y = 'Null';


	%% Get a list of files in the folder
	    subfolder = fullfile(directory.exportmat,'EoD_FE_current');
	    files = dir(fullfile(subfolder, '*.mat'));
    %% if files are empty, stop the program
        if isempty(files) == 1
            warning('Current FE folder is empty');
            coord = [];
            FEcell_output = [];
            return
        end


	%See whether the output results equal to the number of runs we set AnParam.N_RUN_EoD
	%Also a check for whether all the FE analysis are completed successfully
	    if AnParam.N_RUN_EoD ~= numel(files)
		    disp('ERROR: Number of FE runs is not equal to the FE results')
		    return
	    end

	%Generate initial empty cells for output
	    raw_output = cell(1, AnParam.N_outputfields);
	    for ii = 1:AnParam.N_outputfields
		    for jj = 1:AnParam.N_RUN_EoD
			    raw_output{ii}{jj} = {};
		    end
        end


	%% loop to extract data from XXX.mat file to cells
        %ICFEP will only pass the restult name as 'list' not like abaqus
        %will pass like 'Nonlinear_truss'
        if strcmp(AnParam.FE_package,'ICFEP')
            filename = 'list';
        end

	    for kk = 1: AnParam.N_RUN_EoD
		    mfilename  = [filename, sprintf('%03d', kk),'.mat'];
		    load([fullfile(subfolder,mfilename)]);
		    for ii = 1:AnParam.N_outputfields
			    eval('raw_output{1,ii}{kk} = output{1,ii}(:,:)'';');            
    
		    end
	    end

	% setup empty cells for number of outputfield sources
	% get the number of loading steps/construction stages N_stage
	%Generate initial empty cells for FE_output

	    FEcell_output = cell(1, AnParam.N_outputfields);
	    for kk = 1:AnParam.N_outputfields
		    for jj = 1:AnParam.N_FE_stage
			    FEcell_output{kk}{jj} = {};
		    end
	    end

	%%% change raw_output format into FEcell_output format
	    for kk = 1: AnParam.N_outputfields
    
		    for jj = 1:AnParam.N_FE_stage
			    stageOutput_jj = [];%N_Run X N_coordinate for jj-th stage
			    for ii= 1:AnParam.N_RUN_EoD
				    Output_ii = raw_output{1,kk}{1,ii};%output: N_stage X N_coordinate for ii-th FE run
				    stageOutput_jj = [stageOutput_jj; Output_ii(jj,:)];% catenate and restore
			    end
			     FEcell_output{kk}{jj}= stageOutput_jj; 
		    end
    
        end



	%%% Get the directory of EoD_FE_summary and save the current results 
	    subfolder = fullfile(directory.exportmat,'EoD_FE_summary');
    
        if ~exist(subfolder, 'dir')
            mkdir(subfolder);
        end
        
    %in case duplicate name, suffix with a random number with respect
    %to time

        sha256hasher = System.Security.Cryptography.SHA256Managed;
        Time = datestr(now);
        Time_seed = uint16(sum(uint8(sha256hasher.ComputeHash(uint8(Time)))));
        
    %%% ICFEP and ABAQUS generate different FE results
    %%% ABAQUS only save coordination and FE results
    %%% ICFEP additionally need a e.g., Su profile in output0 and coord_0
    switch AnParam.FE_package
        case 'ABAQUS'
            EoDfilename = ['EoD_seed' num2str(AnParam.EoDseed) '_Run' num2str(AnParam.N_RUN_EoD) ...
                            '_N_Enrich' num2str(AnParam.N_enrich) '_' num2str(Time_seed)];        
            save(fullfile(subfolder, EoDfilename),'EDarray','coord','FEcell_output','FE_stageTime');
            
        case 'ICFEP'

            EoDfilename = ['EoD_seed' num2str(AnParam.EoDseed) '_Run' num2str(AnParam.N_RUN_EoD)...
                            '_N_Enrich' num2str(AnParam.N_enrich) '_' num2str(Time_seed)];        
            save(fullfile(subfolder, EoDfilename),'EDarray','coord','FEcell_output','FE_stageTime');
    end
	
end
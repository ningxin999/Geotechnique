
function FEcell_output_interp_coord_stageTime = interp_coord_stageTime(observationcoord,FE_coord,FEcell_output, ...
                                                            AnParam,observation_stageTime,FE_stageTime)

%ADDME: interpolation includes coordination interpolation and stateTime
%       interpolation. In this script, we do the coordination interpolation
%       , then we do the stageTime interpolation.

%Input:   AnParam:Analysis structure with parameters
%         observationcoord: observation coordination
%         FE_coord: coordination from the FE package/output
%         FEcell_output: results from FE packages
%         observation_stageTime: observation with changing stage time (based on technical report)
%         FE_stageTime: FE output with changing stage time (based on steps/increment)

%Output: FEcell_output_interp_coord_stageTime: FE results after coordination and
%                                   stageTime interpolation

    % coordination interpolation
    FEcell_output_interp_coord = interpolation(observationcoord,FE_coord,FEcell_output, AnParam,'spatial_interp');

    % stageTime interpolation based on FE results from coordination
    % interpolation above
    FEcell_output_interp_coord_stageTime  = interpolation(observation_stageTime,FE_stageTime,FEcell_output_interp_coord, AnParam,'time_interp');

end





function FEcell_output_interp  = interpolation(observation_st_coord,FE_st_coord,FEcell_output, AnParam,interpChoice)

  %ADDME:   Interpolation between different time stages (spatial coordinations) to make FE result (vector/scalar output) 
  %         to fit with observation
  %         !!!Notice: For vector interpolation, it may ruin the output structure, which it
  %         should ensure the time increment should be small enough
  %         !!!Notice: For scalar FE output or FE output only with one stageTime, it
  %         cannot be interpolated with only one value. Just return itself


  %Input:   AnParam-Analysis structure with parameters
  %         observation_st_coord: stage time from field/synthetic results
  %         FE_st_coord: stage time from FE results
  %         FEoutput-FE output
  %         AnParam:Analysis structure with parameters
  %         interpChoice: 'spatial_interp' for coordination;'time_interp'
  %         for stageTime

  %Output: FEcell_output_interp




    %%loop to get different sources data of fields 
    for kk = 1:AnParam.N_outputfields 

        % interpolatoin choice for coordination or stageTime
        switch interpChoice

            % spatial coordination interpolation
            case 'spatial_interp'
                if ~isscalar(FE_st_coord{kk})
                    FEcell_output_interp{kk} = single_interp(FE_st_coord{kk},FEcell_output{kk},observation_st_coord{kk},AnParam,interpChoice);
                else
                    FEcell_output_interp{kk} = FEcell_output{kk};
                end

            % stageTime interpolation                
            case 'time_interp'
                if ~isscalar(FE_st_coord)
                    FEcell_output_interp{kk} = single_interp(FE_st_coord,FEcell_output{kk},observation_st_coord,AnParam,interpChoice);
                else
                    FEcell_output_interp{kk} = FEcell_output{kk};
                end
                
        end
                 
    end

end


function FEcell_output_interp_single = single_interp(FE_st_coord,FE_singleField,observation_st_coord,AnParam,interpChoice)

%ADDME: main program to excute the interpolation

%Input:   AnParam-Analysis structure with parameters
%         observation_st_coord: stage time from field/synthetic results
%         FE_st_coord: stage time from FE results
%         FE_singleField-FE output only for single fieldoutput
%         AnParam:Analysis structure with parameters
%         interpChoice: 'spatial_interp' for coordination;'time_interp'
%         for stageTime

%Output:FEcell_output_interp_single

    % change interpolation choices
    switch interpChoice

        % coordination interpolation
        case 'spatial_interp'

            %Note:FE_coordination must contain observation coorination
            if min(observation_st_coord) < min(FE_st_coord) || max(observation_st_coord) > max(FE_st_coord) 
                error(['Please double check observation.csv files, observation file coordination ' ...
                        'is out of range of FE coordination!!!']);
            end

            for qq = 1: AnParam.N_FE_stage
                for ll = 1: 1:AnParam.N_RUN
                    %for loop to interpolation to fit to observation
                    %Interpolation method choice:
                    %'linear';'nearest';'next';'previous';'cubic';'v5cubic';'makima';'spline'
                    FEcell_output_interp_single{qq}(ll,:) = interp1(FE_st_coord,FE_singleField{qq}(ll,:),...
                                            observation_st_coord,'spline');
                end
            end


            
        % stageTime interpolation
        case'time_interp'

            %Note:FE_stageTime must contain observation_stageTime
            if min(observation_st_coord) < min(FE_st_coord) || max(observation_st_coord) > max(FE_st_coord)
                error(['Please double check StageTime.csv files, StageTime file stageTime ' ...
                        'is out of range of FE stageTime!!!']);
            end


            %loop for different RUNS
            for ll = 1:AnParam.N_RUN  
                %loop for different depths along the coordinations
                for mm = 1:size(FE_singleField{1},2)  
                    
                    % set an empty list to restore the all stages FE outputs at
                    % single run/depth coordination before interpolation:
                    % FE_FRD_allStages: All stages FE results at single field/single
                    % run/single depth coordination             
                    FE_FRD_allStages = [];
        
                    %for loop to extract all FE stages results-FE_FRD_allStages
                    for qq = 1: AnParam.N_FE_stage
                         temp = FE_singleField{qq}(ll,mm);
                         FE_FRD_allStages = horzcat(FE_FRD_allStages,temp);
                    end
        
        
                    %for loop to interpolation to fit to observation
                    %Interpolation method choice:
                    %'linear';'nearest';'next';'previous';'cubic';'v5cubic';'makima';'spline'
                    for ii = 1:AnParam.N_Obs_stage
                        FEcell_output_interp_single{ii}(ll,mm) = interp1(FE_st_coord,FE_FRD_allStages,...
                                                                    observation_st_coord(ii),'spline');
                    end
                end
    
           end
    end



end
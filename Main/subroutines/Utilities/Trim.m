function [FEcell_output_interp,observationsarray,observationcoord]  = Trim(jj,AnParam,FEcell_output_interp,FE_coord,kk,observationsarray,observationcoord)


%Addme:trim the FE output and observationsarray, observation coord, only save part of resutls if necessary
%       Note trim process for observation can be only excuted once at the
%       initial stage jj=1, since observation was read outside the big for
%       loop

%Input: AnParam:structure of analysis paramters
%       FEcell_output_interp: FE results after fitting with observation 
%       FE_coord : coordination
%       kk: kk-th outputfield (now it is mannually defined as 1 referred to output field one )
%       observationsarray: observation cell
%       observationcoord: oberservation coordination

%Output: FEcell_output_interp after trim
%        observationsarray: trimed observation 
%       observationcoord: trimed berservation coordination
    


    %observation can be only trimmed  once (output and observation coord)
    % becasue obeservation is read outside of the big for loop
    if jj ==1
        % observationsarray may contain different sets of exp/observation.
        % trim observation array
        allExp = reshape(observationsarray{kk},numel(observationcoord{kk}),[]);% reshape all exp vector format  into matrix format
        allExp_Trim = allExp(AnParam.Trim,:); % begin trim
        observationsarray{kk} = reshape(allExp_Trim,[],numel(observationcoord{kk})); % reshape back after trim

        % trim observation coord
        observationcoord{kk} = observationcoord{kk}(:,AnParam.Trim); % observation coordinate

        % trim the FE (output ) no need to trim FE coord because we only use the coordination for observations
        FEcell_output_interp{kk} = cellfun(@(x) x(:,AnParam.Trim),FEcell_output_interp{kk},'uni',false);
    else 
        observationsarray{kk} = observationsarray{kk};
    end


end
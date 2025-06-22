function PriorOpts = datainput(main_prior,boundary_prior)
%DATAINPUT Summary of this function goes here
%   Detailed explanation goes here


    %switch prior construction for EoD or forward 
    switch nargin

        %prior for EoD, can be only uniform
        case 1
            if ismatrix([main_prior.parameter1])
                % tilde means this variable is deleted immediately and is therefore
                % unused. 
                [~,c] = size([main_prior.parameter1]);
                Input_name = [main_prior.Input_name];  % These 4 lines are very awkward.
                type = [main_prior.type];              % There is definitely something
                parameter1 = [main_prior.parameter1];  % wrong with Matlab. 
                parameter2 = [main_prior.parameter2];
                for ii = 1:c
                    PriorOpts.Marginals(ii).Name = Input_name{ii};
                    PriorOpts.Marginals(ii).Type = type{ii};
                    PriorOpts.Marginals(ii).Parameters = [parameter1(ii) parameter2(ii)];
                    %No boudary available
        
                end
            end



        %prior for forward (need trunction or boundary)
        case 2
            if ismatrix([main_prior.parameter1])
                % tilde means this variable is deleted immediately and is therefore
                % unused. 
                [~,c] = size([main_prior.parameter1]);
                Input_name = [main_prior.Input_name];  % These 4 lines are very awkward.
                type = [main_prior.type];              % There is definitely something
                parameter1 = [main_prior.parameter1];  % wrong with Matlab. 
                parameter2 = [main_prior.parameter2];
                for ii = 1:c
                    PriorOpts.Marginals(ii).Name = Input_name{ii};
                    PriorOpts.Marginals(ii).Type = type{ii};
                    PriorOpts.Marginals(ii).Parameters = [parameter1(ii) parameter2(ii)];
                    %Add boundary if input prior is for forward
                    PriorOpts.Marginals(ii).Bounds = [boundary_prior(ii).parameter1 boundary_prior(ii).parameter2] ;
        
                end
            end   
    end         
            
 









end


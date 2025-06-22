function [S_tot,S_i]=uq_PCA_Sobol(myMdl)
% ＭＩＴ　Ｌｉｃｅｎｓｅ：　ｔｈｉｓ　ｃｏｄｅ　ｉｓ　ｏｒｉｇｉｎａｌｌｙ　ｆｒｏｍ：　https://uqworld.org/t/pca-based-sobol-indices-for-vector-valued-pce-surrogate-model/1538


%uq_PCA_Sobol Evaluates total and first order Sobol indices for          %
%             multivariate PCE+PCA model in original data space          %
%                                                                        %
% Input:                                                                 %
%   myMdl:                 Struct containing custom PCA and UQLab PCE    %
%                          model                                         %
%    myMdl.PCE:          UQLab PCE model                               %
%    myMdl.PCA:            Custom PCA model                              %
%    myMdl.PCA.T:         PCA transformation matrix-eigen vectors | K x K*            %


%                                                                        %
% Output:                                                                %
%   S_tot:                 total Sobol indcies                           %
%                          | K x M                                       %
%   S_i:                   first order Sobol indcies                     %
%                          | K x M                                       %
%                                                                        %
%                                                                        %
% Notes:                                                                 %
%  -  N:  # Number of runs                                               %
%     K:  # Number of output size full space                             %
%     K*: # Number of principle component ( K* <= K )                    %
%     M:  # number of model parameters                                   %
%                                                                        %
% References:                                                            %
%                                                                        %
% [1]	P. R. Wagner, R. Fahrni, M. Klippel, A. Frangi, and B. Sudret,   %
%       “Bayesian calibration and sensitivity analysis of heat transfer  %
%       models for fire insulation panels,” Eng. Struct., vol. 205,      %
%       p. 110063, Feb. 2020, doi: 10.1016/j.engstruct.2019.110063.      %
% [2]	J. B. Nagel, J. Rieckermann, and B. Sudret, “Principal           %
%       component analysis and sparse polynomial chaos expansions for    %
%       global sensitivity analysis and model calibration: Application   %
%       to urban drainage simulation,” Reliab. Eng. Syst. Saf.,          %
%       vol. 195, p. 106737, Mar. 2020, doi: 10.1016/j.ress.2019.106737. %
%                                                                      %


%% 1) Process input parameters

% i) Check number of inputs
if nargin > 1
    disp('ERROR: Too many inputs')
    return
elseif nargin < 1
    disp('ERROR: Too few inputs')
    return
end

% ii) Number of output dimensions (data space)
K=size(myMdl.PCA.T,1);

% iii) Truncated number of output dimensions (PCA space)
K_star=size(myMdl.PCA.T,2);

% iv) Number of input dimensions (#variable model parameters)
%M=length(myMdl.PCE.Options.Input.nonConst);
M=size(myMdl.PCE.ExpDesign.X,2);
% v) Define PCA transformation matrix | K x K*
T=myMdl.PCA.T;


%% 2) Compute total Sobol indices (cf. eq. 34 in [1])

% i) Define truncated union set for multi indices alpha | N_alpha_star x M
Alpha=cell(K_star,1);
for t=1:K_star
    Alpha{t}=full(myMdl.PCE.PCE(t).Basis.Indices);
end

Alpha_star = unique(cat(1,Alpha{:}),'rows'); 
N_alpha_star=size(Alpha_star,1);

% ii) Define PCE coefficient matrix | N_alpha_star x K_star
A=zeros(N_alpha_star,K_star);
for t=1:K_star
    [~,idx_a2A]=ismember(Alpha{t},Alpha_star,'rows');
    A(idx_a2A,t)=myMdl.PCE.PCE(t).Coefficients;
    clear idx_a2A
end

% iii) Preallocate array
S_tot=zeros(K,M);
Var_Y=zeros(K,1);

% iv) Iterate over data space dimension t
for t=1:K
    
    % v) Iterate over input parameter dimension m
    for m=1:M
        
        % vi) Compute nominator in equation 34 in [1]
        idx_alpha_star0=find(Alpha_star(:,m)==0);
        N_alpha_star0=length(idx_alpha_star0);
        var_num=0;
        for j=1:N_alpha_star0
            
            var_num_tmp=0;
            for p=1:K_star
                var_num_tmp=var_num_tmp+A(idx_alpha_star0(j),p)*T(t,p);
                
            end
            var_num=var_num+var_num_tmp^2;
            
        end
        clear var_num_tmp idx_alpha_star0 N_alpha_star0
        
        % vii) Compute denominator in equation 34 in [1]
        var_den=0;
        for j=1:N_alpha_star
            
            var_den_tmp=0;
            for p=1:K_star
                var_den_tmp=var_den_tmp+A(j,p)*T(t,p);
                
            end
            var_den=var_den+var_den_tmp^2;
            
        end
        clear var_den_tmp
        
        % viii) Compute total sobol index according to equation 34 in [1]
        S_tot(t,m) = 1 - var_num / var_den;
        
        % ix) Store variance for output dimension t
        Var_Y(t,1) = var_den;

        clear var_num var_den 
    end
end

clear t m j


%% 3) Compute first order Sobol indices (cf. eq. 18 in [2])

% i) Preallocate array
S_i=zeros(K,M);

% % ii) Iterate over data space dimension t
% for t=1:K
% 
%     % iii) Iterate over input parameter dimension m
%     for m=1:M
% 
%         % iv) Preallocate array
%         S_i_tmp=0;
% 
%         % v) Iterate over PCA output dimension p
%         for p=1:K_star
% 
%             % vi) Define variance of PCA output dimension p
%             Var_Zp=myMdl.PCE.PCE(p).Moments.Var;  
% %             Var_Zi=sum(A_i(2:end).^2);
% 
%             % vii) Define PCE coefficients for PCA output dimension p
%             A_p=myMdl.PCE.PCE(p).Coefficients;
% 
%             % viii) Define indices of set 
%             %      Alpha_{i} := {alpha element of natural numbers^M : 
%             %                    alpha(i)>0, alpha(j~=i)=0}
%             idx_alpha=find(Alpha{p}(:,m)>0 & all(Alpha{p}(:,setdiff(1:M,m))==0,2));
% 
%             % ix) Compute first order Sobol index for PCA output dimension
%             %     p
%             S_Zpi=sum(A_p(idx_alpha).^2)/Var_Zp;
% 
%             % x) Update first order Sobol index for data output dimension
%             %    t         
%             S_i_tmp=S_i_tmp+S_Zpi*Var_Zp/Var_Y(t,1)*T(t,p)^2;
% 
%             % xi) Compute covariance term in eq. 18 in [2] 
% 
%             for q=1:K_star
% 
%                 if p < q
% 
%                     Alpha_star_tmp = unique(cat(1,Alpha{[p,q]}),'rows');
%                     N_alpha_star_tmp=size(Alpha_star_tmp,1);
% 
%                     A_tmp=zeros(N_alpha_star_tmp,2);
%                     l=1;
% 
%                     for k=[p,q]
%                         [~,idx_a2A]=ismember(Alpha{k},Alpha_star_tmp,'rows');
%                         A_tmp(idx_a2A,l)=myMdl.PCE.PCE(k).Coefficients;
%                         l=l+1;
%                         clear idx_a2A
%                     end
% 
%                     idx_alpha_star_tmp=find(Alpha_star_tmp(:,m)>0 & all(Alpha_star_tmp(:,setdiff(1:M,m))==0,2));
%                     cov_pq=sum(A_tmp(idx_alpha_star_tmp,1).*A_tmp(idx_alpha_star_tmp,2));
% 
%                     % xii) Update first order Sobol index for data output dimension
%                     %    t 
%                     S_i_tmp = S_i_tmp + 2*cov_pq/Var_Y(t,1)*T(t,p)*T(t,q);
%                 end
% 
%             end
% 
%         end
% 
%         % xiii) Assign first order sobol index for data output dimension t 
%         %    according to equation 18 in [2]
%         S_i(t,m) = S_i_tmp;
% 
%     end
% end

% ii) Iterate over data space dimension t
parfor t = 1:K  % Parallelize over data space dimension t for large-scale computation

    % Precompute constants independent of m and p
    Var_Y_t_inv = 1 / Var_Y(t, 1);  % Use reciprocal of Var_Y to speed up division
    T_t_sq = T(t, :).^2;            % Square of T(t, p) to accelerate computation

    % iii) Iterate over input parameter dimension m
    for m = 1:M

        % Initialize Sobol index accumulator
        S_i_tmp = 0;

        % Precompute PCE variances and coefficients across dimension p
        Var_Zp_all = arrayfun(@(p) myMdl.PCE.PCE(p).Moments.Var, 1:K_star);
        A_all = arrayfun(@(p) myMdl.PCE.PCE(p).Coefficients, 1:K_star, 'UniformOutput', false);

        % v) Iterate over PCA output dimension p
        for p = 1:K_star
            Var_Zp = Var_Zp_all(p);
            A_p = A_all{p};

            % viii) Precompute and store idx_alpha index
            idx_alpha = find(Alpha{p}(:, m) > 0 & all(Alpha{p}(:, setdiff(1:M, m)) == 0, 2));

            % ix) Compute first-order Sobol index for PCA output dimension p
            S_Zpi = sum(A_p(idx_alpha).^2) / Var_Zp;

            % x) Update first-order Sobol index for data output dimension t
            S_i_tmp = S_i_tmp + S_Zpi * Var_Zp * Var_Y_t_inv * T_t_sq(p);

            % xi) Compute covariance and update Sobol index
            for q = p+1:K_star  % p < q to avoid redundant calculations

                % Premerge Alpha indices
                Alpha_star_tmp = unique(cat(1, Alpha{[p, q]}), 'rows');
                [~, idx_a2A_p] = ismember(Alpha{p}, Alpha_star_tmp, 'rows');
                [~, idx_a2A_q] = ismember(Alpha{q}, Alpha_star_tmp, 'rows');

                % Create merged A_tmp matrix
                A_tmp = zeros(size(Alpha_star_tmp, 1), 2);
                A_tmp(idx_a2A_p, 1) = A_p;
                A_tmp(idx_a2A_q, 2) = A_all{q};

                % Compute covariance
                idx_alpha_star_tmp = find(Alpha_star_tmp(:, m) > 0 & all(Alpha_star_tmp(:, setdiff(1:M, m)) == 0, 2));
                cov_pq = sum(A_tmp(idx_alpha_star_tmp, 1) .* A_tmp(idx_alpha_star_tmp, 2));

                % Update Sobol index
                S_i_tmp = S_i_tmp + 2 * cov_pq * Var_Y_t_inv * T(t, p) * T(t, q);
            end
        end

        % xiii) Assign calculated Sobol index for output dimension t and input m
        S_i(t, m) = S_i_tmp;
    end
end

end


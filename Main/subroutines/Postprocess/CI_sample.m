function Predict_sample_CI = CI_sample(Post_samples,LB,UB)
%ADDME: calculate the LB-UB percentile and extract the samples between confidence interval 

%Input: Post_samples: samples extracted from posterior
%                     LB: Lower percentile e.g., 5%=0.05 
%                     UB: Uppper percentile e.g., 95%=0.95

%Output: Predict_sample_CI: samples used to make predictive posterior with
%                           confidence range LB~UB 

    %find the percentile for LB and UB
        Post_Percentile_UB = quantile(Post_samples,UB); % e.g., cdf -95%
        Post_Percentile_LB = quantile(Post_samples,LB); % e.g., cdf - 5%
    
    %discard the samples not in LB~UB range
        condition = (Post_samples > Post_Percentile_LB) &  (Post_Percentile_UB > Post_samples);% filter samples 5%-95% CI (size:N_sample X N_parameter)
        logical_condition = all(condition,2); % tell if all data point is in 5%-95%, if it is true, reture 1, if not, reture 0(size:N_sample X 1)
        index_CI = find(logical_condition); % returne the index if the data sample is in 5%-95% range
        Predict_sample_CI = Post_samples(index_CI,:); % obtain e.g., 90%CI samples
        % randperm and select the first XX samples 
        sample_random = Predict_sample_CI(randperm(size(Predict_sample_CI, 1)), :);
        Predict_sample_CI = sample_random(1:100,:);
end
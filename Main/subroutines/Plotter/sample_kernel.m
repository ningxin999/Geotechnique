function Y = sample_kernel(K,figure_title,sampleN,coord)
%Addme: given a covariance matrix/kernel K. Sample from this K


%Input: K: covariance matrix
%       sampleN: sample number


%Ouput: samples realizations



% create an empty set to store all samples
    sampleSum = [];


% for loop to sample from kernel K
    [~,n] = size(K); % get the row and coloumn number of K

    Randn_basis = randn(n,sampleN);% create sampleN basis
    
    for mm =1:sampleN 

        Randn_basis_temp = Randn_basis(:,mm); % create N samples based on univarate random distribution
        [u,s,v] = svd(K); % svd to get the kernel's coordination
        sampletemp = u*sqrt(s)*Randn_basis_temp; % project the samplebasis using the kernel's coordination       
        % restore the the sampletemp in sampleSum
        sampleSum = horzcat(sampleSum,sampletemp);

    end
plot(coord,sampleSum,'.-'); %plot the samples
pubfig;
box on; grid on;
title(figure_title);
ylabel('Noise', 'interpreter', 'latex');
xlabel('Coordination $X$ (m)', 'interpreter', 'latex');
view([90 -90]);
pbaspect([2 1 1])
hold off;

% get the output sample realizations
Y = sampleSum;
function K = Eval_Kernel(coord,theta)
% UQ_EVAL_KERNEL computes the kernel matrix given two matrices for a specified kernel function.
N = numel(coord);
[idx2,idx1] = meshgrid(uint32(1:N),uint32(1:N));
h = abs(bsxfun(@rdivide,coord(idx1(:),:) - coord(idx2(:),:), theta'));
K = (1 + sqrt(5)*h + 5/3*(h.^2)) .* exp(-sqrt(5)*h);
K = reshape(K, N, N);


% coord1  = coord(idx1(:),:);
% coord2  =coord(idx2(:),:);
% K =  sigma^2*(coord1 - xc).*(coord2 - xc)+ sigmab^2;
% 
% K = reshape(K, N, N);


% Number of input points
n = length(coord);

% Initialize the covariance matrix
K = zeros(n, n);


% for i = 1:n
%     for j = 1:n
%         % K(i, j) =             (sigma1^2 * (coord(i) - xc1) * (coord(j) - xc1) + sigmab1^2)* ...
%         %             (sigma2^2 * (coord(i) - xc2) * (coord(j) - xc2) + sigmab2^2)        ;
%         K(i,j) = (1 + sqrt(5)*h + 5/3*(h.^2)) .* exp(-sqrt(5)*h);
%     end
% end


% to aviod non-positive definite, add epsilon
%epsilon = 1e-15; % A small value
%K = K + epsilon * eye(size(K));
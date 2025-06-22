function setupSaveFolder(jj)
% setupSaveFolder: Create or clear the 'savedResults' folder based on the input jj.
% This function ensures that at the initial stage (jj == 1), the 'savedResults' folder
% is either created or cleared. For subsequent stages (jj != 1), it does nothing.
%
% Input:
%   jj - Integer flag to control the operation:
%        jj == 1: Initialize or clear the folder (delete existing folder if it exists).
%        jj != 1: Do nothing.

% Check if the operation is the initial stage (jj == 1)
% Define the path for the 'savedResults' folder
path_savedFig = fullfile(pwd(), 'savedResults'); 
if jj ==1
    % If the 'savedResults' folder exists, remove it and its content
    if isfolder(path_savedFig)
        rmdir(path_savedFig, 's');% delete the subfolder and everything content inside 
        disp('Notice: savedResults folder has been cleared!');
    end
    % Create the folder for saving results
    mkdir(path_savedFig); 
end

end

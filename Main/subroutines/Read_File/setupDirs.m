function directory = setupDirs(removeold)
% setupDirs: Set up necessary input/output directories based on config.yaml.
%            Optionally removes old FE result files.
% Input: removeold ('true' / 'false') - whether to remove old FE results.
% Output: directory structure containing paths for input and output.

    % Ensure 'data' folder exists
    dataDir = fullfile(pwd, 'data');
    if ~isfolder(dataDir)
        mkdir(dataDir);
        error('The "data" folder should not be empty!');
    end

    % Load configuration from YAML file
    yamlFilePath = fullfile(dataDir, 'config.yaml');
    configData = yaml.ReadYaml(yamlFilePath);

    % Define necessary directories
    directory.inputcsv  = fullfile(pwd, configData.directories.inputcsv{:});
    directory.inputmat  = fullfile(pwd, configData.directories.inputmat{:});
    directory.exportmat = fullfile(pwd, configData.directories.exportmat{:});


    % Create directories if they don't exist
    allDirs = struct2cell(directory);
    cellfun(@(dir) ~isfolder(dir) && mkdir(dir), allDirs);
    
    % Remove old FE result files if specified
    if strcmpi(removeold, 'true')  % Case-insensitive comparison
        oldResultsDir = fullfile(directory.exportmat, 'EoD_FE_current');
        if isfolder(oldResultsDir)
            delete(fullfile(oldResultsDir, '*.mat'));
            fprintf('Deleted old .mat files from: %s\n', oldResultsDir);
        end
    end
end

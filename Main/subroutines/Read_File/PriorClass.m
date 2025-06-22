classdef PriorClass
    properties
        Prior_hyperdiscrep    % Observation discrepancy error parameters
        Prior_EoD             % Surrogate construction prior
        AnParam               % Analysis parameters (Name, N_parameters)
    end
    
    methods
        % Constructor 
        function obj = PriorClass(directory)
            % Constructor calls the readPrior method
            obj = obj.readPrior(directory);
        end
        
        % Method to read all priors
        function obj = readPrior(obj, directory)
            
            % read Prior_EoD
            obj.Prior_EoD = obj.loadCSVtoStruct(directory.inputcsv, 'Prior_EoD.csv');

            %read Prior_hyperdiscrep
            filePattern = 'hyper_obs_discrepancy*.csv';
            files = dir(fullfile(directory.inputcsv, filePattern));
            numOutputs = numel(files);
            obj.Prior_hyperdiscrep = cell(1, numOutputs);
            % Loop through files to read Prior_hyperdiscrep
            for ii = 1:numOutputs
                filename = sprintf('hyper_obs_discrepancy%d.csv', ii);
                obj.Prior_hyperdiscrep{ii} = obj.loadCSVtoStruct(directory.inputcsv, filename);
            end

            % Update AnParam
            obj.AnParam.Name = cellstr(string({obj.Prior_EoD.Input_name}));
            obj.AnParam.N_parameters = numel(obj.Prior_EoD);  
            obj.AnParam.N_outputfields = numOutputs; 
        end
        
        % Helper function to load CSV files into structures
        function dataStruct = loadCSVtoStruct(~, directory, filename)
        % Utility function to load CSV and convert it to a structure
        % Inputs:
        %       directory: path where the CSV file is located
        %       filename: name of the CSV file to load
        % Output:
        %       dataStruct: structure containing the CSV data
            filePath = fullfile(directory, filename);
            if isfile(filePath)
                % Load CSV into table, then convert to structure
                tempTable = readtable(filePath, TextType="string", VariableNamingRule="preserve");
                dataStruct = table2struct(tempTable);
            else
                error(['File ' filename ' does not exist in directory: ' directory]);
            end
        end
    end
end

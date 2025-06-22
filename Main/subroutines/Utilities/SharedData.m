classdef SharedData < handle
    properties
        Data
    end
    methods
        function obj = SharedData(data)
            obj.Data = data;
        end
    end
end

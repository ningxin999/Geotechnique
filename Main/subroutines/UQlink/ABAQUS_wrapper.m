function myUQLinkModel = ABAQUS_wrapper(name, filename)
%ADDME: Link ABAQUS/ICFEP with UQLAB

%Input: name-model name (e.g., Loaded-Conductor)
%       filename-(e.g,. NonLinear_Truss)

%Output:myUQLinkModel



% Model type:
        ModelOpts.Type = 'UQLink';
        ModelOpts.Name = name;
        EXECPATH = pwd();
		TEMPLATEFILE = [filename '.inp.tpl']; 
		COMMANDLINE = ['abaqus job=' filename ' int ask=off'];


% Command line 
        ModelOpts.Command = COMMANDLINE ;

% Provide the template file
        ModelOpts.Template = TEMPLATEFILE; 

% Provide  Execution path (where ICFEP will be run): 
        ModelOpts.ExecutionPath = EXECPATH;

% Output file list.t format 
        ModelOpts.Output.FileName = [filename '.dat']; 
        ModelOpts.Output.Parser = 'ABAQUS_readoutput';
        ModelOpts.Counter.Digits = 3;

% Specify the format of the variables ; Set the display to quiet:
        ModelOpts.Format =  {'%1.3E'}; %{'%.1f'};

% Specify counter offset (not required or suggested)
%         ModelOpts.Counter.Offset = 2;
        
% Specify display setting:
%         ModelOpts.Display = 'quiet';
%         ModelOpts.Display = 'standard'; % Default
        ModelOpts.Display = 'verbose';

% Specify archiving setting:
        ModelOpts.Archiving.Action = 'save';  % Default
%         ModelOpts.Archiving.Action = 'ignore';
%         ModelOpts.Archiving.Action = 'delete';

% Create the UQLink wrapper:
        myUQLinkModel = uq_createModel(ModelOpts);

end
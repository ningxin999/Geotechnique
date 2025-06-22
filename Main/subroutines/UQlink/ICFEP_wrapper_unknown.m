function myUQLinkModel = ICFEP_wrapper(name, filename)

% Model type:
        ModelOpts.Type = 'UQLink';
        ModelOpts.Name = name;
        EXE = 'icfep';
        EXECPATH = [pwd() '\'];
        INPUTFILE = strcat(filename, '.t');
        VERSION = '25.0';
%         TEMPLATEFOLDER = [pwd() '\TEMPLATE\'];
        CONCTEMPLATE = strcat(filename, '.t.tpl');
        TEMPLATEFILE = 'run_rough_all_v25.t.tpl'; 
        COMMANDLINE = sprintf('%s %s%s %s',EXE, EXECPATH, INPUTFILE, VERSION);


% Command line 
        ModelOpts.Command = COMMANDLINE ;

% Provide the template file
        ModelOpts.Template = TEMPLATEFILE; 

% Provide  Execution path (where ICFEP will be run): 
        ModelOpts.ExecutionPath = EXECPATH;

% Output file list.t format 
        ModelOpts.Output.FileName = 'list.t';
        ModelOpts.Output.Parser = 'ICFEP_readoutput';
        ModelOpts.Counter.Digits = 3;

% Specify the format of the variables ; Set the display to quiet:
%        ModelOpts.Format =  {'%.3f'}; 
         ModelOpts.Format = {'%1.3E'}; 

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
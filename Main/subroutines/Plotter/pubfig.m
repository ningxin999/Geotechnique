
%% Introduction
function pubfig(manual,fignum)
% PUBFIG(MANUAL, FIGNUM) Modified version of fixfig that creates figures
% that are publication ready. 
% 
% Fixfig:
% The font size for all text is increased,
% lines are made thicker, markers are made larger,background is set to
% white, etc. The values are set as constants near the top of the file. You
% may want to change the sizes and fonts to suit your system.
%
% Pubfig:   Increase thickness of axis lines. Increase tick length. Can
%           adjust output size of figures aswell.
%
%%%Optional Inputs%%%
%
% MANUAL    If on (manual =1) opens up dialogue to allow user to manually
%           update figure parameters such as figure size, line width, etc.
%
% FIGNUM    The number of the figure to modify. Default is the current
%           figure.
%
% Pubfig by: 
% Joe de Rutte
% May 2016
%
% Adapted from fixfig.m by
% M. A. Hopcroft
%  mhopeng at ml1 dot net
%
% MH Apr2010
% v1.11  keep legend backgrounds opaque (thanks to SJ for feedback)
%        show axes tag
%        specify axes instead of using gca
%

% MH MAY2009
% v1.01 fix typo at line 96 "('mkr')"
% v1.0  added text and line objects
%       cleaned up for public release
%     
% MH MAR205
% v0.9 script for personal use
%

%% Set Figure Parameter Values

% How thick do we like our lines?
lnwidth = 1;
% How about axes lines?
axwidth = 1;
% How thick to meake edge lines for bar graphs and histograms? 
baredge = 1;
% Axes Tic length
ticklength = 0.02;
% How big do we like our markers?
mksize = 6;
mksizept = mksize * 2; % points ('.') are always smaller
% Which font do we like in our figures?
myfont = 'Arial';
% myfont = 'Times';
fweight = 'normal'; % or 'normal'
% How big do we like our fonts?
fontsize = 12; % font sizes are scaled by this value. 2-3 is typical.

% Axis and font color
fontcolor = 0; % 0 = black, 1 = white
fontcolor = fontcolor*[1,1,1];
edgecolor = fontcolor;

% Figure Size and Position
set(gcf, 'Units','inches');
width = 4;
aspectRatio = 1.25;

% Check input options
if nargin < 2
    fignum=gcf;
end
if nargin < 1
    manual=0;
end

%% If Manual on create diologue to change figure parameter values
oldPosition = get(gcf,'Position');
if manual ==1 
    figure(gcf);
    set(gcf, 'Units','inches');
    dlg_title = 'Figure Editor';
    
    % Properties to Edit
    propertyNames ={'Width (inches)',...
                    'Ratio (w/h)',...
                    'Marker Size',...
                    'Linewidth',...
                    'Axis Line Width',...
                    'Tick Length',...
                    'Font Size',...
                    'Font Name'};
                
    CurrentAns = {num2str(oldPosition(3)),...
                num2str(aspectRatio),...
                num2str(mksize),...                
                num2str(lnwidth),...
                num2str(axwidth),...
                num2str(ticklength),...
                num2str(fontsize),...
                myfont};
            
    figureParameterValues = inputdlg(propertyNames,dlg_title,1,CurrentAns);
    
    % Reset figure parameter values with inputed values
    width       = str2double(figureParameterValues{1});
    aspectRatio = str2double(figureParameterValues{2});
    mksize      = str2double(figureParameterValues{3});
    lnwidth     = str2double(figureParameterValues{4});
    axwidth     = str2double(figureParameterValues{5});
    ticklength  = str2double(figureParameterValues{6});
    fontsize    = str2double(figureParameterValues{7});
    myfont      = figureParameterValues{8};
   
end

%% Modify the figure

% make the background white
set(fignum,'color','w');

% turn off box and change tic direction
box off
set(gca,'TickDir','out');

% Change figure position and size
left = oldPosition(1);
bottom = oldPosition(2);
set(gcf,'Position', [left, bottom, width, width/aspectRatio]);

% identify the subplots
a=get(fignum,'Children')';


k=0;
for i=fliplr(a)
    k=k+1;
    %% Set the linewidths and marker sizes
    
    % find all the lines on this axis
    dataline = findobj(i,'Type','line');

    % cycle through the lines on this axis
    for j = dataline'
        % set the linewidth
        set(j,'LineWidth',lnwidth);
        % set the marker size
        mkr = get(j,'Marker');
        if ~strcmp(mkr,'none')
            mkrsz = get(j,'MarkerSize');
            if mkrsz <= mksize, set(j,'MarkerSize',mksize); end
            if strcmp(mkr,'.')
                if mkrsz <= mksizept, set(j,'MarkerSize',mksizept); end
            end
        end
    end
    
    % find points for 3D scatter plot
    scatterpoints = findobj(i,'Type','scatter');

    % cycle through the lines on this axis
    for j = scatterpoints'
        % set the linewidth
        set(j,'LineWidth',lnwidth);
        % set the marker size

        mkr = get(j,'Marker');
        if ~strcmp(mkr,'none')
            mkrsz = get(j,'SizeData');
            if mkrsz <= mksize*8, set(j,'SizeData',mksize*8); end
            if strcmp(mkr,'.')
                if mkrsz <= mksizept*8, set(j,'SizeData',mksizept*15); end
            end
        end
    end
    
   % Find bars from bar graphs 
    bars = findobj(i,'Type','bar');
    for j = bars'
        % set the linewidth
        set(j,'LineWidth',baredge);
        % set the marker size
    end
    
   % Find histogram bars
    histo = findobj(i,'Type','patch');
    for j = histo'
        % set the linewidth
        set(j,'LineWidth',baredge,'edgecolor',edgecolor);
        % set the marker size
    end
    
    % Surface Plots
    surface = findobj(i,'Type','Surface');
    for j = surface'
        % set the linewidth
        set(j,'LineWidth',baredge);
        % set the marker size
    end
    
    % Error Bars
    Ebar = findobj(i,'Type','ErrorBar');
    for j = Ebar'
        % set the linewidth
        set(j,'LineWidth',lnwidth);
        % set the marker size
    end  
    %% Set Font sizes
    
    % if there is text on the plot, find it and enlarge it
    datatext = findobj(i,'Type','text');
    
    % Check if data type is new illustration type.Legend used to be an axis
    %, but in v2014b this was changed. 
    if isa (i,'matlab.graphics.illustration.Legend')
        set(i,'color','none')
        set(i,'Box','off')
        set(i,'FontSize',fontsize,'FontWeight',fweight,'FontName',myfont,'Textcolor',fontcolor);
    
    else 
        ax =gca;
        ax.LineWidth = axwidth;
        ax.TickLength = [ticklength,ticklength];
        for p = datatext'
            % set the font
            set(p,'FontSize',fontsize,'FontWeight',fweight,'FontName',myfont,'Color',fontcolor);
        end

        %axes(i); % specify the subplot
        set(fignum,'CurrentAxes',i);

        % axis values and legend text
        set(i,'FontSize',fontsize,'FontWeight',fweight,'FontName',myfont,...
            'Xcolor',fontcolor,'Ycolor',fontcolor,'Zcolor',fontcolor)

        % title
        set(get(i,'Title'),'FontSize',fontsize*1.2,'FontWeight',fweight,'FontName',myfont,'Color',fontcolor)

        % x axis label
        set(get(i,'XLabel'),'FontSize',fontsize,'FontWeight',fweight,'FontName',myfont)

        % y axis label
        set(get(i,'YLabel'),'FontSize',fontsize,'FontWeight',fweight,'FontName',myfont)

        % z axis label
        set(get(i,'ZLabel'),'FontSize',fontsize,'FontWeight',fweight,'FontName',myfont)


    end

end

return
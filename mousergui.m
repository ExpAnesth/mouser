function mousergui
% ** function mousergui
% Graphical user interface for display of mouse colony data as listed in a
% spreadsheet 

% -------------------------------------------------------------------------
% Version 0.2, April 2019
% (C) Harald Hentschke (University of T�bingen)
% -------------------------------------------------------------------------

% Here, layout of all gui elements (knobs, buttons, etc.) should be done

labelscale('fontSz',8,'scaleFac',1.0,'lineW',.25,'markSz',6); 
% standard dimension of edit fields
editw=.08;
edith=.032;
% standard dimensions of buttons
butt1x=.08;
butt1y=.04;
butt2x=.16;
butt2y=.08;

% elementary delta y given height of text fields and smaller buttons
dy=.036;
% standard text field width (at least as wide as big buttons)
textw=.16;
% standard margin for major divisions of figure (like plots and groups of buttons)
smarg=.025;

% left alignment lines in ascending order
la1=smarg;
% left border left-aligned subplots
la2=la1+textw+smarg;
% left border of right subplot 
la3=(1-la2+smarg)/2+la2;

% vertical separators from top to bottom
ba1=.96;
ba2=.55;
ba11=.33;

% font sizes
fsz=8;
fsz_big=11;

% if gui exists from previous session, delete it
tmph=findobj('Tag','mousergui','type','figure');
if ~isempty(tmph)
  delete(tmph);
end

% the collection of routines associated with most button callbacks
funcH1=@mouserguifunc;

% create GUI window
H0 = figure('Units','normalized', ...
   'Color',[.9 .9 .9], ...
   'Name','Colony overview', ...
   'NumberTitle','off', ...
   'Position',[0.005 0.25 0.99 0.7], ...
   'Tag','mousergui',...
   'MenuBar','none',...
   'Toolbar','figure',...
   'DeleteFcn',{funcH1,{'done'}}...
);

h1 = uicontrol('Parent',H0, ...
  'Units','normalized', ...
  'HorizontalAlignment','left', ...    
  'Position',[la1 ba1-1*butt2y butt2x butt2y], ...
  'FontSize',fsz_big, ...
  'Fontweight','bold',...
  'style','pushbutton',...
  'String','read data', ...
  'TooltipString','',...
  'Tag','readDataBttn',...
  'callback', {funcH1,{'readData'}});  

% invisible button for future use
h1 = uicontrol('Parent',H0, ...
  'Units','normalized', ...
  'HorizontalAlignment','left', ...    
  'Position',[la1 ba1-2*butt2y butt2x butt2y], ...
  'FontSize',fsz_big, ...
  'Fontweight','bold',...
  'style','pushbutton',...
  'String','', ...
  'TooltipString','',...
  'Tag','nothing',...
  'visible', 'off',...
  'callback', {funcH1,{'nothing'}});  

h1 = uicontrol('Parent',H0, ...
  'Units','normalized', ...
  'HorizontalAlignment','left', ...    
  'Position',[la1 ba1-6*butt1y butt2x butt1y], ...
  'FontSize',fsz, ...
  'Fontweight','normal',...
  'style','checkbox',...
  'value',1,...
  'String','breeding pairs', ...
  'TooltipString','',...
  'Tag','doPlotBreedingPairs',...
  'callback', {funcH1,{'plot'}});  

h1 = uicontrol('Parent',H0, ...
  'Units','normalized', ...
  'HorizontalAlignment','left', ...    
  'Position',[la1 ba1-7*butt1y butt2x butt1y], ...
  'FontSize',fsz, ...
  'Fontweight','normal',...
  'style','checkbox',...
  'value',0,...
  'String','''life lines''', ...
  'TooltipString','',...
  'Tag','doPlotLifeLines',...
  'callback', {funcH1,{'plot'}});  

% Set up the subplots and don't forget to tag them so they can be identified 
% (plots need larger margins because of axes labels)
% - overview 
sp.ov.axH=subplot('position',[la2  0.0+smarg  1-la2-smarg  1.0-2*smarg]);
set(sp.ov.axH,'tag','overview','NextPlot','add');
% - info
sp.textInfo.axH=subplot('position',[la1  0.0+smarg  butt2x  0.5-2*smarg]);
set(sp.textInfo.axH,'tag','textInfo');


mouserguifunc(H0,[],{'init'},'sp',sp);


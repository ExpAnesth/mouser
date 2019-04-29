function wp=mousergui_ini(wp)
% ** function function wp=mousergui_ini(wp)
% User-defined settings for mousergui.m
% -------------------------------------------------------------------------
% Version 0.1, Jan 2015
% (C) Harald Hentschke (University of Tübingen)
% -------------------------------------------------------------------------

% standard background color of subplots in main figure window
wp.stdAxCol=[.7 .7 .8];
% the number of lines in spreadsheet occupied by headers describing
% the columns
wp.nHeaderLines=7;
% this is the format in which dates appear in the excel table - will
% require adjustment according to the computer's language/region
% settings
wp.dateFormat='dd.mm.yyyy';
% wp.dateFormat='mm/dd/yyyy';
% the date format for the x axis of the main plot
wp.abscissaDateFormat='mmmyy';
% the default directory in which to look for data
wp.dataPath='d:\hh\labwork-techdoc\animalExperimentation\';


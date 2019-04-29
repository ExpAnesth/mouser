# mousergui

is a graphical user interface for the display of mouse colony data as listed in an Excel spreadsheet. It has been designed for small mouse colonies of up to maybe 100-200 animals; for larger colonies neither display nor speed will be satisfactory.

![screenshot](/doc/screenshot_mouser.png)

### Features: 
* reading of selectable sheet of Excel file
* display of individual animals' ID, sex, genotype, date of birth and status (dead or alive) along time axis
* optionally, additional display of 'life line' and matings

Please note that the code in this repository is not self-sufficient, you'll additionally need the following repositories:
* etslfunc
* graphics
* utilities

No Matlab toolboxes required.

## General note on repositories in the ExpAnesth organization
The code in these repositories provides basic tools for the analysis of electrophysiological time series to members of the Section of Experimental Anesthesiology, Department of Anesthesiology, University Hospital of Tuebingen. Except where noted, code was written by Harald Hentschke. It has been designed primarily for in-house use by individuals who were instructed on its scope and limitations. Also, a substantial proportion of the code has been developed and extended over a time span of >10 years. In detail,

* the implementation of algorithms reflects the evolution of Matlab itself, that is, code that had been initially developed on older versions of Matlab does not necessarily feature newer techniques such as the new automatic array expansion as introduced in Matlab Release 2016b
* nonetheless, all code has been tested to run on Matlab R2018b
* while most m-files contain ample comments, documentation exists only for a few repositories
* checks of user input are implemented to varying degrees
* the code will be improved, updated and documented when and where the need arises
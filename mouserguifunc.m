function mouserguifunc(src,eventdata,job,varargin)
% ** function mouserguifunc(src,eventdata,job,varargin)
% Collection of callback routines for mousergui.m
%                         >>> INPUT VARIABLES >>>
%
% NAME             TYPE/DEFAULT          DESCRIPTION
% job              cell array of char    jobs to accomplish
% sp               struct                handles to subplots of main
%                                         figure
%

% -------------------------------------------------------------------------
% Version 0.1, Jan 2015
% (C) Harald Hentschke (University of Tübingen)
% -------------------------------------------------------------------------

% to do:
% - click on bp line displays IDs of breeding pair/breeding cage
% - compute degree of inbreeding for present and planned pairs??
% - adapt symbol size, line width, modulo and step size for yPos to
%   number of animals to be plotted
% - option to display only active breeding pairs 
% - query: animals fulfilling certain criteria (age, genotype, etc.)
      

% We need some persistent data:
%   wp='working parameters' (like colors)
%   sp=subplot handles
persistent wp sp animalPar breedPair



pvpmod(varargin);
etslconst;

jobsToDo=true;
while jobsToDo
  
  partJob=job{1};
  switch partJob
    case 'init'
      % *******************************************************************
      % in this ini job, all fields of wp are set up
      % *******************************************************************
      % ----- set up major variables 
      d=[];
      % data file name - uigetfile returns 0 as output arguments if the
      % cancel button is hit, so use these as initializing values
      wp.dataFn=0;
      % --------------------------------------
      % ----- set up wp ('working' parameters)
      % --------------------------------------      
      % ~~~~~~~ display options & matlab version section
      % which version of matlab?
      wp.mver=ver;
      wp.mver=str2double(wp.mver(strmatch('matlab',lower({wp.mver.Name}),'exact')).Version);
      % which version of mousergui?
      wp.ver=1.0;
      % handles to main window and its children
      wp.mainFigureHandle=findobj('Tag','mousergui','type','figure');
      wp.mainGuiHandles=guihandles(wp.mainFigureHandle);
      % date & formats
      wp.nowDateNum=now;
      % now call mousergui_ini, which will append a few
      % user/region/computer-specific fields to wp
      wp=mousergui_ini(wp);
      % --------------------------------------
      % ----- initialize subplots
      % --------------------------------------      
      % -- overview 
      subplot(sp.ov.axH), cla, hold on
      set(sp.ov.axH,'color',wp.stdAxCol,...
        'defaultlinemarkersize',16,'defaultlinelinewidth',2);
      % -- text info
      subplot(sp.textInfo.axH), 
      set(sp.textInfo.axH,'color',wp.stdAxCol,'xtick',[],'ytick',[]);
      box on
      job(1)=[];
      
    case 'readData'
      % read excel worksheet listing animals, check the data and fill
      % appropriate fields of 'animalPar'
      % delete/reset results/plots/variables from last file/channel
      d=[];
      % call the m-file in which columns in the spreadsheet are defined
      % (this deletes the previous instance of animalPar, if any)
      animalPar=mouser_defdata;
      % find indexes to the elements of animal par and make them fields of
      % wp because we need them all over the place
      wp.IDIx=find(strcmp('ID',{animalPar.name}));
      wp.animalLineIx=find(strcmp('animalLine',{animalPar.name}));
      wp.sexIx=find(strcmp('sex',{animalPar.name}));
      wp.genotypeIx=find(strcmp('genotype',{animalPar.name}));
      wp.dateBirthIx=find(strcmp('dateBirth',{animalPar.name}));
      wp.dateMatingIx=find(strcmp('dateMating',{animalPar.name}));
      wp.IDParentsIx=find(strcmp('IDParents',{animalPar.name}));
      wp.breedCageIx=find(strcmp('breedCage',{animalPar.name}));
      wp.dateDispensIx=find(strcmp('dateDispens',{animalPar.name}));
      wp.dateDeathIx=find(strcmp('dateDeath',{animalPar.name}));
      
      % wipe plots
      cla(sp.ov.axH);
      cla(sp.textInfo.axH);
      % should reading data fail for any reason, be done
      job(1)=[];
      % read spreadsheet data
      [tmpDataFn,tmpDataPath] = uigetfile({'*.xlsx';'*.xls'},'pick data file',wp.dataPath);
      if ischar(tmpDataFn) && ischar(tmpDataPath)
        wp.dataFn=tmpDataFn;
        wp.dataPath=tmpDataPath;
        [stat,sheetName]=xlsfinfo([wp.dataPath wp.dataFn]);
        if isempty(stat)
          warning('cannot read file')
        else
          % decide which sheet to read
          shIx=picklistitem(char(sheetName),'defaultVal',1);
          % the number of parameters describing the animals
          nPar=length(animalPar);
          % put into wp so that we know how many original parameters there
          % are
          wp.nOriginalPar=nPar;
          [num,cha,d] = xlsread([wp.dataPath wp.dataFn],shIx);
          % remove column headers from d
          d(1:wp.nHeaderLines,:)=[];
          % now the size of d reflects data content of the spreadsheet
          [n1,n2]=size(d);
          % --- perform some global checks
          if n2~=nPar
            errordlg({'The data sheet contains too few or too many columns (this may be due to a ''stray cell'' inadvertently filled with a value).';...
              'Please see template_mouser.xls or mouser_defdata.m for a definition of columns'});
            error('see error window for a description of the problem');
          end
          % now transfer data to animalPar
          for g=1:nPar
            switch animalPar(g).dType
              case 'char'
                tmp=d(:,g);
                % replace empty cells by sth. (NOT empty string)
                for gg=1:n1
                  if any(isnan(tmp{gg})) || isempty(tmp{gg}) || all(isspace(tmp{gg}))
                    tmp{gg}='nil';
                  end
                end
                % get rid of leading and trailing whitespace
                tmp=strtrim(tmp);
                animalPar(g).d=tmp;
              case 'double'
                tmp=cat(1,d{:,g});
                if ~isnumeric(tmp)
                  error(['parameter ' animalPar(g).name ' should be numeric but is not']);
                end
                animalPar(g).d=tmp;
              otherwise
                error('illegal animalPar.dType')
            end
          end
          
          % ***************************************************************
          % in the following, entries in the sheet will be checked for
          % consistency; in the process, new fields of animalPar will be
          % created which greatly facilitate dealing with the data.
          % ***************************************************************
          
          % - first thing: line number in data sheet; displaying this line
          % in error messages may facilitate fixing faulty entries
          g=numel(animalPar)+1;
          animalPar(g).name='sheetLine';
          animalPar(g).dType='double';
          animalPar(g).d=(1:n1)'+wp.nHeaderLines;
          wp.sheetLineIx=g;
          
          % - delete all entries without a birth date - these are most
          % likely 'stray lines' which do not contain valid data
          delIx=find(strcmp('nil',animalPar(wp.dateBirthIx).d));
          if ~isempty(delIx)
            disp(['the following lines in the data sheet do not contain a birth date and are therfore eliminated: ',...
              int2str(animalPar(wp.sheetLineIx).d(delIx)')]);
            [animalPar,n1]=cleanAnimalPar(animalPar,delIx);
          end
          
          % error if there are duplicate IDs
          tmpID=sort(animalPar(wp.IDIx).d);
          duplicateIx=find(~diff(tmpID));
          if ~isempty(duplicateIx)
            errordlg({'Duplicate animal IDs found: ',...
              int2str(tmpID(duplicateIx)')});
            error('see error window for a description of the problem');
          end
          
          % - logical array indicating bred animals (those without a
          % preceding '$' in the corresponding parent ID column)
          g=numel(animalPar)+1;
          animalPar(g).name='isBred';
          animalPar(g).dType='logical';
          animalPar(g).d=find(~strncmp('$',animalPar(wp.IDParentsIx).d(:,1),1));
          wp.isBredIx=g;

          % from the cell array of strings listing the parent IDs generate
          % a n-by-2 double array of the IDs:
          g=numel(animalPar)+1;
          animalPar(g).name='IDParents_num';
          animalPar(g).dType='double';
          % preallocate with nans
          animalPar(g).d=nan(n1,2);
          wp.IDParents_numIx=g;
          % - first, pick all entries for bred animals, replace ampersand
          % and convert to char
          tmpParentID=char(regexprep(animalPar(wp.IDParentsIx).d(animalPar(wp.isBredIx).d),'&',' '));
          % - convert line by line, collecting those with problems
          problemID=[];
          for aIx=1:size(tmpParentID,1)
            % index to current bred animal within full data set 
            helpIx=animalPar(wp.isBredIx).d(aIx);
            % try to convert chars to integers
            [tmpNum,count]=sscanf(tmpParentID(aIx,:),'%u');
            if count==2
              animalPar(g).d(helpIx,:)=sort(tmpNum);
            else
              problemID=[problemID  animalPar(wp.IDIx).d(helpIx)];
            end
          end
          if ~isempty(problemID)
            errordlg({'Bred animals with the following IDs have non-identifiable parent IDs: ',...
              int2str(problemID)});
            error('see error window for a description of the problem');
          end
          % now, check whether parents are in data base
          problemID=setdiff(unique(animalPar(g).d(animalPar(wp.isBredIx).d,:)),...
            animalPar(wp.IDIx).d);
          if ~isempty(problemID)
            errordlg({'The following parent IDs are not in the data set: ',...
              int2str(problemID)});
            error('see error window for a description of the problem');
          end        
  
          % ** the list of breeding PAIRS (not cages) as deduced from
          % the animals' parent IDs
          breedPair.parentID=unique(animalPar(wp.IDParents_numIx).d(animalPar(wp.isBredIx).d,:),'rows');
          % don't forget to sort
          breedPair.parentID=sort(breedPair.parentID,2);
          
          % ** now determine breeding pairs as explicitly specified in
          % terms of breeding cages:
          % - index to animals in breeding cages
          bcIx=find(isfinite(animalPar(wp.breedCageIx).d));
          % - breeding cage numbers without repetitions
          bCage=unique(animalPar(wp.breedCageIx).d(bcIx));
          % - list of parent animal IDs (pairs in rows)
          tmpParentID=[];
          % container for breeding cage numbers with problems
          problemBc=[];
          for bpi=1:numel(bCage)
            % extract animal IDs belonging to current breeding pair and
            % check gender
            tmpIx=find(animalPar(wp.breedCageIx).d==bCage(bpi))';
            if numel(tmpIx)==2 && isempty(setdiff(lower(animalPar(wp.sexIx).d(tmpParentID)),{'f','m'}))
              tmpParentID=[tmpParentID; tmpIx];
            else
              problemBc=[problemBc bCage(bpi)];
            end
          end
          % error if there are unmatched/same sex breeding pairs
          if ~isempty(problemBc)
            errordlg({'The following breeding pairs do not consist of one male and one female: ',...
              int2str(problemBc)});
            error('see error window for a description of the problem');
          end
          tmpParentID=sort(tmpParentID,2);
          % ** now consolidate both lists:
          breedPair.parentID=unique(cat(1,breedPair.parentID,tmpParentID),'rows');


          % - generate datenums of all dates
          % -- birth date
          g=numel(animalPar)+1;
          animalPar(g).name='dateBirth_num';
          animalPar(g).dType='double';
          try
            animalPar(g).d=datenum(animalPar(wp.dateBirthIx).d,wp.dateFormat);
          catch
            dateErrorMsg('At least one birth date is not properly formatted!',...
              animalPar(wp.dateBirthIx).d{1},wp);
          end
          wp.dateBirth_numIx=g;

          % -- mating date
          g=numel(animalPar)+1;
          animalPar(g).name='dateMating_num';
          animalPar(g).dType='double';
          % preallocate with nans
          animalPar(g).d=nan(n1,1);
          % index to valid entries
          tmpIx= ~strcmp('nil',animalPar(wp.dateMatingIx).d);
          if any(tmpIx)
            try
              animalPar(g).d(tmpIx)=datenum(animalPar(wp.dateMatingIx).d(tmpIx),wp.dateFormat);
            catch
              dateErrorMsg('At least one mating date is not properly formatted!',...
                animalPar(wp.dateMatingIx).d{1},wp);            
            end
          end
          wp.dateMating_numIx=g;
          
          % -- exit date: death or dispensal
          g=numel(animalPar)+1;
          animalPar(g).name='dateExit_num';
          animalPar(g).dType='double';
          % preallocate with nans
          animalPar(g).d=nan(n1,1);
          % index to valid entries
          tmpIx= ~strcmp('nil',animalPar(wp.dateDeathIx).d);
          if any(tmpIx)
            try
              animalPar(g).d(tmpIx)=datenum(animalPar(wp.dateDeathIx).d(tmpIx),wp.dateFormat);
            catch
              dateErrorMsg('At least one death date is not properly formatted!',...
                animalPar(wp.dateDeathIx).d{1},wp);
            end
          end
          wp.dateExit_numIx=g;
          % repeat for dispensal such that the entries in dateExit_num
          % reflect exist due to any cause (§ note that we're overwriting
          % values here without check)
          tmpIx= ~strcmp('nil',animalPar(wp.dateDispensIx).d) ;
          if any(tmpIx)
            try
              animalPar(g).d(tmpIx)=datenum(animalPar(wp.dateDispensIx).d(tmpIx),wp.dateFormat);
            catch
              dateErrorMsg('At least one dispensal date is not properly formatted!',...
                animalPar(wp.dateDispensIx).d{1},wp);
            end
          end
          clear tmp*
          job(1)={'plot'};    
        end
      end
      

      
    case 'plot'
      
      % each animal is represented by a filled symbol at its day of birth
      % (dob) and optionally a horizontal 'life line' extending up to its
      % last day of existence in the colony. Breeding pairs are connected
      % via straight lines meeting at mating date.
      
      % characteristics that are plotted
      % sex - symbol
      % date of birth - abscissa value
      % genetic state - fill color
      % dead or alive - markercolor (and presence of life line)
      % mating date (if any) - abscissa value of crossing of lines
      % ID - text?
      % ancestors - yellow stars popping up
      
      if ~isempty(animalPar)
        % enquire status of tickboxes and set flags accordingly:
        % - set flag for plotting life lines
        doPlotLifeLines=get(wp.mainGuiHandles.doPlotLifeLines,'value');
        % - set flag for plotting breeding pairs
        doPlotBreedingPairs=get(wp.mainGuiHandles.doPlotBreedingPairs,'value');
        
        % - number of animals in current list
        nAnimal=size(animalPar(wp.IDIx).d,1);
        
        % - preparations for plotting:
        % -- array of marker types (gender-dependent; preallocate with
        % diamonds for unknown gender)
        mType=repmat('d',nAnimal,1);
        % males: squares
        tmpIx=strcmpi('m',lower(animalPar(wp.sexIx).d));
        if any(tmpIx)
          mType(tmpIx)='s';
        end
        % females: circles
        tmpIx=strcmpi('f',lower(animalPar(wp.sexIx).d));
        if any(tmpIx)
          mType(tmpIx)='o';
        end
        % -- face color (genetics; preallocate with gray for undefined status)
        mFaceColor=repmat([.7 .7 .7],nAnimal,1);
        % WT: white
        tmpIx=strcmpi('wt',lower(animalPar(wp.genotypeIx).d));
        if any(tmpIx)
          mFaceColor(tmpIx,:)=repmat([1 1 1],sum(tmpIx),1);
        end
        % hemizygotes: light green
        tmpIx=strcmpi('he',lower(animalPar(wp.genotypeIx).d));
        if any(tmpIx)
          mFaceColor(tmpIx,:)=repmat([.6 1 .6],sum(tmpIx),1);
        end
        % homozygotes: green 
        tmpIx=strcmpi('ho',lower(animalPar(wp.genotypeIx).d));
        if any(tmpIx)
          mFaceColor(tmpIx,:)=repmat([.1 .7 .1],sum(tmpIx),1);
        end
        % outline color (animal available (black) or gone (for whatever
        % reason, light gray))
        mColor=repmat([0 0 0],nAnimal,1);
        tmpIx=isfinite(animalPar(wp.dateExit_numIx).d);
        if any(tmpIx)
          mColor(tmpIx,:)=repmat([.6 .6 .6],sum(tmpIx),1);
        end
        nAliveAnimals=sum(~tmpIx);
        
        % -- y position of symbol and line representing animals in the plot
        mYPos=mod(3*animalPar(wp.IDIx).d,131);
        % -- x position of symbol representing animals in the plot
        mXPos=animalPar(wp.dateBirth_numIx).d;
        % -- x END position of line representing animals in the plot
        lXPos=animalPar(wp.dateExit_numIx).d;
        
        ID=animalPar(wp.IDIx).d;
        IDParents=animalPar(wp.IDParents_numIx).d;
        
        
        % here would be a good spot to retrieve some stats on the animals:
        % % average age of animals in weeks (all):
        % nanmean(diff([mXPos lXPos],1,2))/7
        % % number of females (all animals):
        % sum(strcmp(animalPar(3).d,'F'))
        
        % ------------ plot
        axes(sp.ov.axH);
        cla
        
        % loop over animals to be able to set individual callbacks
        ph=nan(nAnimal,1);
        lh=nan(nAnimal,1);
        for g=1:nAnimal
          % life line first, if desired (with a little y jitter)
          if doPlotLifeLines
            lh(g)=line([mXPos(g) lXPos(g)],mYPos(g)*[1 1]+(rand-.5)*.1);
            set(lh(g),'color',mColor(g,:));
          end
          ph(g)=plot(mXPos(g),mYPos(g),mType(g));
          set(ph(g),'color',mColor(g,:),'markerfacecolor',mFaceColor(g,:));
          % user data: [ID, xpos(parent1), xpos(parent2), ypos(parent1),
          % ypos(parent2)] 
          % §§ if only one parent is in list, omit the other
          if all(isfinite(IDParents(g,:)))
            ud=[ID(g) mXPos(IDParents(g,:))' mYPos(IDParents(g,:))'];
          else
            ud=[ID(g) nan(1,4)];
          end
          set(ph(g),'userdata',ud);
          % callback: recursive call of mouserguifunc
          set(ph(g),'ButtonDownFcn',{@mouserguifunc,{'displayInfo','showAncestors'}});
          % add ID
          th=text(mXPos(g),mYPos(g),int2str(ID(g)));
        end
        
        nAliveBreedingPairs=0;
        % plot of breeding pairs, if requested
        if doPlotBreedingPairs
          nBp=size(breedPair.parentID,1);
          % avoid shades of gray by making a colormap about 30% larger than
          % the acutal number of breeding pairs
          bpCol=colorcube(max(10,ceil(nBp*1.30)));
          bpPh=nan(nBp,1);
%           for uix=1:nBp
%             % retrieve ...
%             tmpIx=[find(ID==breedPair.parentID(uix,1)),find(ID==breedPair.parentID(uix,2))];
%             % both ends of the line connecting individuals in a breeding
%             % pair shall course horizontally to the date of mating and
%             % there be connected vertically
%             xtra=animalPar(wp.dateMating_numIx).d(tmpIx);
%             % if for whatever reason mating date is not in list, there will
%             % be nans = no line will be drawn
%             xco=[mXPos(tmpIx(1));xtra;mXPos(tmpIx(2))];
%             yco=mYPos(tmpIx([1 1 2 2]));
%             % symbols
%             bpPh(uix)=plot(mXPos(tmpIx),mYPos(tmpIx),'k+');
%             % lines 
%             bpPh(uix)=plot(xco,yco,'k-');
%           end
          

          for uix=1:nBp
            % retrieve ...
            tmpIx=[find(ID==breedPair.parentID(uix,1)),find(ID==breedPair.parentID(uix,2))];
            % on the occasion, count number of alive bp
            nAliveBreedingPairs=nAliveBreedingPairs+...
              all(isnan(animalPar(wp.dateExit_numIx).d(tmpIx)));
            % both ends of the line connecting individuals in a breeding
            % pair shall course to the date of mating and there be
            % connected
            xtra=animalPar(wp.dateMating_numIx).d(tmpIx(1));
            % if for whatever reason mating date is not in list, there will
            % be nans = no line will be drawn
            xco=[mXPos(tmpIx(1));xtra;mXPos(tmpIx(2))];
            yco=[mYPos(tmpIx(1));mean(mYPos(tmpIx));mYPos(tmpIx(2))];
            % symbols
            tmpPh=plot(xco,yco,'k.');
            set(tmpPh,'color',bpCol(uix,:));
            % lines 
            bpPh(uix)=plot(xco,yco,'k-');
            set(bpPh(uix),'color',bpCol(uix,:));
            % userdata: {of all progeny [ID | x pos | ypos], handle to plot
            % showing progeny or []}
            progIx=all(isfinite(animalPar(wp.IDParents_numIx).d),2) & ...
              ~any(animalPar(wp.IDParents_numIx).d-repmat(tmpIx,[nAnimal 1]),2);
            set(bpPh(uix),'userdata',{[ID(progIx) mXPos(progIx) mYPos(progIx)],[]});
            % callback: recursive call of mouserguifunc
            set(bpPh(uix),'ButtonDownFcn',{@mouserguifunc,{'showProgeny'}});
          end
        end
        nicexyax;
        % info string
        smarttext(['no. alive animals: ' int2str(nAliveAnimals) '; no. active breeding pairs: ' int2str(nAliveBreedingPairs)],.05,.95,'fontsize',14);
        % axes
        set(sp.ov.axH,'ytick',[]);
        % time axis: convert to dates
        datetick('x',wp.abscissaDateFormat);
      end
      
      job(1)=[];

    case 'displayInfo'
      curID=get(src,'userdata');
      % animal's ID is in first place
      curID=curID(1);
      aIx=find(animalPar(wp.IDIx).d==curID);
      if isempty(aIx)
        txt={'ID not found'};
      else
        % restrict to meaningful ones
        for g=1:wp.nOriginalPar 
          if strcmp(animalPar(g).dType,'double')
            txt{g}=[animalPar(g).name ': ' num2str(animalPar(g).d(aIx))];
          else
            txt{g}=[animalPar(g).name ': ' animalPar(g).d{aIx}];
          end            
        end
      end
      axes(sp.textInfo.axH);
      cla
      smarttext(txt,0.03,0.97,'verticalalignment','top');
      job(1)=[];
      
    case 'showProgeny'
      ud=get(src,'userdata');
      axes(sp.ov.axH);
      if isempty(ud{2})
        progeny=ud{1};
        ph=plot(progeny(:,2),progeny(:,3),'+');
        set(ph,'color',get(src,'color'));
        ud{2}=ph;
      else
        delete(ud{2});
        ud{2}=[];
      end
      set(src,'userdata',ud);
      job(1)=[];

    case 'showAncestors'
      curParentXY=get(src,'userdata');
      axes(sp.ov.axH);
      % parents' coordinates are in elements 2:5
      ph=plot(curParentXY(:,2:3),curParentXY(:,4:5),'yp');
      pause(1);
      delete(ph);
      job(1)=[];

    case 'done'
      disp('bye...');
      clear global
      job(1)=[];
      
    case 'nothing'
      disp('second button has no function yet')
      job(1)=[];

    otherwise
      error(['internal:illegal job:' partJob]);
      
  end
  drawnow
  jobsToDo= ~isempty(job);
end


function [par,nRow]=cleanAnimalPar(par,delIx)
for g=1:numel(par)
  par(g).d(delIx)=[];
end
nRow=size(par(1).d,1);

function dateErrorMsg(errmsg,dString,wp)
errordlg({errmsg,...
  'First entry in spreadsheet:',...
  ' ',...
  dString,...
  ' ',...
  'Assumed format (as given in mousergui_ini.m):', ...
  ' ',...
  wp.dateFormat});
error('see error dialog')


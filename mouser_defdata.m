function animalPar=mouser_defdata
% ** function animalPar=mouser_defdata
% generates structure array animalPar with as many elements as columns of
% an excel worksheet to be read by mouserguifunc.m. The definition of the
% columns of the worksheet is in the body of the function.

% -------------------------------------------------------------------------
% Version 0.1, Jan 2015
% (C) Harald Hentschke (University of Tübingen)
% -------------------------------------------------------------------------

% *************************************************************************
% Below is the definition of columns in the worksheet. Don't change.
% *************************************************************************
g=1;
animalPar(g).name='ID';
animalPar(g).dType='double';

g=g+1;
animalPar(g).name='animalLine';
animalPar(g).dType='char';

g=g+1;
animalPar(g).name='sex';
animalPar(g).dType='char';

g=g+1;
animalPar(g).name='genotype';
animalPar(g).dType='char';

g=g+1;
animalPar(g).name='dateBirth';
animalPar(g).dType='char';

g=g+1;
animalPar(g).name='dateMating';
animalPar(g).dType='char';

g=g+1;
animalPar(g).name='IDParents';
animalPar(g).dType='char';

g=g+1;
animalPar(g).name='breedCage';
animalPar(g).dType='double';

% dispensal
g=g+1;
animalPar(g).name='dateDispens';
animalPar(g).dType='char';

g=g+1;
animalPar(g).name='recipDispens';
animalPar(g).dType='char';

% death
g=g+1;
animalPar(g).name='dateDeath';
animalPar(g).dType='char';

g=g+1;
animalPar(g).name='causeDeath';
animalPar(g).dType='char';

% identification marks 
g=g+1;
animalPar(g).name='leftEarMark';
animalPar(g).dType='char';

g=g+1;
animalPar(g).name='rightEarMark';
animalPar(g).dType='char';

% finally, comment
g=g+1;
animalPar(g).name='comment';
animalPar(g).dType='char';


% -------- complement animalPar ------------------------
nPar=length(animalPar);
charIx=strmatch('char',strvcat(animalPar.dType));
numIx=setdiff(1:nPar,charIx);
% append fields to animalPar and set to nan or '' depending on type
[animalPar(charIx).normVal]=deal('');
[animalPar(charIx).min]=deal('');
[animalPar(charIx).max]=deal('');
[animalPar(charIx).purgeVal]=deal('');
[animalPar(numIx).normVal]=deal(nan);
[animalPar(numIx).min]=deal(nan);
[animalPar(numIx).max]=deal(nan);
[animalPar(numIx).purgeVal]=deal(nan);

% [DiffMat, DiffMatSig] = diffCoeffAll(timestrMult, plotflag, verbose,savename );
% Wrapper for diffCoeffCalc that analyzes all the files in the msdfiles folder.
% All these files need the same grid and trials. The parameters from the files
% should form a grid ( # bind energy) X ( # ffo )

function [DiffMat, DiffMatSig] = ...
  diffCoeffAll( timestrMult, plotflag, verbose, savename )

if nargin == 0
  timestrMult = 1;
  plotflag = 0;
  verbose = 0;
  saveflag = 0;
elseif nargin == 1
  plotflag = 0;
  verbose = 0;
  saveflag = 0;
elseif nargin == 2
  verbose = 0;
  saveflag = 0;
elseif nargin == 3
  saveflag = 0;
else
  saveflag = 1;
end

% Flag for infinite binding
isInfFlag = 0;

cd ~/McHydro/
% Add paths
addpath('~/McHydro/src')
addpath('~/McHydro/msdfiles')

fprintf('Startng diffCoeffAll. Analyzing all files in ./msdfiles \n');
% diffcoeffCal inputs

% Output directory
if ~exist('figs','dir'); mkdir('figs'); end;
if ~exist('diffcalc','dir'); mkdir('diffcalc'); end;

% Grab all the files in the msd folder
msdLall = filelist( '.mat','./msdfiles');
totFiles  = length(msdLall);

% Find the number of parameter configurations
% Get trial information
tRunIdtfy    = msdLall{1}( strfind( msdLall{1}, '_t' ) : end );
bindRunIdtfy = msdLall{1}( ...
  strfind( msdLall{1}, 'bind' ) : strfind( msdLall{1},'_fo' ) - 1);
foRunIdtfy = msdLall{1}( ...
  strfind( msdLall{1}, 'fo' ) : strfind( msdLall{1},'_ft' ) - 1);
soRunIdtfy = msdLall{1}( ...
  strfind( msdLall{1}, 'so' ) : strfind( msdLall{1},'_st' ) - 1);

% Find all cell indices that have the same trial and run identifier 
% strfind goes through all cells and looks for the str while cellfunc
% applies 'isempty' to all strings;
uniquePind = find(~cellfun('isempty', strfind( msdLall, tRunIdtfy ) ));
msdLUnParam = msdLall(uniquePind);  % list of unique parameter files
numUnqParams = length(msdLUnParam); % number of unique parameter combinations
numSameBind = msdLall( ~cellfun('isempty',strfind( msdLall, bindRunIdtfy); 
numSameFFo = msdLall( ~cellfun('isempty',strfind( msdLall, foRunIdtfy); 
numSameSo = msdLall( ~cellfun('isempty',strfind( msdLall, soRunIdtfy); 
numBind = numUnqParams / ( numSameFFo * numSameSo );
numFFo = numUnqParams / ( numSameBind * numSameSo );
numSo = numUnqParams / ( numSameBind * numSameFFo );

if numBind == 1
  Param1 = 'ff obstacles';
  Param1s = 'ffo';
  Param2 = 'size obstacles';
  Param2s = 'so';
elseif numFFo == 1
  Param1 = 'binding energyff';
  Param1s = 'be';
  Param2 = 'size obstacles';
  Param2s = 'so';
elseif numSo == 1
  Param1 = 'binding energyff';
  Param1s = 'be';
  Param2 = 'ff obstacles';
  Param2s = 'ffo';
else
  error('Too many varying parameters')
end
  

% Calculate the number of trails
numTrials = totFiles / numUnqParams;


if floor(numTrials) ~= numTrials; 
  error('Varying trial number for parameter config');
end;

fprintf('%d total files. %d parameter configs. %d trials/config\n',...
  totFiles, numUnqParams, numTrials);

% Allocate memory for everything
% m(:,1) : be; m(:,2) = ff; m(:,3) = D m(:,4) = sig D
% m(:,1) : be; m(:,2) = so; m(:,3) = D m(:,4) = sig D
% m(:,1) : ff; m(:,2) = so; m(:,3) = D m(:,4) = sig D
BindFFDiff = zeros( numUnqParams ,  4); 

% cd into directory with msdfiles--- that's where diffcoeffCalc needs to be run
cd ./msdfiles

 for ii = 1:numUnqParams

    % Grab file and load it
    filename = msdLUnParam{ii};
    load( filename );
    if exist('paramlist','var')
      ffo  = floor( paramlist.ffo * 1e10 ) / 1e10;
      bindEn  = floor( paramlist.be * 1e10 ) / 1e10;
      sizeobs = paramlist.size_obst;
      clear paramlist % Just in case
    elseif exist('paramvec','var' )
      ffo = paramvec(1);
      bindEn = paramvec(4);
      sizeobs = paramlist.size_obst;
      clear paramvec % Just in case
    else
      error('I cannot find any parameters');
    end
    
    if verbose
      fprintf('ff = %.2g be = %.2g so=%d\n', ffo, bindEn, sizeobs);
    end
    
    if isinf( bindEn )
      timestart = 0 ;
      isInfFlag = 1;
    else
      timestart = timestrMult * max( exp( bindEn ) , exp(-bindEn) );
    end

    % If tstart is too large, make it equal to half the max run time
    % (arbitrary).
    tmax = dtime(end);
    if timestart > tmax / 2; timestart = tmax / 2; end;
    
    % Run diffcoeffcalc
    [Dout] = diffCoeffCalc( filename, timestart, plotflag, verbose );

    % Display it
    if verbose
      disp(Dout);
    end

    % Store it in mat
    if numSo == 1
      BindFFDiff(ii,1) = bindEn;
      BindFFDiff(ii,2) = ffo;
    elseif numBind == 1
      BindFFDiff(ii,1) = ffo;
      BindFFDiff(ii,2) = sizeobs;
    else 
      BindFFDiff(ii,1) = bindEn;
      BindFFDiff(ii,2) = sizeobs;
    end
      BindFFDiff(ii,3) = Dout.Dfit;
      BindFFDiff(ii,4) = Dout.DsigFit;

 end

% Sort it by binding energy
[~,I] = sort(BindFFDiff);
BindFFDiff = BindFFDiff( I(:,1), : );

% Move all figs to ~/McHydro/figs
if plotflag; movefile('*.fig', '~/McHydro/figs'); end;
cd ~/McHydro/

% Rearrang things into a more friendly matrix
% Find the number of binding energies
%beVec = uniquetol( BindFFDiff(:,1), 1e-9 );
%num_be = length(beVec);

p1vec = uniquetol( BindFFDiff(:,1), 1e-9 );
num_p1 = length(beVec);

% Find the number of filling fractions
ffoVec = uniquetol( BindFFDiff(:,2), 1e-9 );
num_ffo = length(ffoVec);

p2vec = uniquetol( BindFFDiff(:,2), 1e-9 );
num_p1 = length(beVec);

% Diffusion Mat
DiffMat    = zeros( num_p1, num_p2 );
DiffMatSig = zeros( num_p1, num_p2  );

for ii = 1:num_p1
  for jj = 1:num_p2
    % Use conditional statements to find row with given BE and FF
    row = (ii-1) * num_p2 + jj; 
    DiffMat(ii,jj) = BindFFDiff( row, 3 );
    DiffMatSig(ii,jj) = BindFFDiff( row, 4 );
  end
end

% Plot it
% D vs param1
if isfinite(p1vec) ~= 0
  figure()
  hold all
  for ii = 1:num_p2
    errorbar( p1vec, DiffMat(ii,: ), DiffMatSig(ii,: ) )
  end
  Ax = gca;
  Ax.YLim = [0 1.1];
  xlabel(Param1); ylabel('D');
  titlestr = ['D vs' Param1s];
  title(titlestr);

  legcell = cell( num_p2, 1 );

  for i = 1:num_p2
    legcell{i} = [ Param2s ' = ' num2str( p1vec(i) ) ];
  end
  legend( legcell,'location', 'best' );
end

% D vs param2
if isfinite(p2vec) ~= 0
  figure()
  hold all
  for ii = 1:num_p1
    errorbar( p2vec, DiffMat(ii,: ), DiffMatSig(ii,: ) )
  end
  Ax = gca;
  Ax.YLim = [0 1.1];
  xlabel(Param2); ylabel('D');
  titlestr = ['D vs' Param2s];
  title(titlestr);

  legcell = cell( num_p1, 1 );

  for i = 1:num_p1
    legcell{i} = [ Param1s ' = ' num2str( p1vec(i) ) ];
  end
  legend( legcell,'location', 'best' );
end

if isfinite(p1vec) ~= 0 && isfinite(p2vec)
  %Color bar
  figure()
  imagesc( p2vec, p1vec, DiffMat );
  colorbar;
  title('Diffusion Coeff')
  xlabel(Param2); ylabel(Param1)
end

%% Only plot vs BE is inf is not in the data set
%if isInfFlag == 0
  %% D vs be
  %figure()
  %hold all
  %for ii = 1:num_ffo
    %errorbar( beVec, DiffMat(:,ii ), DiffMatSig(:,ii ) )
  %end
  %Ax = gca;
  %Ax.YLim = [0 1.1];
  %xlabel('be'); ylabel('D');
  %title('D vs be');

  %legcell = cell( num_ffo, 1 );

  %for i = 1:num_ffo
    %legcell{i} = ['ff = ' num2str( ffoVec(i) ) ];
  %end
  %legend( legcell,'location', 'best' );

  %%Color bar
  %figure()
  %imagesc( ffoVec, beVec, DiffMat );
  %colorbar;
  %title('Diffusion Coeff')
  %xlabel('\nu obstacles'); ylabel('binding energy')
%end

% Save the Diffusion Coeff
if saveflag
  DiffSaveName = [ savename 'be' num2str(num_be)...
    'ffo' num2str(num_ffo) '.mat' ];
  save( DiffSaveName, 'DiffMat', 'beVec','ffoVec');
  movefile(DiffSaveName, '~/McHydro/diffcalc');
end

fprintf('Finished run\n');


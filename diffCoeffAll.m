% [DiffMat, DiffMatSig] = diffCoeffAll(timestrMult, plotflag, verbose,savename );
% Wrapper for diffCoeffCalc that analyzes all the files in the msdfiles folder.
% All these files need the same grid and trials. The parameters from the files
% should form a grid ( # bind energy) X ( # ffo )

function [DiffMat, DiffMatSig] = ...
  diffCoeffAll( timestrMult, plotflag, verbose, savename )

try 
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
  % applies 'isempty' to all strings
  % list of unique parameter files
  msdLUnParam = msdLall(~cellfun('isempty', strfind( msdLall, tRunIdtfy ) ));  
  numUnqParams = length(msdLUnParam); % number of unique parameter combinations
  numSameBind = length(msdLUnParam( ...
    ~cellfun('isempty',strfind( msdLUnParam, bindRunIdtfy) ))); 
  numSameFFo = length(msdLUnParam( ...
    ~cellfun('isempty',strfind( msdLUnParam, foRunIdtfy) ))); 
  numSameSo = length(msdLUnParam( ...
    ~cellfun('isempty',strfind( msdLUnParam, soRunIdtfy) ))); 
  numBind = numUnqParams / numSameBind ;
  numFFo = numUnqParams / numSameFFo  ;
  numSo = numUnqParams / numSameSo ;

  if numBind == 1
    Param1 = 'ff obstacles';
    Param1s = 'ffo';
    Param2 = 'size obstacles';
    Param2s = 'so';
  elseif numFFo == 1
    Param1 = 'binding energy';
    Param1s = 'be';
    Param2 = 'size obstacles';
    Param2s = 'so';
  elseif numSo == 1
    Param1 = 'binding energy';
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
  p1p2Diff = zeros( numUnqParams ,  4); 

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

      if isfield(paramlist,{'so'}
        sizeobs = paramlist.so;
      elseif isfield(const,{'size_obst'}
        sizeobs = const.size_obst;
      else
        error('I cannot find obstacle size')
      end
      
      if verbose
        fprintf('ff = %.2g be = %.2g so=%d\n', ffo, bindEn, sizeobs);
      end

      if isinf( bindEn )
        timestart = 0 ;
      else
        timestart = timestrMult * max( exp( bindEn ) , exp(-bindEn) );
      end

      % If tstart is too large, make it equal to half the max run time
      % (arbitrary).
      tmax = max(dtime);
      if timestart > tmax / 2; timestart = tmax / 2; end;
      
      % Run diffcoeffcalc
      [Dout] = diffCoeffCalc( filename, timestart, plotflag, verbose );

      % Display it
      if verbose
        disp(Dout);
      end

      % Store it in mat
      if numSo == 1
        p1p2Diff(ii,1) = bindEn;
        p1p2Diff(ii,2) = ffo;
      elseif numBind == 1
        p1p2Diff(ii,1) = ffo;
        p1p2Diff(ii,2) = sizeobs;
      else 
        p1p2Diff(ii,1) = bindEn;
        p1p2Diff(ii,2) = sizeobs;
      end
        p1p2Diff(ii,3) = Dout.Dfit;
        p1p2Diff(ii,4) = Dout.DsigFit;

   end

  % Sort it by binding energy
  [~,I] = sort(p1p2Diff);
  p1p2Diff = p1p2Diff( I(:,1), : );

  % Move all figs to ~/McHydro/figs
  if plotflag; movefile('*.fig', '~/McHydro/figs'); end;
  cd ~/McHydro/

  % Rearrang things into a more friendly matrix
  % Find the number of binding energies
  %beVec = uniquetol( BindFFDiff(:,1), 1e-9 );
  %num_be = length(beVec);

  p1vec = uniquetol( p1p2Diff(:,1), 1e-9 );
  num_p1 = length(p1vec);

  % Find the number of filling fractions
  % ffoVec = uniquetol( p1p2Diff(:,2), 1e-9 );
  % num_ffo = length(ffoVec);

  p2vec = uniquetol( p1p2Diff(:,2), 1e-9 );
  num_p2 = length(p2vec);

  % Diffusion Mat
  DiffMat    = zeros( num_p1, num_p2 );
  DiffMatSig = zeros( num_p1, num_p2  );

  for ii = 1:num_p1
    for jj = 1:num_p2
      % Use conditional statements to find row with given BE and FF
      row = (ii-1) * num_p2 + jj; 
      DiffMat(ii,jj) = p1p2Diff( row, 3 );
      DiffMatSig(ii,jj) = p1p2Diff( row, 4 );
    end
  end

  % Plot it
  % D vs param1
  if isfinite(p1vec) ~= 0
    figure()
    hold all
    for ii = 1:num_p2
      errorbar( p1vec, DiffMat(:,ii ), DiffMatSig(:,ii ) )
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

  if [isfinite(p1vec); isfinite(p2vec)] ~= 0
    %Color bar
    figure()
    imagesc( p2vec, p1vec, DiffMat);
    colorbar;
    title('Diffusion Coeff')
    xlabel(Param2); ylabel(Param1)
  end

  % Save the Diffusion Coeff
  if saveflag
    DiffSaveName = [ savename 'be' num2str(num_be)...
      'ffo' num2str(num_ffo) '.mat' ];
    save( DiffSaveName, 'DiffMat', 'beVec','ffoVec');
    movefile(DiffSaveName, '~/McHydro/diffcalc');
  end

  fprintf('Finished run\n');

catch err
  fprintf('%s',err.getReport('extended') );
  cd ~/McHydro
end



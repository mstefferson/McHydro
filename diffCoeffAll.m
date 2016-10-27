% [DiffMat, DiffMatSig, p1vec, p2vec, numTrials] = ...
%  diffCoeffAll( timestrMult, plotDFlag, plotFit, plotLog, ...
%    verbose, savename, initFitGuess )
% Wrapper for diffCoeffCalc that analyzes all the files in the msdfiles folder.
% All these files need the same grid and trials. The parameters from the files
% should form a grid ( # bind energy) X ( # ffo )

function [DiffMat, DiffMatSig, p1vec, p2vec, numTrials] = ...
diffCoeffAll( timestrMult, plotDFlag, plotFit, plotLog, ...
  verbose, savename, initFitGuess )

try
  if nargin == 0
    timestrMult = 1;
    plotDFlag = 0;
    plotFit = 0;
    plotLog = 0;
    verbose = 0;
    saveflag = 0;
    guessFlag = 0;
  elseif nargin == 1
    plotDFlag = 0;
    plotFit = 0;
    plotLog = 0;
    verbose = 0;
    saveflag = 0;
    guessFlag = 0;
  elseif nargin == 2
    plotFit = 0;
    plotLog = 0;
    verbose = 0;
    saveflag = 0;
    guessFlag = 0;
  elseif nargin == 3
    plotLog = 0;
    verbose = 0;
    saveflag = 0;
    guessFlag = 0;
  elseif nargin == 4
    verbose = 0;
    saveflag = 0;
    guessFlag = 0;
  elseif nargin == 5
    saveflag = 0;
    guessFlag = 0;
  elseif nargin == 6
    if isempty(savename); saveflag = 0; else saveflag = 1; end;
    guessFlag = 0;
  elseif nargin == 7
    if isempty(savename); saveflag = 0; else saveflag = 1; end;
    guessFlag = 1;
  end
  
  % Add paths
  addpath('~/McHydro/src')
  
  fprintf('Startng diffCoeffAll. Analyzing all files in ./msdfiles \n');
  % diffcoeffCal inputs
  
  % Output directory
  if ~exist('figs','dir'); mkdir('figs'); end;
  if ~exist('diffcalc','dir'); mkdir('diffcalc'); end;
  
  % Grab all the files in the msd folder
  msdLall = filelist( '.mat','./');
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
  
  if numSo == 1
    Param1 = 'binding energy';
    Param1s = 'be';
    Param2 = 'ff obstacles';
    Param2s = 'ffo';
    combo = 1;
  elseif numFFo == 1
    Param1 = 'binding energy';
    Param1s = 'be';
    Param2 = 'size obstacles';
    Param2s = 'so';
    combo = 2;
  elseif numBind == 1
    Param1 = 'ff obstacles';
    Param1s = 'ffo';
    Param2 = 'size obstacles';
    Param2s = 'so';
    combo = 3;
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
  % m(:,1) : p1; m(:,2) = p2; m(:,3) = D m(:,4) = sig D
  p1p2Diff = zeros( numUnqParams ,  4);
  
  if guessFlag; fitGuess = initFitGuess; end;
  
  for ii = 1:numUnqParams
    % Grab file and load it
    filename = msdLUnParam{ii};
    load( filename );
    if isfield(const,{'size_obst'})
      sizeobs = const.size_obst;
    end
    if exist('paramlist','var')
      ffo  = floor( paramlist.ffo * 1e10 ) / 1e10;
      bindEn  = floor( paramlist.be * 1e10 ) / 1e10;
      if isfield(paramlist,{'so'})
        sizeobs = paramlist.so;
      end
      clear paramlist % Just in case
    elseif exist('paramvec','var' )
      ffo = paramvec(1);
      bindEn = paramvec(4);
      clear paramvec % Just in case
    else
      error('I cannot find any parameters');
    end
    
    if ~exist('sizeobs','var')
      error('I cannot find obstacle size')
    end
    
    if verbose
      fprintf('ff = %.2g be = %.2g so=%d\n', ffo, bindEn, sizeobs);
    end
    
    if isinf( bindEn )
      timestart = 0 ;
    else
      timestart = timestrMult * 1;
    end
    
    % If tstart is too large, make it equal to half the max run time
    % (arbitrary).
    tmax = max(dtime);
    if timestart > tmax / 2; timestart = tmax / 2; end;
    
    % Run diffcoeffcalc
    if guessFlag
      [Dout,coeffsFit] = diffCoeffCalc( filename, timestart, plotFit, plotLog, ...
        verbose, saveflag, fitGuess );
      fitGuess = coeffsFit.UwaWfSc;
    else
      [Dout,~] = diffCoeffCalc( filename, timestart, plotDFlag, verbose, saveflag );
    end
    
    % Display it
    if verbose; disp(Dout); end
    
    % Store it in mat
    if combo == 1
      p1p2Diff(ii,1) = bindEn;
      p1p2Diff(ii,2) = ffo;
    elseif combo == 2
      p1p2Diff(ii,1) = bindEn;
      p1p2Diff(ii,2) = sizeobs;
    else
      p1p2Diff(ii,1) = ffo;
      p1p2Diff(ii,2) = sizeobs;
    end
    
    p1p2Diff(ii,3) = Dout.DfitUwaWfSc;
    p1p2Diff(ii,4) = Dout.DsigUwaWfSc;
  end
  % Rearrang things into a more friendly matrix
  % Find the number of p1
  p1vec = uniquetol( p1p2Diff(:,1), 1e-9 );
  num_p1 = length(p1vec);
  
  % Find the number of p2
  p2vec = uniquetol( p1p2Diff(:,2), 1e-9 );
  num_p2 = length(p2vec);
  
  % Sort it by p1
  [~,I] = sort(p1p2Diff);
  p1p2Diff = p1p2Diff( I(:,1), : );
  % Sort by p2
  for i = 1:num_p1
    [~,I] = sort( p1p2Diff( (i-1) * num_p2 + 1 : i * num_p2, 2  ) );
    p1p2Diff( (i-1) * num_p2 + 1 : i * num_p2 ,: ) = ...
      p1p2Diff( (i-1) * num_p2 + I ,: );
  end
  
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
  if plotDFlag
    % D vs param1
    if length(p1vec) > 1
      if isfinite(p1vec) ~= 0
        
        figure()
        hold all
        for ii = 1:num_p2
          errorbar( p1vec, DiffMat(:,ii ), DiffMatSig(:,ii ) )
        end
        Ax = gca;
        Ax.YLim = [0 1.1];
        Ax.XLim = [ min(p1vec) max(p1vec) ];
        xlabel(Param1); ylabel('D');
        titlestr = ['D vs ' Param1s];
        title(titlestr);
        
        legcell = cell( num_p2, 1 );
        
        for i = 1:num_p2
          legcell{i} = [ Param2s ' = ' num2str( p2vec(i) ) ];
        end
        legend( legcell,'location', 'best' );
      end
    end % end plot p1
    
    % D vs param2
    if length(p2vec) > 1
      if isfinite(p2vec) ~= 0
        figure()
        hold all
        for ii = 1:num_p1
          errorbar( p2vec, DiffMat(ii,: ), DiffMatSig(ii,: ) )
        end
        Ax = gca;
        Ax.YLim = [0 1.1];
        Ax.XLim = [ min(p2vec) max(p2vec) ];
        xlabel(Param2); ylabel('D');
        titlestr = ['D vs ' Param2s];
        title(titlestr);
        legcell = cell( num_p1, 1 );
        
        for i = 1:num_p1
          legcell{i} = [ Param1s ' = ' num2str( p1vec(i) ) ];
        end
        legend( legcell,'location', 'best' );
      end
    end %end plot p2
    
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
      DiffSaveName = [ savename 'be' num2str(numBind)...
        'ffo' num2str(numFFo) 'so' num2str(numSo) '.mat' ];
      save( DiffSaveName, 'DiffMat', 'p1vec','p2vec');
      movefile(DiffSaveName, '~/McHydro/diffcalc');
    end
    fprintf('Finished run\n');
  end
  
  % Move all figs to ~/McHydro/figs
  if plotDFlag && saveflag; movefile('*.fig', '~/McHydro/figs'); end;
  
catch err
  fprintf('%s',err.getReport('extended') );
   keyboard
end

% averageMSDgrids( ffo, bind, bBar, parentpath, nameID )
%   Description: finds weighted MSD averages over grids. Takes files
% from parentpath with given ffo, bind, bBar, and names them with
% name ID tag

function averageMSDgrids( ffo, bind, bBar, parentpath, nameID )
% get path for binding. files must be in their own bind dir
for hh = 1:length(bind)
  bindTemp = bind(hh);
  if abs(bindTemp) > 0 && abs(bindTemp) < 1
    fullpath = [parentpath 'bind' num2str(bindTemp, '%.1f' ) '/'];
  else
    fullpath = [parentpath 'bind' num2str(bindTemp, '%.2d' ) '/'];
  end
  % load first out here
  try
    for ii = 1:length(ffo)
      ffoTemp = ffo(ii);
      fileId = [ 'msd_unBbar0_Bbar' num2str(bBar) ...
        '_bind' num2str(bindTemp ) '_fo' num2str(ffoTemp, '%.2f') '*'];
      files = dir( [fullpath fileId] );
      numGrids = length(files);
      load( [ fullpath files(ii).name ] );
      % Do a weight average
      msdTemp = msd(:,1);
      timeTemp = dtime;
      nPtsTemp = msd(:,3);
      stdTemp = msd(:,2);
      errorTemp = msd(:,2) ./ sqrt( nPtsTemp);
      weightTemp =  1 ./ ( errorTemp .^ 2 );
      % Allocate memory
      msdMat = zeros( length(msdTemp), numGrids );
      timeMat = zeros( length(timeTemp), numGrids );
      stdMat = zeros( length(stdTemp), numGrids );
      errorMat = zeros( length(errorTemp), numGrids );
      weightMat = zeros( length(weightTemp), numGrids );
      nPtsMat = zeros( length(nPtsTemp), numGrids );
      % Save first one out of loop
      msdMat(:,1) = msdTemp;
      timeMat(:,1) = timeTemp;
      stdMat(:,1) = stdTemp;
      errorMat(:,1) = errorTemp;
      weightMat(:,1) = weightTemp;
      nPtsMat(:,1) = nPtsTemp;
      % Loop over grids
      for jj = 2:numGrids
        load( [fullpath files(jj).name] );
        msdTemp = msd(:,1);
        timeTemp = dtime;
        stdTemp = msd(:,2);
        nPtsTemp = msd(:,3);
        errorTemp = msd(:,2) ./ sqrt( nPtsTemp );
        weightTemp =  1 ./ ( errorTemp .^ 2 );
        % Save Temps
        msdMat(:,jj) = msdTemp;
        timeMat(:,jj) = timeTemp;
        stdMat(:,jj) = stdTemp;
        errorMat(:,jj) = errorTemp;
        weightMat(:,jj) = weightTemp;
        nPtsMat(:,jj) = nPtsTemp;
      end
      % unweighted averages
      msdUw = mean( msdMat, 2 );
      stdUw = std( msdMat, 0, 2 );
      sigUw = stdUw ./ sqrt( numGrids );
      nPtsAve = mean( nPtsMat, 2 );
      timeAve = mean( timeMat, 2 );
      % weighted averages
      sumW = sum( weightMat, 2 );
      msdW = sum( msdMat .* weightMat, 2 ) ./ sumW;
      stdW = sqrt( sum( ...
        ( msdMat - repmat( msdW, [1, numGrids] ) ) .^ 2 .* weightMat, 2 ) ...
        ./ (  ( numGrids - 1 ) ./ numGrids  .* sumW ) );
      sigW = stdW ./ sqrt( numGrids );
      % Save parameters and time
      aveGrid.ffo  = ffoTemp;
      aveGrid.be   = bindTemp ;
      aveGrid.bBar = bBar;
      aveGrid.gridConfigs = numGrids;
      aveGrid.time  = timeAve;
      aveGrid.nPts = nPtsAve;
      % save weighted and unweighted
      aveGrid.msdW  = msdW;
      aveGrid.stdW  = stdW;
      aveGrid.sigW = sigW;
      aveGrid.msdUw  = msdUw;
      aveGrid.stdUw = stdUw;
      aveGrid.sigUw = sigUw;
      % save file
      savename = [ 'aveGrid_' fileId(1:end-1) '_ng' num2str(numGrids) '_' ...
        't' num2str( const.ntimesteps ) '_' nameID '.mat' ];
      save(savename, 'aveGrid');
      movefile(savename, 'gridAveMSDdata/');
    end
  catch err
    keyboard
  end
end


% averageMSDgrids( ffo, bind, bDif, parentpath, nameID )
%   Description: finds weighted MSD averages over grids. Takes files
% from parentpath with given ffo, bind, bDif, and names them with
% name ID tag

function averageMSDgrids( ffo, bind, bDiff, sizeObs, parentpath, nameID )
% get path for binding. files must be in their own bind dir
% fullpath = parentpath;
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
      for jj = 1:length(sizeObs)
        sizeObstTemp = sizeObs(jj);
        for kk = 1:length(bDiff)
          bDiffTemp = bDiff(kk);
          fileId = [ 'msd_unD1_bD' num2str(bDiffTemp, '%.2f') ...
            '_bind' num2str(bindTemp ) '_fo' num2str(ffoTemp, '%.2f') ...
            '_so' num2str(sizeObstTemp, '%.1d') '_*'];
          files = dir( [fullpath fileId] );
          numGrids = length(files);
          load( [ fullpath files(1).name ] );
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
          for kk = 2:numGrids
            load( [fullpath files(kk).name] );
            msdTemp = msd(:,1);
            timeTemp = dtime;
            stdTemp = msd(:,2);
            nPtsTemp = msd(:,3);
            errorTemp = msd(:,2) ./ sqrt( nPtsTemp );
            weightTemp =  1 ./ ( errorTemp .^ 2 );
            % Save Temps
            msdMat(:,kk) = msdTemp;
            timeMat(:,kk) = timeTemp;
            stdMat(:,kk) = stdTemp;
            errorMat(:,kk) = errorTemp;
            weightMat(:,kk) = weightTemp;
            nPtsMat(:,kk) = nPtsTemp;
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
          aveGrid.bDiff = bDiffTemp;
          aveGrid.so = sizeObstTemp;
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
      end
    end
  catch err
    keyboard
  end
end


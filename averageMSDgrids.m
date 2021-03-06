% averageMSDgrids( ffo, bind, bDif, parentpath, nameID )
%   Description: finds weighted MSD averages over grids. Takes files
% from parentpath with given ffo, bind, bDif, and names them with
% name ID tag
%
% ffo: filling fractions you wanted to look for
% bind: binding energies you wanted to look for
% bDiff: bound diffusion you wanted to look for
% sizeObs: obstable sizes you want to look for
% parentpath: path to look for msdfiles
% nameID: name Id you'd like in filename
% bindDirFlag: if 1, code will look for files in directories bind## (##=be) 
% in the parentpath. If 0, it looks in the parentpath

function averageMSDgrids( ffo, bind, bDiff, sizeObs, parentpath, nameID, bindDirFlag )
% get path for binding. files must be in their own bind dir
fullpath = parentpath;
for hh = 1:length(bind)
  bindTemp = bind(hh);
  if bindDirFlag
    if abs(bindTemp) > 0 && abs(bindTemp) < 1
     fullpath = [parentpath 'bind' num2str(bindTemp, '%.1f' ) '/'];
    else
     fullpath = [parentpath 'bind' num2str(bindTemp, '%.2d' ) '/'];
    end
  end
  % load first out here
  end
  try
    for ii = 1:length(ffo)
      ffoTemp = ffo(ii);
      for jj = 1:length(sizeObs)
        sizeObstTemp = sizeObs(jj);
        for kk = 1:length(bDiff)
          bDiffTemp = bDiff(kk);
          fileId = [ 'msd_unD1_bD' num2str(bDiffTemp, '%.2f') ...
            '_bind' num2str(bindTemp ) '_fo' num2str(ffoTemp, '%.2f') ...
            '_so' num2str(sizeObstTemp, '%.2d') '_*'];
          files = dir( [fullpath fileId] );
          numGrids = length(files);
          load( [ fullpath files(1).name ] );
          obstExclude = modelopt.obst_excl;
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
          occupancyMat = zeros( 1, numGrids );
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
            if const.trackOcc
              occupancyMat(kk) = mean(occupancy);
            end
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
          % if weight is nan (constant msd), set it to unweighted value
          if any( isnan( msdW ) )
            keyboard
          end
          % Save parameters and time
          aveGrid.ffo  = ffoTemp;
          aveGrid.be   = bindTemp ;
          aveGrid.bDiff = bDiffTemp;
          aveGrid.so = sizeObstTemp;
          aveGrid.obstExclude = obstExclude;
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
          aveGrid.occupancy = mean( occupancyMat );
          % save file
          savename = [ 'aveGrid_' fileId(1:end-1) 'oe' num2str(obstExclude)...
            '_ng' num2str(numGrids)  ...
            '_t' num2str( const.ntimesteps ) '_' nameID '.mat' ];
          save(savename, 'aveGrid');
          movefile(savename, 'gridAveMSDdata/');
        end
      end
    end
  catch err
    fprintf('%s',err.getReport('extended') );
    keyboard
  end
end


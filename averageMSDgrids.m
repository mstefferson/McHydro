function averageMSDgrids( ffom, bind, bBar, nameID )

for hh = 1:length(bind)
  
  bindTemp = bind(hh);
  
if bBar == 0
 parentpath = '/home/mws/McHydro/msdfiles/pando/saxtonParams/hopbnd0/';
elseif isinf( bBar )
  parentpath = '/home/mws/McHydro/msdfiles/pando/saxtonParams/hopbndInf/';
end
fullpath = [parentpath 'be' num2str(bindTemp ) '/'];
if isinf(bind)
  parentpath = '/home/mws/McHydro/msdfiles/pando/saxtonParams/nobind/';
  fullpath = [parentpath 'OTE1' '/'];
end


% load first out here

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
  stdTemp = msd(:,2) ./ sqrt( msd(:,3) );
  errorTemp = msd(:,2) ./ sqrt( msd(:,3) );
  weightTemp =  1 ./ errorTemp;
  nPtsTemp = msd(:,3);
  
  msdMat = zeros( length(msdTemp), numGrids );
  timeMat = zeros( length(timeTemp), numGrids );
  stdMat = zeros( length(stdTemp), numGrids );
  errorMat = zeros( length(errorTemp), numGrids );
  weightMat = zeros( length(weightTemp), numGrids );
  nPntsMat = zeros( length(nPtsTemp), numGrids );
  
  msdMat(:,1) = msdTemp;
  timeMat(:,1) = timeTemp;
  stdMat(:,1) = stdTemp;
  errorMat(:,1) = errorTemp;
  weightMat(:,1) = weightTemp;
  nPts(:,1) = nPtsTemp;

  for jj = 2:numGrids
    load( [fullpath files(jj).name] );
    msdTemp = msd(:,1);
    timeTemp = dtime;
    stdTemp = msd(:,2) ./ sqrt( msd(:,3) );
    errorTemp = msd(:,2) ./ sqrt( msd(:,3) );
    weightTemp =  1 ./ errorTemp;
    nPtsTemp = msd(:,3);

    msdMat(:,ii) = msdTemp;
    timeMat(:,ii) = timeTemp;
    stdMat(:,ii) = stdTemp;
    errorMat(:,ii) = errorTemp;
    weightMat(:,ii) = weightTemp;
    nPts(:,ii) = nPtsTemp;
  end
  
  % unweighted averages
  msdAveUw = mean( msdMat, 2 ); 
  errorAveUw = mean( errorMat, 2 ); 
  stdAveUw = mean( stdMat, 2 ); 
  nPntsAve = mean( nPntsMat, 2 ); 
  timeAve = mean( timeAve, 2 ); 

  % weighted averages
  sumW = sum( weightMat, 2 );
  msdAveW = sum( msdMat .* weightMat, 2 ) ./ sumW;
  errorAveW = sqrt( sum( ( msdMat - msdAveW ) .^ 2 .* weightMat, 2 ) ...
   ./ (  ( nPntsMat - 1 ) ./ nPntsMat .* sumW ) );

  % Save
  aveGrid.ffo  = ffoTemp;
  aveGrid.be   = bindTemp ;
  aveGrid.bBar = Inf;
  aveGrid.msdUw  = msdAveUw;
  aveGrid.stdevMeanUw = errorAveUw;
  aveGrid.stdevUw = stdAveUw;
  aveGrid.msdW  = msdAveW;
  aveGrid.stdevMW  = errorAveW;
  aveGrid.time  = timeAve;
  aveGrid.nPts = nPtsAve;
  aveGrid.gridConfigs = numGrids;

  savename = [ 'aveGrid_' fileId(1:end-1) nameID '.mat' ];
  save(savename, 'aveGrid');
  movefile(savename, 'gridAveMSDdata/');
end

end


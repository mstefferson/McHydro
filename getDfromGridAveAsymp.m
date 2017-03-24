% masterD = getDfromGridAveAsymp( path2files, fileId, plotAllFlag, saveFigFlag )
%   Description: Wrapper for findHorztlAsymp. Loops aveGrid* for 
% everything matching the fileID in path2files. Plot options
% key:
% masterD( be, ffo, bBar, D, Dsig, tAnom, tAnomSig, steadyState , ...
% earlyAnom, slopeEnd, slopeMoreNeg, yinterMostNeg, upperbound)
function masterD = getDfromGridAveAsymp( path2files, fileId, plotAllFlag, saveFigFlag )
% addpath
addpath('./src')
% get files
files2analyze = dir( [path2files fileId] );
numFiles = length( files2analyze );
masterD = zeros( numFiles, 14 );
for ii = 1:numFiles
  % load and save parameters
  load( [path2files files2analyze(ii).name ] );
  if isfield(aveGrid,'bDiff')
    masterD(ii,1) = aveGrid.bDiff;
  else
    masterD(ii,1) = exp(-aveGrid.bBar);
  end
  masterD(ii,2) = aveGrid.be;
  masterD(ii,3) = aveGrid.ffo;
  % handle changing parameter names
  if isfield(aveGrid,'so')
    masterD(ii,4) = aveGrid.so;
  else
    masterD(ii,4) = 1;
  end
  % find the horzontal asymptote
  out = findHorztlAsymp( aveGrid.time, aveGrid.msdW, aveGrid.sigW );
  masterD(ii,5) = out.D;
  masterD(ii,6) = out.Dsig;
  masterD(ii,7) = out.tAnom;
  masterD(ii,8) = out.tAnomSig;
  masterD(ii,9) = out.steadyState;
  masterD(ii,10) = out.earlyAnom;
  masterD(ii,11) = out.slopeEnd;
  masterD(ii,12) = out.slopeMostNeg;
  masterD(ii,13) = out.yinterMostNeg;
  masterD(ii,14) = min( log10( aveGrid.msdW ./ aveGrid.time) );
  % plotting routines
  if plotAllFlag
    plotDataAsympError( aveGrid.time, aveGrid.msdW, aveGrid.sigW, ...
      out.slopeMostNeg, out.yinterMostNeg, out.tAnom, out.earlyAnom, out.D, out.Dsig, ...
      aveGrid.be, aveGrid.ffo, masterD(ii,1), masterD(ii,4), 0 )
    if saveFigFlag
      savename = ['logAsymp_bBar' num2str( aveGrid.bBar) '_be' num2str( aveGrid.be )  ...
        '_ffo' num2str( aveGrid.ffo,'%.2f' ) '.fig' ];
      savefig(gcf, savename);
    end
  end
end
% Sort it by be, and ffo
masterD = sortrows( masterD, [ 1 1 1 ] );
end


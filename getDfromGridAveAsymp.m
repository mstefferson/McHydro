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
masterD = zeros( numFiles, 13 );
% keyboard
for ii = 1:numFiles
  % load and save parameters
  load( [path2files files2analyze(ii).name ] );
  masterD(ii,1) = aveGrid.be;
  masterD(ii,2) = aveGrid.ffo;
  masterD(ii,3) = aveGrid.bBar;
  % find the horzontal asymptote
  out = findHorztlAsymp( aveGrid.time, aveGrid.msdW, aveGrid.sigW );
  masterD(ii,4) = out.D;
  masterD(ii,5) = out.Dsig;
  masterD(ii,6) = out.tAnom;
  masterD(ii,7) = out.tAnomSig;
  masterD(ii,8) = out.steadyState;
  masterD(ii,9) = out.earlyAnom;
  masterD(ii,10) = out.slopeEnd;
  masterD(ii,11) = out.slopeMostNeg;
  masterD(ii,12) = out.yinterMostNeg;
  masterD(ii,13) = min( log10( aveGrid.msdW ./ aveGrid.time) );
  % plotting routines
  if plotAllFlag
    plotDataAsympError( aveGrid.time, aveGrid.msdW, aveGrid.sigW, ...
      out.slopeMostNeg, out.yinterMostNeg, out.tAnom, out.earlyAnom, out.hAsymp, out.hSig, ...
      aveGrid.be, aveGrid.ffo, aveGrid.bBar, 0 )
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


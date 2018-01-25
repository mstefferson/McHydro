% masterD = getDfromGridAveAsymp( path2files, fileId, plotAllFlag, saveFigFlag )
%   Description: Wrapper for getHorzAsymptotes. Loops aveGrid* for 
% everything matching the fileID in path2files. Plot options
% key:
% masterD( be, ffo, bBar, D, Dsig, tAnom, tAnomSig, steadyState , ...
% earlyAnom, slopeEnd, slopeMoreNeg)
function [masterD, asymInfo] = getDfromGridAveAsymp( path2files, fileId, ...
  numBins, threshold, plotFlag, saveFigFlag, verbose )
% addpath
addpath('./src')
% get files
files2analyze = dir( [path2files fileId] );
numFiles = length( files2analyze );
masterD = zeros( numFiles, 14 );
% master = zeros( numFiles, 100 );
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
  try
    [diffInfo, asymInfo] = getDfromMsdData( aveGrid.time, ...
      aveGrid.msdW, aveGrid.sigW, ...
      threshold, numBins, plotFlag, verbose );
      if saveFigFlag
        savename = ['bins_bDiff' num2str( aveGrid.bDiff) '_be' num2str( aveGrid.be )  ...
          '_ffo' num2str( aveGrid.ffo,'%.2f' ) '.fig' ];
          savefig(gcf, savename);
      end
  catch err
    fprintf('%s',err.getReport('extended') );
  end
  masterD(ii,5) = diffInfo.D;
  masterD(ii,6) = diffInfo.DSig;
  masterD(ii,7) = diffInfo.tAnom;
  masterD(ii,8) = diffInfo.tAnomSig;
  masterD(ii,9) = diffInfo.steadyState;
  masterD(ii,10) = diffInfo.earlyAnom;
  masterD(ii,11) = asymInfo.slopeAsym(end);
  masterD(ii,12) = asymInfo.maxNegSlope;
end
% Sort it by be, and ffo
masterD = sortrows( masterD, [ 1 1 1 ] );
end

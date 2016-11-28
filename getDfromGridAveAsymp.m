function masterD = getDfromGridAveAsymp( path2files, fileId, plotAllFlag, saveFigFlag )
% addpath
addpath('./src')

files2analyze = dir( [path2files fileId] );

numFiles = length( files2analyze );

% masterD( be, ffo, bBar, D, Dsig, tAsymp, tAsympSig, steadyState )
masterD = zeros( numFiles, 8 );

for ii = 1:numFiles
  load( [path2files files2analyze(ii).name ] );
  masterD(ii,1) = aveGrid.be;
  masterD(ii,2) = aveGrid.ffo;
  masterD(ii,3) = aveGrid.bBar;
  
  out = findHorztlAsymp( aveGrid.time, aveGrid.msdW, aveGrid.sigW );
  masterD(ii,4) = out.D;
  masterD(ii,5) = out.Dsig;
  masterD(ii,6) = out.tAsymp;
  masterD(ii,7) = out.tAsympSig;
  masterD(ii,8) = out.steadyState;
%   keyboard
  if plotAllFlag
    plotDataAsympError( aveGrid.time, aveGrid.msdW, aveGrid.sigW, ...
      out.slopeStart, out.yinter, out.hAsymp, out.hSig, ...
      aveGrid.be, aveGrid.ffo, aveGrid.bBar, 0 )
    if saveFigFlag
      savename = ['logAsymp_be' num2str( aveGrid.be ) '_ffo' num2str( aveGrid.ffo ) ...
        '_bBar' num2str( aveGrid.bBar) '.fig' ];
      savefig(gcf, savename);
    end  
  end
end
  
  % Sort it by be, and ffo
  
  masterD_sort = sortrows( masterD, [ 1 1 1 ] );
  
  save('aveGridDAsymp.mat', 'masterD')
end


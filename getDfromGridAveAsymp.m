function masterD = getDfromGridAveAsymp( path2files, plotAllFlag, saveFigFlag )
% addpath
addpath('./src')

files2analyze = dirs( [path2files '*.mat'] )

numFiles = length( files2analyze );

% masterD( be, ffo, D, Dsig, tAsymp, tAsympSig, steadyState )
masterD = zeros( numFiles, 7 );

for ii = 1:numFiles
  load( [path2files files2analyze(ii).name ] );
  [output]= findHorztlAsymp(x,y,erry)
  masterD(ii,1) = aveGrid.be;
  masterD(ii,2) = aveGrid.ffo;

  out = findHorztlAsymp( aveGrid.time, aveGrid.msdW, aveGrid.sigW );
  masterD(ii,3) = out.D;
  masterD(ii,4) = out.Dsig;
  masterD(ii,5) = out.tAsymp;
  masterD(ii,6) = out.tAsympSig;
  masterD(ii,7) = out.steadyState;

  if plotAllFlag
    plotDataAsymp( aveGrid.time, aveGrid.msdW, out.hAsymp, out.slopeStart, out.yinter )
    if saveFigFlag
      savename = ['logAsymp_be' num2str( aveGrid.be ) '_ffo' num2str( aveGrid.ffo ) ...
        '_bBar' num2str( aveGrid.bar) '.fig' ];
      savefig(gcf, savename);
  end

end

% Sort it by be, and ffo

masterD_sorted = sortrows( masterD, [ 1 1 ] );
keyboard
end


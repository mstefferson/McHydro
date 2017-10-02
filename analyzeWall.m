function T = analyzeWall( path2dirs )
% grab files
files2analyze = dir( [path2dirs '/' 'data_*'] );
numFiles = length( files2analyze);
% get obstacle length
randFile = randi( numFiles-1 )+1;
load( [files2analyze(randFile).folder '/' files2analyze(randFile).name ] );
numObst = length( obst );
% allocate
counter = zeros( numFiles, 1 );
filename = cell( numFiles, 1 );
type = cell( numFiles, 1);
bndDiff = zeros( numFiles, 1);
be = zeros( numFiles, 1 );
thickness = zeros( numFiles, 1 );
width = zeros( numFiles, 1);
fluxIn = zeros( numFiles, 1);
for ii = 1:numFiles
  % get path to params
  nameTemp = files2analyze(ii).name;
  load( [files2analyze(ii).folder '/' nameTemp ] );
  numTemp =  length( obst );
  % store name and things
  filename{ii} = nameTemp;
  counter(ii) = ii;
  for jj = 1:numTemp
    if strcmp( obst{jj}{1}, 'wall' )
      type{ii,jj} = obst{jj}{1};
      bndDiff( ii, jj ) = obst{jj}{2}(1);
      be( ii, jj ) = obst{jj}{2}(2);
      thickness( ii, jj ) = obst{jj}{2}(3);
      width( ii, jj ) = obst{jj}{2}(4);
    else
      type{ii,jj} = 'none';
      bndDiff( ii, jj ) = 1;
      be( ii, jj ) = 0;
      thickness( ii, jj ) = 0;
      width( ii, jj ) = const.n_gridpoints;
    end
  end
  if numTemp < numObst
    type{ii,numObst} = 'none';
    bndDiff( ii, numObst ) = 1;
    be( ii, numObst ) = 0;
    thickness( ii, numObst ) = 0;
    width( ii, numObst ) = const.n_gridpoints;
  end
  fluxIn( ii ) = flux;
end
% make table
T = table( counter, fluxIn );
typeT = cell2table( type );
for ii=1:numObst
  typeTemp = typeT{:,ii};
  Ttemp =  table( bndDiff(:,ii), be(:,ii), ...
    thickness(:,ii), width(:,ii) );
  Tappend = [ typeTemp Ttemp ];
  idstr = num2str( ii, '%d' );
  varNames = { ['type' idstr], ['bndDiff' idstr], ['be' idstr],...
    ['thickness' idstr], ['width' idstr] };
  Tappend.Properties.VariableNames = varNames;
  T = [ T Tappend ];
end
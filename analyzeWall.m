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
param3 = zeros( numFiles, 1 );
param4 = zeros( numFiles, 1);
fluxIn = zeros( numFiles, 1);
occFlag = zeros( numFiles, 1);
occStore = cell( numFiles, 1);
occSitesStore = cell( numFiles, 1);
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
      param3( ii, jj ) = obst{jj}{2}(3);
      param4( ii, jj ) = obst{jj}{2}(4);
    elseif strcmp( obst{jj}{1}, 'rand' )
      type{ii,jj} = obst{jj}{1};
      bndDiff( ii, jj ) = obst{jj}{2}(1);
      be( ii, jj ) = obst{jj}{2}(2);
      param3( ii, jj ) = obst{jj}{2}(3);
      param4( ii, jj ) = obst{jj}{2}(4);
    elseif strcmp( obst{jj}{1}, 'teleport' )
      type{ii,jj} = obst{jj}{1};
      bndDiff( ii, jj ) = 0;
      be( ii, jj ) = 0;
      param3( ii, jj ) = 0;
      param4( ii, jj ) = 0;
    elseif strcmp( obst{jj}{1}, 'specloc' )
      type{ii,jj} = obst{jj}{1};
      bndDiff( ii, jj ) = obst{jj}{2}(1);
      be( ii, jj ) = obst{jj}{2}(2);
      param3( ii, jj ) = obst{jj}{2}(3);
      param4( ii, jj ) = 0;
    else
      type{ii,jj} = 'none';
      bndDiff( ii, jj ) = 1;
      be( ii, jj ) = 0;
      param3( ii, jj ) = 0;
      param4( ii, jj ) = const.n_gridpoints;
    end
  end
  if numTemp < numObst
    type{ii,numObst} = 'none';
    bndDiff( ii, numObst ) = 1;
    be( ii, numObst ) = 0;
    param3( ii, numObst ) = 0;
    param4( ii, numObst ) = const.n_gridpoints;
  end
  fluxIn( ii ) = flux;
  if exist( 'occ', 'var' )
    occFlag(ii) = 1;
    occStore{ii} = occ;
    occSitesStore{ii} = occSites;
  else
    occFlag(ii) = 0;
    occStore{ii} = 0;
    occSitesStore{ii} = 0;
  end
end
% make table
T = table( counter, fluxIn, occFlag,occStore, occSitesStore );
typeT = cell2table( type );
for ii=1:numObst
  typeTemp = typeT{:,ii};
  Ttemp =  table( bndDiff(:,ii), be(:,ii), ...
    param3(:,ii), param4(:,ii) );
  Tappend = [ typeTemp Ttemp ];
  idstr = num2str( ii, '%d' );
  varNames = { ['type_' idstr], ['bndDiff_' idstr], ['be_' idstr],...
    ['param3_' idstr], ['param4_' idstr] };
  Tappend.Properties.VariableNames = varNames;
  T = [ T Tappend ];
end

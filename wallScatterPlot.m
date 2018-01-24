% wall plot
function wallScatterPlot( path2dirs )
% path2dirs = 'runfiles/20171002_LorenTele';
T = analyzeWall( path2dirs );
paramInfo = getIndsParams( T );
% distinguish between wall and specloc
if strcmp( unique( T.type_2( ~strcmp(T.type_2,'teleport') ) ), 'wall' )
  obsttype = 'wall';
elseif strcmp( unique( T.type_2( ~strcmp(T.type_2,'teleport') ) ), 'specloc' )
  obsttype = 'specloc';
else
  obsttype = 'unknown';
end
% plot it
plotFlux( T, obsttype, paramInfo )
plotOccAllDist( T, obsttype, paramInfo )
plotOccGap( T, obsttype, paramInfo )

%%%%%%%%%%%%% sub routines %%%%%%%%%%%%%%
function plotFlux(T, plottype, paramInfo)
if strcmp( plottype, 'wall')
  xlabelStr = 'thickness, $$t$$';
  legendStr = '$$ t = $$ ';
elseif strcmp( plottype, 'specloc' )
  xlabelStr = 'size, $$ s $$';
  legendStr = '$$ s = $$ ';
else
  error( 'not written')
end
% no 2nd obstacle case
fluxSingle = T.fluxIn( strcmp( T.type_2, 'teleport' ) );
% set bndDiff identifiers
bndId = {'o'; 'sq'};
randFig = randi( 100000 );
figure(randFig);
colorArrayBe = colormap(['lines(' num2str(length(paramInfo.beUnique)) ')']);
colorArrayTh = colormap(['lines(' num2str(length(paramInfo.lengthUnique)) ')']);
close(randFig);
% plot vs length
figure()
hold
legCellBe = cell( paramInfo.numBe * paramInfo.numBndDiff + 1, 1);
counter = 1;
for ii = 1:paramInfo.numBndDiff
  bndDiffStr = ['$$ D_{b} = $$ ' num2str(  paramInfo.bndDiffUnique(ii) )];
  for jj = 1:paramInfo.numBe
    beStr = ['$$ \Delta G = $$  ' num2str(  paramInfo.beUnique(jj) )];
    plotInd = T.bndDiff_2 == paramInfo.bndDiffUnique(ii) & ...
      T.be_2 == paramInfo.beUnique(jj) & ...
      paramInfo.loginds2analyze;
    colorIdTemp = colorArrayBe(jj,:);
    s = scatter( T.param3_2( plotInd ), T.fluxIn( plotInd ));
    s.MarkerFaceColor = colorIdTemp;
    s.Marker = bndId{ii};
    s.SizeData = 50;
    legCellBe{counter} = [ bndDiffStr ' ' beStr ];
    counter = counter + 1;
  end
end
% plot just inf wall
plot( paramInfo.lengthUnique, ...
  fluxSingle * ones( size( paramInfo.lengthUnique ) ), 'k:' );
xlabel( xlabelStr ); ylabel('$$ j $$');
legCellBe{counter} = 'none';
lh = legend( legCellBe, 'location', 'best' );
lh.Interpreter = 'latex';
% plot vs be
legCellTh = cell( paramInfo.numLength * paramInfo.numBndDiff + 1, 1);
counter = 1;
figure()
hold
beNonInf = paramInfo.beUnique( ~isinf( paramInfo.beUnique ) );
for ii = 1:paramInfo.numBndDiff
  bndDiffStr = ['$$ D_{b} = $$ ' num2str(  paramInfo.bndDiffUnique(ii) )];
  for jj = 1:paramInfo.numLength
    thStr = [ legendStr num2str(  paramInfo.lengthUnique(jj) )];
    plotInd = T.bndDiff_2 == paramInfo.bndDiffUnique(ii) &...
      T.param3_2 == paramInfo.lengthUnique(jj) ...
      & paramInfo.loginds2analyze ;
    colorIdTemp = colorArrayTh(jj,:);
    % fix sorting issue
    s = scatter( T.be_2( plotInd ) , T.fluxIn( plotInd ) );
    s.MarkerFaceColor = colorIdTemp;
    s.Marker = bndId{ii};
    s.SizeData = 50;
    legCellTh{counter} = [ bndDiffStr ' ' thStr ];
    counter = counter + 1;
  end
end
% plot just inf wall
plot( beNonInf, fluxSingle * ones( size( beNonInf ) ), 'k:' );
xlabel(' Binding energy $$ \Delta G $$'); ylabel('$$ j $$');
legCellTh{counter} = 'none';
lh = legend( legCellTh, 'location', 'best' );
lh.Interpreter = 'latex';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plotOccGap(T, plottype, paramInfo)
if strcmp( plottype, 'wall')
  xlabelStr = 'thickness, $$t$$';
  legendStr = '$$ t = $$ ';
elseif strcmp( plottype, 'specloc' )
  xlabelStr = 'size, $$ s $$';
  legendStr = '$$ s = $$ ';
else
  error( 'not written')
end
% no 2nd obstacle case
occSingleAllPos = T.occStore{ strcmp( T.type_2, 'teleport') };
% get gap ind
randPick = paramInfo.inds2analyze( randi( length( paramInfo.inds2analyze ) ) );
currSubs = T.occSitesStore{ randPick };
[~, wallDim] = max( currSubs(1,:) );
[~, maxWallPosInd] = max( currSubs(:,wallDim) );
wallind2plot = maxWallPosInd;
% set bndDiff identifiers
bndId = {'o'; 'sq'};
randFig = randi(1000000);
figure(randFig);
colorArrayBe = colormap(['lines(' num2str(length(paramInfo.beUnique)) ')']);
colorArrayTh = colormap(['lines(' num2str(length(paramInfo.lengthUnique)) ')']);
close(randFig);
% plot vs length
figure()
hold
legCellBe = cell( paramInfo.numBe * paramInfo.numBndDiff + 1, 1);
counter = 1;
for ii = 1:paramInfo.numBndDiff
  bndDiffStr = ['$$ D_{b} = $$ ' num2str(  paramInfo.bndDiffUnique(ii) )];
  for jj = 1:paramInfo.numBe
    beStr = ['$$ \Delta G = $$  ' num2str(  paramInfo.beUnique(jj) )];
    plotInd = find( T.bndDiff_2 == paramInfo.bndDiffUnique(ii) & T.be_2 == paramInfo.beUnique(jj) & ...
      paramInfo.loginds2analyze );
    colorIdTemp = colorArrayBe(jj,:);
    % grab occ
    tempOcc = zeros(1, length( find(plotInd)) );
    for ll = 1:length(plotInd)
      dataSlice = T.occStore{ plotInd(ll) };
      tempOcc(ll) = dataSlice(wallind2plot);
    end
    s = scatter( T.param3_2( plotInd ), tempOcc );
    s.MarkerFaceColor = colorIdTemp;
    s.Marker = bndId{ii};
    s.SizeData = 50;
    legCellBe{counter} = [ bndDiffStr ' ' beStr ];
    counter = counter + 1;
  end
end
% plot just inf wall
plot( T.param3_2( plotInd ), ...
  occSingleAllPos( wallind2plot ) * ones( size( T.param3_2( plotInd ) ) ),...
  'k:' );
xlabel( xlabelStr ); ylabel('gap occupancy');
legCellBe{counter} = 'none';
lh = legend( legCellBe, 'location', 'best' );
lh.Interpreter = 'latex';
% plot vs be
legCellTh = cell( paramInfo.numLength * paramInfo.numBndDiff + 1, 1);
counter = 1;
figure()
hold
for ii = 1:paramInfo.numBndDiff
  bndDiffStr = ['$$ D_{b} = $$ ' num2str(  paramInfo.bndDiffUnique(ii) )];
  for jj = 1:paramInfo.numLength
    thStr = [ legendStr num2str(  paramInfo.lengthUnique(jj) )];
    plotInd = find( T.bndDiff_2 == paramInfo.bndDiffUnique(ii) & ...
      T.param3_2 == paramInfo.lengthUnique(jj) ...
      & paramInfo.loginds2analyze );
    colorIdTemp = colorArrayTh(jj,:);
    % grab occ
    tempOcc = zeros(1, length( find(plotInd)) );
    for ll = 1:length(plotInd)
      dataSlice = T.occStore{ plotInd(ll) };
      tempOcc(ll) = dataSlice(wallind2plot);
    end
    s = scatter( T.be_2( plotInd ) , tempOcc);
    s.MarkerFaceColor = colorIdTemp;
    s.Marker = bndId{ii};
    s.SizeData = 50;
    legCellTh{counter} = [ bndDiffStr ' ' thStr ];
    counter = counter + 1;
  end
end
% plot just inf wall
plot( T.be_2( plotInd ), ...
  occSingleAllPos( wallind2plot ) * ones( size( T.be_2( plotInd ) ) ),...
  'k:' );
xlabel(' Binding energy $$ \Delta G $$'); ylabel('gap occupancy');
legCellTh{counter} = 'none';
lh = legend( legCellTh, 'location', 'best' );
lh.Interpreter = 'latex';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plotOccAllDist( T, plottype, paramInfo )
if strcmp( plottype, 'wall' )
  legendStr = '$$ t = $$ ';
elseif strcmp( plottype, 'specloc' )
  legendStr = '$$ s = $$ ';
else
  error( 'not written')
end
% get distance inds
possDim = [1 2];
randPick = paramInfo.inds2analyze( randi( length( paramInfo.inds2analyze ) ) );
currSubs = T.occSitesStore{ randPick };
[~, wallDim] = max( currSubs(1,:) );
varyDim = possDim( possDim ~= wallDim );
[maxWallPos, maxWallPosInd] = max( currSubs(:,wallDim) );
varyCenter = currSubs(maxWallPosInd,varyDim);
indsPerpGap = find( currSubs(:, varyDim ) == varyCenter );
distPerpGap = maxWallPos - currSubs(indsPerpGap, wallDim );
indsParGap = find( currSubs(:,wallDim)  == maxWallPos-1 );
distParGap  =  varyCenter - currSubs(indsParGap,varyDim);
% set bndDiff identifiers
lengthId = {'o'; 'sq'; '^'};
randFig = randi(100000);
figure(randFig);
colorArrayBe = colormap(['lines(' num2str(length(paramInfo.beUnique)) ')']);
close(randFig);
% plot occ
legCell = cell( paramInfo.numLength * paramInfo.numBe, 1);
counter = 1;
hold
for hh = 1:paramInfo.numBndDiff
  figure()
  ax1 = subplot(1,2,1);
  title('dist from gap, perp to wall')
  xlabel('distance');
  ylabel('occupancy');
  hold
  ax2 = subplot(1,2,2);
  title('dist from gap, par to wall')
  xlabel('distance');
  ylabel('occupancy');
  hold
  for ii = 1:paramInfo.numBe
    beStr = [ '$$ \Delta G = $$ ' num2str(  paramInfo.beUnique(ii) )];
    colorIdTemp = colorArrayBe(ii,:);
    for jj = 1:paramInfo.numLength
      thStr = [ legendStr num2str(  paramInfo.lengthUnique(jj) )];
      plotInd = T.bndDiff_2 == paramInfo.bndDiffUnique(hh) & ...
        T.be_2 == paramInfo.beUnique( ii )...
        & T.param3_2 == paramInfo.lengthUnique(jj) & ...
        paramInfo.loginds2analyze ;
      % fix sorting issue
      currOcc = T.occStore{ plotInd };
      s = scatter( ax1, distPerpGap, currOcc( indsPerpGap ) );
      s.MarkerFaceColor = colorIdTemp;
      s.MarkerEdgeColor = colorIdTemp;
      s.Marker = lengthId{jj};
      s.SizeData = 50;
      s.Marker = lengthId{jj};
      s.SizeData = 50;
      s = scatter( ax2, distParGap, currOcc( indsParGap ) );
      s.MarkerFaceColor = colorIdTemp;
      s.MarkerEdgeColor = colorIdTemp;
      s.Marker = lengthId{jj};
      s.SizeData = 50;
      legCell{counter} = [ beStr ' ' thStr ];
      counter = counter + 1;
    end
  end
end
lh = legend(legCell);
lh.Interpreter = 'latex';

function paramInfo = getIndsParams( T )
% get inds
paramInfo.loginds2analyze = ~strcmp( T.type_2, 'teleport' );
paramInfo.inds2analyze = find( paramInfo.loginds2analyze );
paramInfo.beUnique = unique( T.be_2( paramInfo.loginds2analyze ) );
paramInfo.lengthUnique = unique( T.param3_2( paramInfo.loginds2analyze ) );
paramInfo.bndDiffUnique = unique( T.bndDiff_2( paramInfo.loginds2analyze ) );
paramInfo.numBe = length( paramInfo.beUnique );
paramInfo.numLength = length( paramInfo.lengthUnique );
paramInfo.numBndDiff = length( paramInfo.bndDiffUnique );

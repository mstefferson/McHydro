% wall plot
function wallScatterPlot( path2dirs )
% path2dirs = 'runfiles/20171002_LorenTele';
T = analyzeWall( path2dirs );

if strcmp( unique( T.type_2( ~strcmp(T.type_2,'teleport') ) ), 'wall' )
  plotFlux( T, 'wall' )
end

if strcmp( unique( T.type_2( ~strcmp(T.type_2,'teleport') ) ), 'specloc' )
  plotFlux( T, 'specloc' )
end

% get inds 
keyboard
possDim = [1 2];
currSubs = T.occSitesStore{1};
currOcc = T.occStore{1};
[~, wallDim] = max( currSubs(1,:) );
varyDim = possDim( possDim ~= wallDim );
[maxWallPos, maxWallPosInd] = max( currSubs(:,wallDim) );
varyCenter = currSubs(maxWallPosInd,varyDim);

indsPerpGap = find( currSubs(:, varyDim ) == varyCenter );
distPerpGap = maxWallPos - currSubs(indsPerpGap, wallDim );

indsParGap = find( currSubs(:,wallDim)  == maxWallPos-1 );
distParGap  =  varyCenter - currSubs(indsParGap,varyDim);

figure()
subplot(1,2,1) 
scatter( distPerpGap, currOcc( indsPerpGap ) );
title('dist from gap, perp to wall')
subplot(1,2,2)
scatter( distParGap, currOcc( indsParGap ) );
title('dist from gap, par to wall')

%%% sub routines %%%
function plotFlux(T, plottype)
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
% get unique vectors
inds2analyze = ~strcmp( T.type_2, 'teleport' );
beUnique = unique( T.be_2( inds2analyze ) );
thickUnique = unique( T.param3_2( inds2analyze ) );
bndDiffUnique = unique( T.bndDiff_2( inds2analyze ) );
numBe = length( beUnique );
numThick = length( thickUnique );
numBndDiff = length( bndDiffUnique );
% set bndDiff identifiers
% bndId = {'-'; '--'};
bndId = {'o'; 'sq'};
colorArrayBe = colormap(['lines(' num2str(length(beUnique)) ')']);
colorArrayTh = colormap(['lines(' num2str(length(thickUnique)) ')']);
% plot vs thickness
figure()
hold
legCellBe = cell( numBe * numBndDiff + 1, 1);
counter = 1;
for ii = 1:numBndDiff
  bndIdTemp = bndId{ii};
  bndDiffStr = ['$$ D_{b} = $$ ' num2str(  bndDiffUnique(ii) )];
  for jj = 1:numBe
    beStr = ['$$ \Delta G = $$  ' num2str(  beUnique(jj) )];
    plotInd = T.bndDiff_2 == bndDiffUnique(ii) & T.be_2 == beUnique(jj) & ...
      inds2analyze;
    colorIdTemp = colorArrayBe(jj,:);
    s = scatter( T.param3_2( plotInd ), T.fluxIn( plotInd ));
    %     s.Color = colorIdTemp;
    %     s.LineStyle = bndIdTemp;
    s.MarkerFaceColor = colorIdTemp;
    s.Marker = bndId{ii};
    s.SizeData = 50;
    legCellBe{counter} = [ bndDiffStr ' ' beStr ];
    counter = counter + 1;
  end
end
plot( thickUnique, fluxSingle * ones( size( thickUnique ) ), 'k:' );
xlabel( xlabelStr ); ylabel('$$ j $$');
legCellBe{counter} = 'none';
lh = legend( legCellBe, 'location', 'best' );
lh.Interpreter = 'latex';
% plot vs be
legCellTh = cell( numThick * numBndDiff + 1, 1);
counter = 1;
figure()
hold
beNonInf = beUnique( ~isinf( beUnique ) );
for ii = 1:numBndDiff
  bndIdTemp = bndId{ii};
  bndDiffStr = ['$$ D_{b} = $$ ' num2str(  bndDiffUnique(ii) )];
  for jj = 1:numThick
    thStr = [ legendStr num2str(  thickUnique(jj) )];
    plotInd = T.bndDiff_2 == bndDiffUnique(ii) & T.param3_2 == thickUnique(jj) ...
      & inds2analyze ;
    colorIdTemp = colorArrayTh(jj,:);
    % fix sorting issue
    %     y2plot = T.fluxIn( logInd );
    %     y2plot( y2plot( beUniqueInds ) )
    s = scatter( T.be_2( plotInd ) , T.fluxIn( plotInd ) );
    s.MarkerFaceColor = colorIdTemp;
    s.Marker = bndId{ii};
    s.SizeData = 50;
    %     s.Color = colorIdTemp;
    %     s.LineStyle = bndIdTemp;
    legCellTh{counter} = [ bndDiffStr ' ' thStr ];
    counter = counter + 1;
  end
end
plot( beNonInf, fluxSingle * ones( size( beNonInf ) ), 'k:' );
xlabel(' Binding energy $$ \Delta G $$'); ylabel('$$ j $$');
legCellTh{counter} = 'none';
lh = legend( legCellTh, 'location', 'best' );
lh.Interpreter = 'latex';

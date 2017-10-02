% wall plot
path2dirs = 'runfiles/20170927LorensGapRequstNoTele';
% path2dirs = 'runfiles/20171002_LorenTele';
T = analyzeWall( path2dirs );
% no 2nd obstacle case
fluxSingle = T.fluxIn( T.width2 == 100 );
% get unique vectors
beUnique = unique( T.be2( T.be2 ~= Inf ) );
thickUnique = unique( T.thickness2( T.thickness2 > 0 ) );
bndDiffUnique = unique( T.bndDiff2 );
numBe = length( beUnique );
numThick = length( thickUnique );
numBndDiff = length( bndDiffUnique );
% set bndDiff identifiers
bndId = {'-'; '--'};
colorArrayBe = colormap(['lines(' num2str(length(beUnique)) ')']);
colorArrayTh = colormap(['lines(' num2str(length(thickUnique)) ')']);
% plot vs thickness
figure()
hold
legCellBe = cell( numBe * numBndDiff + 1, 1);
counter = 1;
for ii = 1:numBndDiff
  bndIdTemp = bndId{ii};
  bndDiffStr = ['$$ D_{b} = $$' num2str(  bndDiffUnique(ii) )];
  for jj = 1:numBe
    beStr = ['$$ \Delta G = $$  ' num2str(  beUnique(jj) )];
    logInd = T.bndDiff2 == bndDiffUnique(ii) & T.be2 == beUnique(jj) & ...
      T.thickness2 > 0;
    colorIdTemp = colorArrayBe(jj,:);
    s = plot( thickUnique, T.fluxIn( logInd ) );
    s.Color = colorIdTemp;
    s.LineStyle = bndIdTemp;
    legCellBe{counter} = [ bndDiffStr ' ' beStr ];
    counter = counter + 1;
  end
end
plot( thickUnique, fluxSingle * ones( size( thickUnique ) ), 'k:' );
xlabel('Thickness $$ t $$'); ylabel('$$ j $$');
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
  bndDiffStr = ['$$ D_{b} = $$' num2str(  bndDiffUnique(ii) )];
  for jj = 1:numThick
    thStr = ['$$ t = $$  ' num2str(  thickUnique(jj) )];
    logInd = T.bndDiff2 == bndDiffUnique(ii) & T.thickness2 == thickUnique(jj) ...
      & ~isinf( T.be2 );
    colorIdTemp = colorArrayTh(jj,:);
    s = plot( beNonInf, T.fluxIn( logInd ) );
    s.Color = colorIdTemp;
    s.LineStyle = bndIdTemp;
    legCellTh{counter} = [ bndDiffStr ' ' thStr ];
    counter = counter + 1;
  end
end
plot( beNonInf, fluxSingle * ones( size( beNonInf ) ), 'k:' );
xlabel(' Binding energy $$ \Delta G $$'); ylabel('$$ j $$');
legCellTh{counter} = 'none';
lh = legend( legCellTh, 'location', 'best' );
lh.Interpreter = 'latex';


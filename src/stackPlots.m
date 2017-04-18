function stackPlots( fH, numCols )
%% stackPlots( fH, numCols )
% Michael Stefferson
% April 2017
%
% Squashes matlab subplots so they are stack; i.e., they shared x axis.
% Unlike samexaxis, can easily handle multiple columns
%
% Inputs:
% fH = figure handles
% numCol = number of columns
%
% Example
% fig = figure()
% numRows = 2;
% numCols = 1;
% numPlots = numRows * numCols;
% axVec = cell(1,numPlots);
%
% % Make subplot
% for ii = 1:numPlots
%   axTemp = subplot(numRows,numCols,ii);
%   axVec{ii} = axTemp;
%   plot(  axVec{ ii }, x, sin(x) + 1 )
%   tTemp = title( axVec{ ii }, num2str(ii) );
%   xlabel('x' );
%   ylabel('y' );
% end
%
% % stack 'em!
% stackPlots( fig, numCols )
%

% get number of rows and plots
numPlots = length( fH.Children ) ;
axVec = cell(1,numPlots);
axNum = 0;
% grab axis handles in a smart way (like a book), and undo squaring
for ii = 1 : numPlots
  if strcmp( fH.Children(numPlots + 1 -ii ).Type, 'axes' )
    axNum = axNum + 1;
    axVec{ axNum } = fH.Children(numPlots + 1 -ii );
    axis( axVec{ axNum }, 'normal')
    %     hold( axVec{ axNum + 1 }, 'off')
  end
end
% get rid of extras
axVec = axVec( 1:axNum );
numPlots = axNum;
numRows = numPlots / numCols;
% fix stretch
stretchAmount = (1 - 1 / numRows ) * ...
  ( axVec{end-numCols}.Position(2) - ...
  ( axVec{end}.Position(2) + axVec{end}.Position(4) ) );
for ii = 1 : numPlots
  axVec{ ii }.Position(4) =  axVec{ ii }.Position(4) + stretchAmount;
end
% fix position
for ii =  numPlots - numCols: - 1: 1
  axVec{ ii }.Position(2) =  axVec{ ii + numCols }.Position(2) + axVec{ ii + numCols }.Position(4);
end
% title position 
aspectRatio = axVec{1}.Position(4) ./ axVec{1}.Position(3); 
shift = 0.02;
tX = shift;
tY = 1 - shift ./ aspectRatio;
% fix appearance
% title spacing parameter
titleWiggle = 3/2;
for ii = 1 : numPlots
  % grab font size for title scaling
  axVec{ii}.FontUnits = 'normalized';
  titleSpace = titleWiggle * axVec{1}.FontSize;
  % axis ticks, labels, mkae room for title
  if strcmp( axVec{ ii }.YScale, 'linear' )
    dTick = titleSpace .* ( axVec{ ii }.YLim(2) - axVec{ ii }.YLim(1) );
    YTickOld = axVec{ ii }.YTick; 
    lowerYlim = axVec{ ii }.YLim(1);
    upperYlim = axVec{ ii }.YLim(2) + dTick;
    axVec{ ii }.YLim = [lowerYlim upperYlim];
    axVec{ ii }.YTick =  YTickOld;
  else % log
    YTickOld = axVec{ ii }.YTick; 
    lowerYlim = axVec{ ii }.YLim(1);
    upperYlim = axVec{ ii }.YLim(2) * ...
      10 ^ (titleSpace* ( log10( axVec{ ii }.YLim(2) ) - log10( axVec{ ii }.YLim(1)) ) );
    axVec{ ii }.YLim = [lowerYlim upperYlim];
    axVec{ ii }.YTick =  YTickOld;
  end
  % erase labels
  if ii <= ( numRows - 1 ) * numCols
    axVec{ ii }.XTickLabel = {};
  end
  axVec{ ii }.LineWidth = 1;
  % title
  axVec{ ii }.Title.Units = 'normalized';
  axVec{ ii }.Title.VerticalAlignment = 'top';
  axVec{ ii }.Title.HorizontalAlignment = 'left';
  axVec{ ii }.Title.Position =  [tX tY 0];
  axVec{ ii }.Box =  'on';
end

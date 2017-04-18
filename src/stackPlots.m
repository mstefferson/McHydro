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
numRows = numPlots / numCols;
axVec = cell(1,numPlots);

% grab axis handles in a smart way (like a book), and make it square
for ii = 1 : numPlots
  axVec{ ii } = fH.Children(numPlots + 1 -ii );
%   maxW = max( axVec{ ii }.Position( 3:4 ) ); 
%   maxW = max( axVec{ ii }.Position( 3:4 ) ); 
%   axis( axVec{ ii }, 'square' );
end

% fix stretch
stretchAmount = (1 - 1 / numRows ) * ...
  ( axVec{end-numCols}.Position(2) - ...
  ( axVec{end}.Position(2) + axVec{end}.Position(4) ) );
for ii = 1 : numPlots
  axVec{ ii }.Position(4) =  axVec{ ii }.Position(4) + stretchAmount;
%   axVec{ ii }.Position(3) =  axVec{ ii }.Position(4);
end

% fix position
for ii =  numPlots - numCols: - 1: 1
  axVec{ ii }.Position(2) =  axVec{ ii + numCols }.Position(2) + axVec{ ii + numCols }.Position(4);
end

% Title position 
aspectRatio = axVec{1}.Position(4) ./ axVec{1}.Position(3); 
shift = 0.02;
tX = shift;
tY = 1 - shift ./ aspectRatio;

% fix appearance
for ii = 1 : numPlots
  % axis ticks and labels
  dTick = axVec{ ii }.YTick(2) - axVec{ ii }.YTick(1);
  axVec{ ii }.YLim = [axVec{ ii }.YLim(1) axVec{ ii }.YLim(2) + dTick];
  axVec{ ii }.YTick = axVec{ ii }.YTick(1:end-1);
  if ii <= ( numRows - 1 ) * numCols
    axVec{ ii }.XTickLabel = {};
  end
  axVec{ ii }.LineWidth = 1;
  % title
  axVec{ ii }.Title.Units = 'normalized';
  axVec{ ii }.Title.VerticalAlignment = 'top';
  axVec{ ii }.Title.HorizontalAlignment = 'left';
  axVec{ ii }.Title.Position =  [tX tY 0];
end

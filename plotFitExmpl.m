% plotFitExmpl
%
% Plots the fits for the paper and alpha vs time
function plotFitExmpl(winStyle, fontSize)
plotMe = 0;
dirPath = './gridAveMSDdata/showFit/';
files = dir( [dirPath '*.mat']);
numFiles  = length(files);
% masterAveGrid(numFiles).aveGrid = 1;
% master D matrix  and structure
[~, out] = getDfromGridAveAsymp( dirPath, '0*',plotMe,0 );
numBins = length( out(1).slopeBin );
slopeStore = zeros( numFiles, numBins*2);
for ii = 1:numFiles
  %   fileInd = numFiles+1-ii;
  fileInd = ii;
  load( [dirPath files(fileInd).name] );
  slopeStore(ii,1:length( out(fileInd).slopeBin' ) ) = out(fileInd).slopeBin';
  masterAveGrid(ii) = aveGrid;
end

%%
% plotting
fig = figure();
figpos = [1 1 1920 1080];
titleMaster = {'a', 'b', 'c', 'd', 'e', 'f'};
fig.WindowStyle = winStyle;
fig.Position = figpos;

numCols = 3;
numRows = 2;
falseHugeSlope = 50; % for t anom
colorArray = colormap('lines(2)');
xLimMinVec = [10 10 10];
xLimMaxVec = [10^5 10^5 10^6];
yLimMinVec = [0.9 0.25 0.0055];
yLimMaxVec = [0.94 0.45 0.0105];
alphaYLims = [ 0.85 1.05];
legPos = [0.5336 0.7754 0.0462 0.1148];
yTickLabel(1).msd = {'0.91', '0.92', '0.93', '0.94'};
yTick(1).msd = [0.91, 0.92, 0.93, 0.94];
yTickLabel(2).msd = { '0.3', '0.35', '0.4', '0.45'};
yTick(2).msd = [ 0.3, 0.35, 0.4, 0.45 ];
yTickLabel(3).msd = { '0.006', '0.007', '0.008', '0.009', '0.01'};
yTick(3).msd = [0.006, 0.007, 0.008, 0.009, 0.01];
%for ii = 1:3
%%
for ii = 1:3
  % plot msd
  ax = subplot(numRows,numCols,ii);
  y = masterAveGrid(ii).msdW;
  x = masterAveGrid(ii).time;
  lenX = length(x);
  y_x = y ./ x;
  % ticks and limits
  xLimMin = xLimMinVec(ii);
  xLimMax = xLimMaxVec(ii);
  xTick = 10 .^ ( [log10(xLimMin):log10(xLimMax)] );
  % yLimMin = min(y_x);
  % yLimMax = max(y_x);
  yLimMin = yLimMinVec(ii);
  yLimMax = yLimMaxVec(ii);
  ax.FontSize = fontSize;
  % set-up figure
  hold on
  title( titleMaster{ii} );
  ax.YLim = [ yLimMin yLimMax];
  ax.XLim = [ xLimMin xLimMax];
  ax.XScale = 'log';
  ax.YScale = 'log';
  ax.XTick = xTick;
  ax.YTickLabel = yTickLabel(ii).msd;
  ax.YTick = yTick(ii).msd;
  
  % plot msd curve
  p = plot( x, y_x );
  p.Color = colorArray(1,:);
  p.LineWidth = 2;
  p.LineStyle = '-';
  ylabel( '$$ \langle r^2 \rangle /t $$');
  % plot asymptote and friends
  p = plot( x, out(ii).D .* ones( lenX , 1) );
  p.Color = colorArray(2,:);
  p.LineWidth = 2;
  p.LineStyle = '--';
  % plot max slope if it was able to
  if out(ii).earlyAnom == 0
    y = x .^ (falseHugeSlope) * out(ii).tAnom ^ (-falseHugeSlope ) ;
    p = plot( x, y );
    p.Color = [0 0 0];
    p.LineWidth = 2;
    p.LineStyle = ':';
    y = x .^ (out(ii).slopeMostNeg) * exp(out(ii).yinterMostNeg);
    p = plot( x, y );
    p.Color = colorArray(2,:);
    p.LineWidth = 2;
    p.LineStyle = '-.';
  end
  % get legend
  if ii == 2
    leg = legend( 'data', '$$ D^* $$', '$$ t_a $$', '$$ \alpha_{min} $$' );
    leg.Interpreter = 'latex';
    leg.Position = legPos;
  end
  % alpha vs time
  ax = subplot(numRows,numCols,numCols + ii);
  x = out(ii).centerTimeBin';
  temp = slopeStore(ii,:) ~= 0;
  y = 1 + slopeStore( ii, temp);
  p = plot( x, y  );
  p.Color = colorArray(1,:);
  p.LineWidth = 2;
  p.LineStyle = '-';
  % titles and limits
  title( titleMaster{numCols+ii} );
  ax.YLim = alphaYLims;
  ax.XScale = 'log';
  ax.XLim = [ xLimMin xLimMax];
  ax.XTick = xTick;
  xlabel( 'Time delay $$ t $$'); ylabel( 'Scaling exponent $$ \alpha $$' );
  ax.FontSize = fontSize;
end

%%
% stack 'em
stackPlots( fig, numCols );

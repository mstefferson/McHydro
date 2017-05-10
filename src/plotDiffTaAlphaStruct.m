% Plot No Bind, pos BE, motion, pos Be no motion bound, neg BE motion while bound

% masterD( be, ffo, bBar, D, Dsig, tAsymp, tAsympSig, steadyState , ...
% earlyAsymp, slopeEnd, slopeMoreNeg, yinterMostNeg, upperbound)

function plotDiffTaAlphaStruct( Dstruct, param, plotThresLines, ...
  connectDots, saveMe,moveSaveMe, saveID, winStyle, fontSize, fileExt, ...
  currentRow, totalRow, newFig)
% Latex font
set(0,'defaulttextinterpreter','latex')

if currentRow == 1
  titleMaster = {'a', 'b', 'c'};
elseif currentRow == 2
  titleMaster = {'d', 'e', 'f'};
elseif currentRow == 3
  titleMaster = {'g', 'h', 'i'};
else
  titleMaster = {'', '', ''};
end

title1 = titleMaster{1};
title2 = titleMaster{2};
title3 = titleMaster{3};

ax2YLim = [10 10^6];
% threshold lines
if plotThresLines.flag
  bigSlope = 10000;
  up = plotThresLines.uppVal;
  lp = plotThresLines.lowVal;
end

% figpos = [1 1 1920 1080];
% find what parameter you are varying
if strcmp(param.pVaryStr,'nu')
  xLim = [0 1];
elseif strcmp(param.pVaryStr,'bdiff')
  minX = min( param.pVary );
  maxX = max( param.pVary  );
  if minX < maxX
    xLim = [ minX maxX ];
  elseif (minX == 0) && (maxX == 0 )
    xLim = [ -1  1 ];
  else
    xLim = [ minX-minX/10  minX+minX/10];
  end
elseif strcmp(param.pVaryStr,'lobst')
  minX = min( param.pVary  );
  maxX = max( param.pVary  );
  if minX < maxX
    xLim = [ minX maxX ];
  elseif (minX == 0) && (maxX == 0 )
    xLim = [ -1  1 ];
  else
    xLim = [ minX-minX/10  minX+minX/10];
  end
else
  error('cannot find varying parameter')
end
% label is already saved
labX = param.pVaryTex;
% set up threshold lines
if plotThresLines.flag
  colorFact = 0.5;
  bl = -bigSlope .* up;
  bu = -bigSlope .* lp;
  x2plot = linspace(0,1,100);
  ta0 = log( ax2YLim(1) );
end

% set-up figure
if newFig
  fig = figure();
  fig.WindowStyle = winStyle;
  figpos = [1 1 1920 1080/2];
  fig.Position = figpos;
else
  fig = gcf;
end

% Diff
currSub = (currentRow-1) .* 3 ;
ax1 = subplot(totalRow,3,currSub + 1);
ax1.FontSize = fontSize;
title(title1, 'Units', 'normalized', ...
  'Position', [0 1 0], 'HorizontalAlignment', 'left');
% axis square
xlabel( ax1, labX); ylabel(ax1, 'Diffusion coeff. $$ D^* $$');
ax1.XLim = xLim;
ax1.YLim = [0,1.05];
ax1.XMinorTick = 'on';
ax1.YMinorTick = 'on';
hold
% ta
ax2 = subplot(totalRow,3,currSub + 2);
ax2.FontSize = fontSize;
% axis square
ax2.YScale = 'log';
title(title2, 'Units', 'normalized', ...
  'Position', [0 1 0], 'HorizontalAlignment', 'left');
ax2.YTick = [10^2 10^4 10^6];
ax2.YLim = ax2YLim;
ax2.XLim = xLim;
xlabel(ax2, labX); ylabel(ax2,'Anomalous time $$ t_{a} $$');
ax2.XMinorTick = 'on';
ax2.YMinorTick = 'on';
hold
% alpha
ax3 = subplot(totalRow,3,currSub + 3);
ax3.FontSize = fontSize;
% axis square
title(title3, 'Units', 'normalized', ...
  'Position', [0 1 0], 'HorizontalAlignment', 'left');
xlabel( ax3, labX); ylabel(ax3, 'Min. scaling exponent $$ \alpha_{min} $$');
ax3.XLim = xLim;
ax3.YLim = [0,1.05];
ax3.XMinorTick = 'on';
ax3.YMinorTick = 'on';
hold
% plot it
% Diff
plotDiff( ax1, Dstruct, param, connectDots );
% t_a
plotTasym( ax2, Dstruct, param, connectDots );
% alpha
plotAlpha( ax3, Dstruct, param, connectDots );
% % legend
if newFig
  legH = legend(ax2, param.legcell);
  legH.Interpreter = 'latex';
  legH.Position = [0.8848    0.7438    0.1012    0.2448];
end
% plot threshold lines
if plotThresLines.flag
  % Diff
  p = plot( ax1, x2plot, bigSlope .* x2plot + bu, 'k:');
  p.LineWidth = 2;
  p.Color = [colorFact colorFact colorFact];
  p = plot( ax1, x2plot, bigSlope .* x2plot + bl, 'k:') ;
  p.LineWidth = 2;
  p.Color = [colorFact colorFact colorFact];
  % Ta
  p = plot( ax2, x2plot, ta0 .* exp( bigSlope .* (x2plot - up) ), 'k:') ;
  p.LineWidth = 2;
  p.Color = [colorFact colorFact colorFact];
  p = plot( ax2, x2plot, ta0 .* exp( bigSlope .* (x2plot - lp) ), 'k:');
  p.LineWidth = 2;
  p.Color = [colorFact colorFact colorFact];
  % alpha
  p = plot( ax3, x2plot, bigSlope .* x2plot + bu, 'k.:') ;
  p.LineWidth = 2;
  p.Color = [colorFact colorFact colorFact];
  p = plot( ax3, x2plot, bigSlope .* x2plot + bl, 'k:');
  p.LineWidth = 2;
  p.Color = [colorFact colorFact colorFact];
end
% save it
if saveMe
  savefig( gcf,  saveID );
  if strcmp(fileExt,'eps')
    saveas( fig, [ saveID '.' fileExt ], 'epsc2' );
  else
    saveas( fig, [ saveID '.' fileExt ], fileExt );
  end
  % move it
if moveSaveMe
  movefile( [ saveID '*' ], './paperFigs' )
end
end


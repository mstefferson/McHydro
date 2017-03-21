% Plot No Bind, pos BE, motion, pos Be no motion bound, neg BE motion while bound

% masterD( be, ffo, bBar, D, Dsig, tAsymp, tAsympSig, steadyState , ...
% earlyAsymp, slopeEnd, slopeMoreNeg, yinterMostNeg, upperbound)

function plotDiffTaAlphaStruct( Dstruct, param, plotThresLines, ...
  saveMe,moveSaveMe, saveID, winStyle, fileExt)
% Latex font
set(0,'defaulttextinterpreter','latex')
fontSize = 24;
title1 = '(a)';
title2 = '(b)';
title3 = '(c)';
ax2YLim = [10 10^6];
% threshold lines
if plotThresLines
  bigSlope = 1000;
  up = 0.72;
  lp = 0.4;
end
savename = 'diffTasympAlphaVsNu_';
figpos = [1 1 1920 1080];
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
if plotThresLines
  colorFact = 0.5;
  bl = -bigSlope .* up;
  bu = -bigSlope .* lp;
  x2plot = linspace(0,1,100);
  ta0 = log( ax2YLim(1) );
end

% set-up figure
figure()
fig = gcf;
fig.WindowStyle = winStyle;
fig.Position = figpos;
% Diff
ax1 = subplot(1,3,1);
ax1.FontSize = fontSize;
title(title1, 'Units', 'normalized', ...
  'Position', [0 1 0], 'HorizontalAlignment', 'left')
axis square
xlabel( ax1, labX); ylabel(ax1, '$$ D^* $$');
ax1.XLim = xLim;
ax1.YLim = [0,1.1];
hold
% ta
ax2 = subplot(1,3,2);
ax2.FontSize = fontSize;
axis square
ax2.YScale = 'log';
title(title2, 'Units', 'normalized', ...
  'Position', [0 1 0], 'HorizontalAlignment', 'left')
ax2.YTick = [10^2 10^4 10^6];
ax2.YLim = ax2YLim;
ax2.XLim = xLim;
xlabel(ax2, labX); ylabel(ax2,'$$ t_{a} $$');
hold
% alpha
ax3 = subplot(1,3,3);
ax3.FontSize = fontSize;
axis square
title(title3, 'Units', 'normalized', ...
  'Position', [0 1 0], 'HorizontalAlignment', 'left')
xlabel( ax3, labX); ylabel(ax3, '$$ \alpha_{min} $$');
ax3.XLim = xLim;
ax3.YLim = [0,1.1];
hold
% plot it
% Diff
plotDiff( ax1, Dstruct, param );
% t_a
plotTasym( ax2, Dstruct, param );
% alpha
plotAlpha( ax3, Dstruct, param );
% legend
legH = legend(ax2, param.legcell);
legH.Interpreter = 'latex';
legH.Position = [0.8848    0.7438    0.1012    0.2448];
% plot threshold lines
if plotThresLines
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
  savefig( gcf, [ savename saveID ] );
  if strcmp(fileExt,'eps')
    saveas( fig, [ savename saveID '.' fileExt ], 'epsc2' );
  else
    saveas( fig, [ savename saveID '.' fileExt ], fileExt );
  end
end
% move it
if moveSaveMe
  movefile( [ savename '*' ], './paperFigs' )
end

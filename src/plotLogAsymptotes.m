% Pick configs to plot r^2/t
function plotLogAsymptotes(saveMe,moveSaveMe, winStyle,fileExt)
% Latex font
set(0,'defaulttextinterpreter','latex')
% ( bBar, be, nu ) 
% saveMe = 1;
% moveSaveMe = 1;
% fileExt = 'png';
fontSize = 20;

savename = ['msd_MDB' num2str(be) ];
% figpos = [1 1 1920 1080];
figpos = [1 1 935 850];
bHop1 = 0;
be1 = 1;
nu1 = 0.95;
bHop2 = Inf;
be2 = 2;
nu2 = 0.45;
bHop2 = Inf;
be2 = -5;
nu2 = 0.50;
% param matrix
params2plot = [
bHop1 be1 nu1; ...
bHop2 be2 nu2; ...
bHop3 be3 nu3];
% number of parameters
numParams = length( params2plot(:,1) );
nuVec = unique( params2plot(:,3) );
numNu = length( nuVec );
% set-up figures
figure()
fig = gcf;
fig.WindowStyle = winStyle;
fig.Position = figpos;
maxX = 5;
labX = '$$ t $$';
labY = '$$ \langle r^2 \rangle / t $$';
title1 = '(a)';
title2 = '(b)';
title3 = '(c)';
% Inf
ax1 = subplot(1,3,1);
ax1.XScale = 'log';
ax1.YScale = 'log';
ax1.XLim = [10^1 10^maxX];
ax1.XTick = logspace(1,maxX,maxX);
axis square
title(title1, 'Units', 'normalized', ...
'Position', [0 1 0], 'HorizontalAlignment', 'left')
% title( title1, 'Units', 'normalized', ...
% 'Position', [1 10], 'HorizontalAlignment', 'right')
xlabel(labX); ylabel(labY);
ax1.FontSize = fontSize;
hold
% Motion bound 
ax2 = subplot(1,3,2);
ax2.XScale = 'log';
ax2.YScale = 'log';
ax2.XLim = [10^1 10^maxX];
ax2.XTick = logspace(1,maxX,maxX);
axis square
title(title2, 'Units', 'normalized', ...
'Position', [0 1 0], 'HorizontalAlignment', 'left')
xlabel(labX); ylabel(labY);
ax2.FontSize = fontSize;
hold
% Motion bound pos G
ax3 = subplot(1,3,3);
ax3.XScale = 'log';
ax3.YScale = 'log';
ax3.XLim = [10^1 10^maxX];
ax3.XTick = logspace(1,maxX,maxX);
axis square
title(title3, 'Units', 'normalized', ...
'Position', [0 1 0], 'HorizontalAlignment', 'left')
xlabel(labX); ylabel(labY);
ax3.FontSize = fontSize;
hold

axVec = [ax1 ax2 ax3];
% loop over plots
for ii = 1:numParams
  axTemp = axVec(ii);
  BbarTemp = params2plot(ii,1);
  beTemp = params2plot(ii,2);
  ffoTemp = params2plot(ii,3);
  % load and store msd and time
  nameTemp = ['aveGrid_msd_unBbar0_Bbar' num2str( BbarTemp ) ...
  '_bind' num2str(  beTemp ) '_fo' num2str( ffoTemp,'%.2f' ) '_*' ];
  file2load = dir ( ['./gridAveMSDdata/newPlacet600/' nameTemp] );
  load( ['./gridAveMSDdata/newPlacet600/' file2load.name ])
  msd = aveGrid.msdW;
  time = aveGrid.time;
% figure out which mmatrxi to use
  if isinf( params2plot(ii,2) )
    axTemp = ax1;
  elseif params2plot(ii,1) == 0
    axTemp = ax2;
  elseif params2plot(ii,2) == be
    axTemp = ax3;
  else
    axTemp = ax4;
  end
  % plot it
  p = loglog( axTemp, time, msd./time );
  p.LineWidth = 3;
end
% legend
legH = legend( ax3, legNu );
legH.Interpreter = 'latex';
legH.Position = [0.1586    0.1300    0.1570    0.1423];
%%
if saveMe
  savefig( fig, [ savename '.fig' ] );
  if strcmp(fileExt,'eps')
    saveas( fig, [ savename '.' fileExt ], 'epsc2' );
  else
    saveas( fig, [ savename '.' fileExt ], fileExt );
  end
end

if moveSaveMe
  movefile( [ savename '*' ], './paperFigs' )
end

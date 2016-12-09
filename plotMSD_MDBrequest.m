% Pick configs to plot r^2/t
function plotMSD_MDBrequest(saveMe,moveSaveMe, winStyle,fileExt)
% Latex font
set(0,'defaulttextinterpreter','latex')
% ( bBar, be, nu ) 
% saveMe = 1;
% moveSaveMe = 1;
% fileExt = 'png';
fontSize = 20;
be = 2;
savename = ['msd_MDB' num2str(be) ];
% figpos = [1 1 1920 1080];
figpos = [1 1 935 850];
nu1 = 0.05;
nu2 = 0.25;
nu3 = 0.45;
nu4 = 0.75;
be1 = -1;
be2 = -2;
be3 = -3;
be4 = -4;
% param matrix
params2plot = [
Inf be1 nu1; ...
Inf be1 nu2; ...
Inf be1 nu3; ...
Inf be1 nu4; ...
Inf be2 nu1; ...
Inf be2 nu2; ...
Inf be2 nu3; ...
Inf be2 nu4; ...
Inf be3 nu1; ...
Inf be3 nu2; ...
Inf be3 nu3; ...
Inf be3 nu4; ...
Inf be4 nu1; ...
Inf be4 nu2; ...
Inf be4 nu3; ...
Inf be4 nu4 ];
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
title1 = ['(a) be ' num2str(be1) ];
title2 = ['(b) be ' num2str(be2) ];
title3 = ['(c) be ' num2str(be3) ];
title4 = ['(d) be ' num2str(be4) ];
% Inf
ax1 = subplot(2,2,1);
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
ax2 = subplot(2,2,2);
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
ax3 = subplot(2,2,3);
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
% Motion bound neg G
ax4 = subplot(2,2,4);
ax4.XScale = 'log';
ax4.YScale = 'log';
ax4.XLim = [10^1 10^maxX];
ax4.XTick = logspace(1,maxX,maxX);
axis square
title(title4, 'Units', 'normalized', ...
'Position', [0 1 0], 'HorizontalAlignment', 'left')
xlabel(labX); ylabel(labY);
ax4.FontSize = fontSize;
hold
% legend
legNu = cell( 1, numNu );
for ii = 1:numNu
  legNu{ii} = [' $$ \nu = $$ ', num2str( nuVec(ii), '%.2f') ] ;
end
% loop over plots
for ii = 1:numParams
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
  if params2plot(ii,2) == be1
    axTemp = ax1;
  elseif params2plot(ii,2) == be2
    axTemp = ax2;
  elseif params2plot(ii,2) == be3
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

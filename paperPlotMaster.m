addpath('./src')
%%
saveMe = 1;
moveSaveMe = 0;
winStyle = 'normal';
tempTitle = 0;
sameXaxis = 1;
plotThresLines.flag = 1;
plotAllSep = 0; % plot everything seperately
% flags
plotDstickSlipp = 0;
plotDsize = 0;
plotDbnddiff = 1;
plot3d = 0;
plotPercBnd0 = 0;
plotPercBnd1 = 0;
% ranges
plotRng2d = 3:4; % 1: slip pos, 2: slip neg, 3: stick pos, 4: sticky neg
plotRngSize = 2; % 1: slipp oe1, 2: sticky oe1 3: slipp oe0, 4: sticky oe0,
plotRng3d = [4]; % 1: 2d slipp, 2: 3d slipp, 3: 2d sticky, 4: 3d sticky
%1: l = 1, oe = 1 ; %2: l = 3, oe = 1; 3: l = 5, oe = 1; 4: l = 7, oe = 1;
%4: l = 3, oe = 0; 5: l = 5, oe = 0;
plotPercRngBnd0 = [1 2 4];
%1: l = 1, oe = 1 ; %2: l = 3, oe = 1; 3: l = 5; 3: l = 7,
plotPercRngBnd1 = [1 2 4];
fileExt = 'png';
vertFlag = 0; % for Asym

% load it
if plotDstickSlipp
  if ( ~exist('masterD_pos_bnd1','var') ) && ( any(plotRng2d == 1) )
    load('./dataMasterD/masterD_pos_bnd1.mat')
  end
  if ( ~exist('masterD_neg_bnd1','var')  ) && ( any(plotRng2d == 2) )
    load('./dataMasterD/masterD_neg_bnd1.mat')
  end
  if ( ~exist('masterD_pos_bnd0','var') ) && ( any(plotRng2d == 3) )
    load('./dataMasterD/masterD_pos_bnd0.mat')
  end
  if ( ~exist('masterD_neg_bnd0','var') ) && ( any(plotRng2d == 4) )
    load('./dataMasterD/masterD_neg_bnd0.mat')
  end
end
if plot3d
  if ( ~exist('masterD_Bbar0_pos','var') ) && ( any(plotRng3d == 1) )
    load('./dataMasterD/masterD_Bbar0_pos.mat')
  end
  if ( ~exist('masterD_3d_bnd0','var') ) && ( any(plotRng3d == 2) )
    load('./dataMasterD/masterD_3d_bnd0.mat')
  end
  if ( ~exist('masterD_BbarInf_pos','var') ) && ( any(plotRng3d == 3) )
    load('./dataMasterD/masterD_BbarInf_pos.mat')
  end
  if ( ~exist('masterD_3d_bnd1','var') ) && ( any(plotRng3d == 4) )
    load('./dataMasterD/masterD_3d_bnd1.mat')
  end
end
if plotDbnddiff
  if ( ~exist('masterD_bnddiff','var') )
    load('./dataMasterD/masterD_bnddiff.mat')
  end
end
if plotDsize
  if ( ~exist('masterD_size_oe1_bnd1','var') ) && ( any(plotRngSize == 1) )
    load('./dataMasterD/masterD_size_oe1_bnd1.mat')
  end
  if ( ~exist('masterD_size_oe1_bnd0','var') ) && ( any(plotRngSize == 2) )
    load('./dataMasterD/masterD_size_oe1_bnd0.mat')
  end
  if ( ~exist('masterD_bnd1_oe0_size','var') ) && ( any(plotRngSize == 3) )
    load('./dataMasterD/masterD_bnd1_oe0_size.mat')
  end
  if ( ~exist('masterD_bnd0_oe0_size','var') ) && ( any(plotRngSize == 4) )
    load('./dataMasterD/masterD_bnd0_oe0_size.mat')
  end
end
if plotPercBnd0
  if ( ~exist('masterD_l1_oe1_bnd0','var') ) && ( any(plotPercRngBnd0 == 1) )
    load('./dataMasterD/masterD_l1_oe1_bnd0.mat')
  end
  if ( ~exist('masterD_l3_oe1_bnd0','var') ) && ( any(plotPercRngBnd0 == 2) )
    load('./dataMasterD/masterD_l3_oe1_bnd0.mat')
  end
  if ( ~exist('masterD_l5_oe1_bnd0','var') ) && ( any(plotPercRngBnd0 == 3) )
    load('./dataMasterD/masterD_l5_oe1_bnd0.mat')
  end
  if ( ~exist('masterD_l7_oe1_bnd0','var') ) && ( any(plotPercRngBnd0 == 4) )
    load('./dataMasterD/masterD_l7_oe1_bnd0.mat')
  end
  if ( ~exist('masterD_l3_oe0','var') ) && ( any(plotPercRngBnd0 == 5) )
    load('./dataMasterD/masterD_l3_oe0.mat')
  end
  if ( ~exist('masterD_l5_oe0','var') ) && ( any(plotPercRngBnd0 == 6) )
    load('./dataMasterD/masterD_l5_oe0.mat')
  end
end

if plotPercBnd1
  if ( ~exist('masterD_l1_oe1_bnd1','var') ) && ( any(plotPercRngBnd0 == 1) )
    load('./dataMasterD/masterD_l1_oe1_bnd1.mat')
  end
  if ( ~exist('masterD_l3_oe1_bnd1','var') ) && ( any(plotPercRngBnd0 == 2) )
    load('./dataMasterD/masterD_l3_oe1_bnd1.mat')
  end
  if ( ~exist('masterD_l5_oe1_bnd1','var') ) && ( any(plotPercRngBnd0 == 3) )
    load('./dataMasterD/masterD_l5_oe1_bnd1.mat')
  end
end
%%
% plotLogCurvesVariousNu(saveMe,moveSaveMe, winStyle,fileExt)
%%
% plotLogAsymptotes(masterD_Bbar0,masterD_BbarInf_neg,masterD_BbarInf_pos,...
%   saveMe,moveSaveMe, winStyle,fileExt, vertFlag)
%%
if plotDstickSlipp
  varyParam = 'nu'; % nu, lobst, bdiff
  sizeWant = 1;
  nuWant = [];
  fig = figure();
  figpos = [1 1 1920 1080];
  fig.WindowStyle = winStyle;
  fig.Position = figpos;
  connectDots = 0;
  if plotAllSep == 0
    totRow = length(plotRng2d);
  else
    totRow = 1;
  end
  subplot( totRow, 3, totRow * 3);
  counter = 1;
  for ii = plotRng2d
    if plotAllSep == 1
      subRow = 1;
    else
      subRow = counter;
    end
    if ii == 1
      masterD2plot = masterD_pos_bnd1;
      saveID = 'pos_bnd1';
      saveIDTog = '2d_slippery';
      if strcmp( varyParam, 'nu' )
        plotThresLines.flag = 1;
        plotThresLines.uppVal = 0.72;
        plotThresLines.lowVal = 0.4;
      end
      dDiffWant = 1;
      beWant = [0 1 2 3 4 5 10];
      [Dstruct, param] = ...
        diffMatParamExtact( masterD2plot, varyParam, nuWant, dDiffWant, beWant, sizeWant );
      plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, connectDots, ...
        0, 0, saveID, winStyle, fileExt, subRow, totRow, plotAllSep);
      leg1 = param.legcell;
      if tempTitle; title('2D pos Slippery'); end;
    end
    if ii == 2
      masterD2plot = masterD_neg_bnd1;
      saveID = 'neg_bnd1';
      saveIDTog = '2d_slippery';
      if strcmp( varyParam, 'nu' )
        plotThresLines.flag = 1;
        plotThresLines.uppVal = 0.72;
        plotThresLines.lowVal = 0.4;
      end
      dDiffWant = 1;
      beWant = [0 -1 -2 -3 -4 -5 -10];
      [Dstruct, param] = ...
        diffMatParamExtact( masterD2plot, varyParam, nuWant, dDiffWant, beWant, sizeWant );
      plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, connectDots, ...
        0,0, saveID, winStyle, fileExt, subRow, totRow, plotAllSep)
      leg2 = param.legcell;
      if tempTitle; title('2D neg Slippery'); end;
    end
    if ii == 3
      masterD2plot = masterD_pos_bnd0;
      saveID = 'pos_bnd0';
      saveIDTog = '2d_sticky';
      if strcmp( varyParam, 'nu' )
        plotThresLines.flag = 1;
        plotThresLines.uppVal = 0.72;
        plotThresLines.lowVal = 0.4;
      end
      dDiffWant = 0;
      beWant = [0 1 2 3 10 Inf];
      [Dstruct, param] = ...
        diffMatParamExtact( masterD2plot, varyParam, nuWant, dDiffWant, beWant, sizeWant );
      plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, connectDots, ...
        0,0, saveID, winStyle, fileExt, subRow, totRow, plotAllSep)
      leg1 = param.legcell;
      if tempTitle; title('2D pos Sticky'); end;
    end
    if ii == 4
      masterD2plot = masterD_neg_bnd0;
      saveID = 'neg_bnd0';
      saveIDTog = '2d_sticky';
      if strcmp( varyParam, 'nu' )
        plotThresLines.flag = 1;
        plotThresLines.uppVal = 0.72;
        plotThresLines.lowVal = 0.4;
      end
      dDiffWant = 0;
      beWant = [0 -1 -2 -3 -10];
      %       beWant = [0 -2 -4 -5];
      [Dstruct, param] = ...
        diffMatParamExtact( masterD2plot, varyParam, nuWant, dDiffWant, beWant, sizeWant );
      plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, connectDots, ...
        0,0, saveID, winStyle, fileExt, subRow, totRow, plotAllSep)
      leg2 = param.legcell;
      if tempTitle; title('2D neg Sticky'); end;
    end
    counter = counter + 1;
  end
  % stack em!
  if plotAllSep == 0
    axTemp = cell(1,2);
    axTemp{1} = subplot(totRow, 3, 3);
    axTemp{2} = subplot(totRow, 3, 6);
    stackPlots( fig, 3 )
    legH = legend( axTemp{1} , leg1 );
    legH.Interpreter = 'latex';
    legH.FontSize = legH.FontSize .* 0.9;
    legH.Position = [0.9150 0.6369 0.0773 0.1929];
    legH = legend( axTemp{2}, leg2 );
    legH.Interpreter = 'latex';
    legH.FontSize = legH.FontSize .* 0.9;
    legH.Position = [0.9161 0.2788 0.0762 0.1194];
    if saveMe
      savefig( gcf,  saveIDTog );
      saveas( fig, [ saveIDTog '.' fileExt ], fileExt );
    end
  end
end

%% Size
if plotDsize
  varyParam = 'lobst';
  nuWant = [0.3 0.6];
  lWant = [1:23];
  connectDots = 1;
  plotThresLines.flag = 0;
  for ii = plotRngSize
    if ii == 1
      masterD2plot = masterD_size_oe1_bnd1;
      beWant = [0 1 2 3 Inf];
      dDiffWant = 1;
      saveID = 'size_slippery_oe1';
      if plotAllSep == 0
        fig = figure();
        figpos = [1 1 1920 1080];
        fig.WindowStyle = winStyle;
        fig.Position = figpos;
        totRow = length(plotRng2d);
        subplot( totRow, 3, totRow * 3)
        nuWant = [0.3];
        [Dstruct, param] = ...
          diffMatParamExtact( masterD2plot, varyParam, lWant, dDiffWant, beWant, nuWant );
        plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, connectDots, ...
          0,moveSaveMe, saveID, winStyle, fileExt, 1, 2, 0)
        if tempTitle; title('2D Slip oe1 nu = 0.3'); end;
        nuWant = [0.6];
        [Dstruct, param] = ...
          diffMatParamExtact( masterD2plot, varyParam, lWant, dDiffWant, beWant, nuWant );
        plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, connectDots, ...
          0,moveSaveMe, saveID, winStyle, fileExt, 2, 2, 0)
        % stack em
        axTemp{1} = subplot(totRow, 3, 3);
        stackPlots( fig, 3 )
        legH = legend( axTemp{1} , param.legcell );
        legH.Interpreter = 'latex';
        legH.Position = [0.9151 0.4398 0.0783 0.1642];
        %         keyboard
        if saveMe
          savefig( gcf,  saveID );
          saveas( fig, [ saveID '.' fileExt ], fileExt );
        end
        if tempTitle; title('2D Slip oe1 nu = 0.6'); end;
      else
        totRow = 1;
        saveID = 'sizeBd1_oe1';
        nuWant = [0.3 0.6];
        [Dstruct, param] = ...
          diffMatParamExtact( masterD2plot, varyParam, lWant, dDiffWant, beWant, nuWant );
        plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, connectDots, ...
          saveMe,moveSaveMe, saveID, winStyle, fileExt, 1, 1, 1)
        if tempTitle; title('2D Slip oe1'); end;
      end
    end
    if ii == 2
      masterD2plot = masterD_size_oe1_bnd0;
      beWant = [0 1 2 3 Inf];
      dDiffWant = 0;
      saveID = 'size_sticky_oe1';
      if plotAllSep == 0
        fig = figure();
        fig.WindowStyle = winStyle;
        figpos = [1 1 1920 1080];
        fig.Position = figpos;
        totRow = length(plotRng2d);
        subplot( totRow, 3, totRow * 3)
        nuWant = [0.3];
        [Dstruct, param] = ...
          diffMatParamExtact( masterD2plot, varyParam, lWant, dDiffWant, beWant, nuWant );
        plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, connectDots, ...
          0,moveSaveMe, saveID, winStyle, fileExt, 1, 2, 0)
        if tempTitle; title('2D Sticky oe1 nu = 0.3'); end;
        nuWant = [0.6];
        [Dstruct, param] = ...
          diffMatParamExtact( masterD2plot, varyParam, lWant, dDiffWant, beWant, nuWant );
        plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, connectDots, ...
          0,moveSaveMe, saveID, winStyle, fileExt, 2, 2, 0)
        % stack em
        axTemp{1} = subplot(totRow, 3, 3);
        stackPlots( fig, 3 )
        % Clean up legend
        legH = legend( axTemp{1} , param.legcell );
        legH.Interpreter = 'latex';
        legH.Position = [0.9151 0.4398 0.0783 0.1642];
        if saveMe
          savefig( gcf,  saveID );
          saveas( fig, [ saveID '.' fileExt ], fileExt );
        end
        if tempTitle; title('2D Sticky oe1 nu = 0.6'); end;
      else
        %         saveID = 'sizeBd0_oe1';
        nuWant = [0.3 0.6];
        [Dstruct, param] = ...
          diffMatParamExtact( masterD2plot, varyParam, lWant, dDiffWant, beWant, nuWant );
        plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, connectDots, ...
          saveMe,moveSaveMe, saveID, winStyle, fileExt, 1, 1, 1)
        if tempTitle; title('2D Slip oe1'); end;
      end
    end
    if ii == 3
      beWant = [1 2 3 Inf];
      masterD2plot = masterD_bnd1_oe0_size;
      saveID = 'sizeBd1_oe0';
      dDiffWant = 1;
      [Dstruct, param] = ...
        diffMatParamExtact( masterD2plot, varyParam, lWant, dDiffWant, beWant, nuWant );
      plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, connectDots, ...
        saveMe,moveSaveMe, saveID, winStyle, fileExt, 1, 1, 1)
      if tempTitle; title('2D Slip oe0'); end;
    end
    if ii == 4
      beWant = [1 2 3 Inf];
      masterD2plot = masterD_bnd0_oe0_size;
      saveID = 'sizeBd0_oe0';
      dDiffWant = 0;
      [Dstruct, param] = ...
        diffMatParamExtact( masterD2plot, varyParam, lWant, dDiffWant, beWant, nuWant );
      plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, connectDots, ...
        saveMe,moveSaveMe, saveID, winStyle, fileExt, 1, 1, 1)
      if tempTitle; title('2D Sticky oe0'); end;
    end
  end
end

%% bnd diff
if plotDbnddiff
  varyParam = 'bdiff';
  plotThresLines.flag = 0;
  connectDots = 1;
  masterD2plot = masterD_bnddiff;
  dDiffWant = [];
  lWant = [1];
  beWant = [1 2 3 Inf];
  saveID = 'bdiff';
  if plotAllSep == 0
    fig = figure();
    fig.WindowStyle = winStyle;
    figpos = [1 1 1920 1080];
    fig.Position = figpos;
    totRow = length(plotRng2d);
    subplot( totRow, 3, totRow * 3)
    nuWant = [0.3];
    [Dstruct, param] = ...
      diffMatParamExtact( masterD2plot, varyParam, dDiffWant, beWant, nuWant,lWant );
    plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, connectDots, ...
      0,moveSaveMe, saveID, winStyle, fileExt, 1, 2, 0)
    if tempTitle; title('Semi-Sticky nu = 0.3'); end;
    nuWant = [0.6];
    [Dstruct, param] = ...
      diffMatParamExtact( masterD2plot, varyParam, dDiffWant, beWant, nuWant,lWant );
    plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, connectDots, ...
      0,moveSaveMe, saveID, winStyle, fileExt, 2, 2, 0)
    % stack em
    axTemp{1} = subplot(totRow, 3, 3);
    stackPlots( fig, 3 )
    % Clean up legend
    legH = legend( axTemp{1} , param.legcell );
    legH.Interpreter = 'latex';
    legH.Position = [0.9151 0.4398 0.0783 0.1642];
    %     hLegend = findobj(gcf, 'Type', 'Legend');
    %     delete( hLegend( 2:length(hLegend) ) );
    %     hLegend(1).Position = [0.9037 0.2024 0.0834 0.1526];
    if saveMe
      savefig( gcf,  saveID );
      saveas( fig, [ saveID '.' fileExt ], fileExt );
    end
    if tempTitle; title('Semi-Sticky nu = 0.6'); end;
  else
    nuWant = [0.3 0.6];
    [Dstruct, param] = ...
      diffMatParamExtact( masterD2plot, varyParam, dDiffWant, beWant, nuWant,lWant );
    plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, connectDots, ...
      saveMe,moveSaveMe, saveID, winStyle, fileExt, 1, 1, 1)
    if tempTitle; title('Semi-Sticky'); end;
  end
end

%% 3d
if plot3d
  varyParam = 'nu'; % nu, lobst, bdiff
  sizeWant = [1];
  connectDots = 1;
  for ii = plotRng3d
    if ii == 1
      masterD2plot = masterD_Bbar0_pos;
      saveID = 'bnd1_2d';
      dDiffWant = 1;
      beWant = [1 2 3 ];
      nuWant = [0.1 0.2 0.5 0.7 0.9];
      if strcmp( varyParam, 'nu' )
        plotThresLines.flag = 1;
        plotThresLines.uppVal = 0.72;
        plotThresLines.lowVal = 0.4;
      end
      [Dstruct, param] = ...
        diffMatParamExtact( masterD2plot, varyParam, nuWant, dDiffWant, beWant, sizeWant );
      plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, connectDots, ...
        saveMe,moveSaveMe, saveID, winStyle, fileExt, 1, 1, 1)
      if tempTitle; title('2D Slippery'); end;
    end
    if ii == 2
      fig = figure();
      fig.WindowStyle = winStyle;
      figpos = [1 1 1920 1080/2];
      fig.Position = figpos;
      masterD2plot = masterD_3d_bnd1;
      saveID = '3d_slippery';
      dDiffWant = 1;
      beWant = [0 1 2 3 Inf];
      nuWant = [];
      if strcmp( varyParam, 'nu' )
        plotThresLines.flag = 1;
        plotThresLines.uppVal = 0.9;
        plotThresLines.lowVal = 0.7;
      end
      [Dstruct, param] = ...
        diffMatParamExtact( masterD2plot, varyParam, nuWant, dDiffWant, beWant, sizeWant );
      plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, connectDots, ...
        saveMe,moveSaveMe, saveID, winStyle, fileExt, 1, 1, 0)
      % Clean up legend
      legH = legend(  param.legcell );
      legH.Interpreter = 'latex';
      legH.Position = [0.9100 0.3923 0.0838 0.3311];
      if saveMe
        savefig( gcf,  saveID );
        saveas( fig, [ saveID '.' fileExt ], fileExt );
      end
      if tempTitle; title('3D Slippery'); end;
    end
    if ii == 3
      masterD2plot = masterD_BbarInf_pos;
      saveID = 'bnd0_2d';
      dDiffWant = 0;
      beWant = [0 1 2 3 Inf];
      nuWant = [0.1 0.3 0.5 0.7];
      if strcmp( varyParam, 'nu' )
        plotThresLines.flag = 1;
        plotThresLines.uppVal = 0.72;
        plotThresLines.lowVal = 0.4;
      end
      [Dstruct, param] = ...
        diffMatParamExtact( masterD2plot, varyParam, nuWant, dDiffWant, beWant, sizeWant );
      plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, connectDots, ...
        saveMe,moveSaveMe, saveID, winStyle, fileExt, 1, 1, 1)
      if tempTitle; title('2D Sticky'); end;
    end
    if ii == 4
      fig = figure();
      fig.WindowStyle = winStyle;
      figpos = [1 1 1920 1080/2];
      fig.Position = figpos;
      masterD2plot = masterD_3d_bnd0;
      saveID = '3d_sticky';
      dDiffWant = 0;
      beWant = [0 1 2 3 Inf];
      nuWant = [0.1 0.3 0.5 0.6 0.65 0.7 0.75 0.8 0.85 0.9];
      if strcmp( varyParam, 'nu' )
        plotThresLines.flag = 1;
        plotThresLines.uppVal = 0.9;
        plotThresLines.lowVal = 0.7;
      end
      [Dstruct, param] = ...
        diffMatParamExtact( masterD2plot, varyParam, nuWant, dDiffWant, beWant, sizeWant );
      plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, connectDots, ...
        saveMe,moveSaveMe, saveID, winStyle, fileExt, 1, 1, 0)
      % legend
      legH = legend(  param.legcell );
      legH.Interpreter = 'latex';
      legH.Position = [0.9100 0.3923 0.0838 0.3311];
      if saveMe
        savefig( gcf,  saveID );
        saveas( fig, [ saveID '.' fileExt ], fileExt );
      end
      if tempTitle; title('3D Sticky'); end;
    end
  end
end

%% Percolation no bound diff
if plotPercBnd0
  connectDots = 1;
  varyParam = 'nu'; % nu, lobst, bdiff
  plotThresLines.flag = 1;
  plotThresLines.uppVal = 0.72;
  plotThresLines.lowVal = 0.4;
  dDiffWant = 0;
  beWant = [0 2 3 Inf];
  nuWant = [0.1:0.1:0.9];
  if plotAllSep == 0
    fig = figure();
    fig.WindowStyle = winStyle;
    figpos = [1 1 1920 1080];
    fig.Position = figpos;
    totRow = length(plotPercRngBnd0);
    subplot( totRow, 3, totRow * 3)
    saveMeTemp = 0;
  else
    saveMeTemp = saveMe;
    totRow = 1;
  end
  counter = 1;
  for ii = plotPercRngBnd0
    if plotAllSep == 1
      subRow = 1;
    else
      subRow = counter;
    end
    if ii == 1
      masterD2plot = masterD_l1_oe1_bnd0;
      sizeWant = [1];
      saveID = 'sticky_perc_l1_eo1';
      [Dstruct, param] = ...
        diffMatParamExtact( masterD2plot, varyParam, nuWant, dDiffWant, beWant, sizeWant );
      plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, connectDots, ...
        saveMeTemp,moveSaveMe, saveID, winStyle, fileExt,  subRow, totRow, plotAllSep)
      if tempTitle; title('sticky l=1 oe1'); end;
    end
    if ii == 2
      masterD2plot = masterD_l3_oe1_bnd0;
      sizeWant = [3];
      saveID = 'sticky_perc_l3_eo1';
      [Dstruct, param] = ...
        diffMatParamExtact( masterD2plot, varyParam, nuWant, dDiffWant, beWant, sizeWant );
      plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, connectDots, ...
        saveMeTemp,moveSaveMe, saveID, winStyle, fileExt,  subRow, totRow, plotAllSep)
      if tempTitle; title('sticky l=3 oe1'); end;
    end
    if ii == 3
      masterD2plot = masterD_l5_oe1_bnd0;
      sizeWant = [5];
      saveID = 'sticky_perc_l5_eo1';
      [Dstruct, param] = ...
        diffMatParamExtact( masterD2plot, varyParam, nuWant, dDiffWant, beWant, sizeWant );
      plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, connectDots, ...
        saveMeTemp,moveSaveMe, saveID, winStyle, fileExt,  subRow, totRow, plotAllSep)
      if tempTitle; title('sticky l=5 oe1'); end;
    end
    if ii == 4
      masterD2plot = masterD_l7_oe1_bnd0;
      sizeWant = [7];
      saveID = 'sticky_perc_l7_eo1';
      [Dstruct, param] = ...
        diffMatParamExtact( masterD2plot, varyParam, nuWant, dDiffWant, beWant, sizeWant );
      plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, connectDots, ...
        saveMeTemp,moveSaveMe, saveID, winStyle, fileExt,  subRow, totRow, plotAllSep)
      if tempTitle; title('sticky l=7 oe1'); end;
    end
    if ii == 5
      masterD2plot = masterD_l3_oe0;
      sizeWant = [3];
      saveID = 'sticky_perc_l3_eo0';
      [Dstruct, param] = ...
        diffMatParamExtact( masterD2plot, varyParam, nuWant, dDiffWant, beWant, sizeWant );
      plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, connectDots, ...
        saveMeTemp,moveSaveMe, saveID, winStyle, fileExt,  subRow, totRow, plotAllSep)
      if tempTitle; title('sticky l=3 oe0'); end;
    end
    if ii == 6
      masterD2plot = masterD_l5_oe0;
      sizeWant = [5];
      saveID = 'sticky_perc_l5_eo0';
      [Dstruct, param] = ...
        diffMatParamExtact( masterD2plot, varyParam, nuWant, dDiffWant, beWant, sizeWant );
      plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, connectDots, ...
        saveMeTemp,moveSaveMe, saveID, winStyle, fileExt,  subRow, totRow, plotAllSep)
      if tempTitle; title('sticky l=5 oe0'); end;
    end
    counter = counter + 1;
  end
  % Clean up legend and stack enm
  if plotAllSep == 0
    saveID = 'perc_sticky';
    axTemp = cell(1,1);
    axTemp{1} = subplot(totRow, 3, 3);
    stackPlots( fig, 3 )
    legH = legend( axTemp{1} , param.legcell );
    legH.Interpreter = 'latex';
    legH.Position = [0.9119 0.4660 0.0783 0.1321];
    if saveMe
      savefig( gcf,  saveID );
      saveas( fig, [ saveID '.' fileExt ], fileExt );
    end
  end
end

%% Percolation bound diff
if plotPercBnd1
  connectDots = 1;
  varyParam = 'nu'; % nu, lobst, bdiff
  plotThresLines.flag = 1;
  plotThresLines.uppVal = 0.72;
  plotThresLines.lowVal = 0.4;
  dDiffWant = 1;
  beWant = [0 2 3 Inf];
  counter = 1;
  nuWant = [0.1:0.1:0.9];
  if plotAllSep == 0
    fig = figure();
    fig.WindowStyle = winStyle;
    figpos = [1 1 1920 1080];
    fig.Position = figpos;
    totRow = length(plotPercRngBnd1);
    subplot( totRow, 3, totRow * 3)
    saveMeTemp = 0;
  else
    saveMeTemp = saveMe;
    totRow = 1;
  end
  for ii = plotPercRngBnd1
    if plotAllSep == 1
      subRow = 1;
    else
      subRow = counter;
    end
    if ii == 1
      masterD2plot = masterD_l1_oe1_bnd1;
      sizeWant = [1];
      saveID = 'slip_perc_l1_eo1';
      [Dstruct, param] = ...
        diffMatParamExtact( masterD2plot, varyParam, nuWant, dDiffWant, beWant, sizeWant );
      plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, connectDots, ...
        saveMeTemp,moveSaveMe, saveID, winStyle, fileExt, subRow, totRow, plotAllSep)
      if tempTitle; title('slip l=1 oe1'); end;
    end
    if ii == 2
      masterD2plot = masterD_l3_oe1_bnd1;
      sizeWant = [3];
      saveID = 'slip_perc_l3_eo1';
      [Dstruct, param] = ...
        diffMatParamExtact( masterD2plot, varyParam, nuWant, dDiffWant, beWant, sizeWant );
      plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, connectDots, ...
        saveMeTemp,moveSaveMe, saveID, winStyle, fileExt,  subRow, totRow, plotAllSep)
      if tempTitle; title('slip l=3 oe1'); end;
    end
    if ii == 3
      masterD2plot = masterD_l5_oe1_bnd1;
      sizeWant = [5];
      saveID = 'slip_perc_l5_eo1';
      [Dstruct, param] = ...
        diffMatParamExtact( masterD2plot, varyParam, nuWant, dDiffWant, beWant, sizeWant );
      plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, connectDots, ...
        saveMeTemp,moveSaveMe, saveID, winStyle, fileExt, subRow, totRow, plotAllSep)
      if tempTitle; title('slip l=5 oe1'); end;
    end
    if ii == 4
      masterD2plot = masterD_l7_oe1_bnd1;
      sizeWant = [7];
      saveID = 'slip_perc_l7_eo1';
      [Dstruct, param] = ...
        diffMatParamExtact( masterD2plot, varyParam, nuWant, dDiffWant, beWant, sizeWant );
      plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, connectDots, ...
        saveMeTemp,moveSaveMe, saveID, winStyle, fileExt, subRow, totRow, plotAllSep)
      if tempTitle; title('slip l=7 oe1'); end;
    end
    counter = counter + 1;
  end
  % Clean up legend and stack em
  if plotAllSep == 0
    saveID = 'perc_slippery';
    axTemp = cell(1,1);
    axTemp{1} = subplot(totRow, 3, 3);
    stackPlots( fig, 3 )
    legH = legend( axTemp{1} , param.legcell );
    legH.Interpreter = 'latex';
    legH.Position = [0.9129 0.4530 0.0783 0.1321];
    if saveMe
      savefig( gcf,  saveID );
      saveas( fig, [ saveID '.' fileExt ], fileExt );
    end
  end
end

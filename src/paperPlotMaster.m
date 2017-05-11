% paperPlotMaster

function paperPlotMaster( plotParams )
addpath('./src')
plotThresLines.flag = plotParams.plotThresFlag;

% load it
if plotParams.plotDstickSlipp
  if ( any(plotParams.plotRng2d == 1) )
    load('./dataMasterD/masterD_pos_bnd1.mat')
  end
  if ( any(plotParams.plotRng2d == 2) )
    load('./dataMasterD/masterD_neg_bnd1.mat')
  end
  if  ( any(plotParams.plotRng2d == 3) )
    load('./dataMasterD/masterD_pos_bnd0.mat')
  end
  if ( any(plotParams.plotRng2d == 4) )
    load('./dataMasterD/masterD_neg_bnd0.mat')
  end
end
if plotParams.plot3d
  if  ( any(plotParams.plotRng3d == 1) )
    load('./dataMasterD/masterD_Bbar0_pos.mat')
  end
  if ( any(plotParams.plotRng3d == 2) )
    load('./dataMasterD/masterD_3d_bnd0.mat')
  end
  if ( any(plotParams.plotRng3d == 3) )
    load('./dataMasterD/masterD_BbarInf_pos.mat')
  end
  if ( any(plotParams.plotRng3d == 4) )
    load('./dataMasterD/masterD_3d_bnd1.mat')
  end
end
if plotParams.plotDbnddiff
  load('./dataMasterD/masterD_bnddiff.mat')
end
if plotParams.plotDsize
  if ( any(plotParams.plotRngSize == 1) )
    load('./dataMasterD/masterD_size_oe1_bnd1.mat')
  end
  if  ( any(plotParams.plotRngSize == 2) )
    load('./dataMasterD/masterD_size_oe1_bnd0.mat')
  end
  if ( any(plotParams.plotRngSize == 3) )
    load('./dataMasterD/masterD_bnd1_oe0_size.mat')
  end
  if ( any(plotParams.plotRngSize == 4) )
    load('./dataMasterD/masterD_bnd0_oe0_size.mat')
  end
end
if plotParams.plotPercBnd0
  if ( any(plotParams.plotPercRngBnd0 == 1) )
    load('./dataMasterD/masterD_l1_oe1_bnd0.mat')
  end
  if ( any(plotParams.plotPercRngBnd0 == 2) )
    load('./dataMasterD/masterD_l3_oe1_bnd0.mat')
  end
  if ( any(plotParams.plotPercRngBnd0 == 3) )
    load('./dataMasterD/masterD_l5_oe1_bnd0.mat')
  end
  if ( any(plotParams.plotPercRngBnd0 == 4) )
    load('./dataMasterD/masterD_l7_oe1_bnd0.mat')
  end
  if ( any(plotParams.plotPercRngBnd0 == 5) )
    load('./dataMasterD/masterD_l3_oe0.mat')
  end
  if ( any(plotParams.plotPercRngBnd0 == 6) )
    load('./dataMasterD/masterD_l5_oe0.mat')
  end
end

if plotParams.plotPercBnd1
  if ( any(plotParams.plotPercRngBnd0 == 1) )
    load('./dataMasterD/masterD_l1_oe1_bnd1.mat')
  end
  if ( any(plotParams.plotPercRngBnd0 == 2) )
    load('./dataMasterD/masterD_l3_oe1_bnd1.mat')
  end
  if ( any(plotParams.plotPercRngBnd0 == 3) )
    load('./dataMasterD/masterD_l5_oe1_bnd1.mat')
  end
    if ( any(plotParams.plotPercRngBnd0 == 4) )
    load('./dataMasterD/masterD_l7_oe1_bnd1.mat')
  end
end

%%
if plotParams.plotDstickSlipp
  varyParam = 'nu'; % nu, lobst, bdiff
  sizeWant = 1;
  nuWant = [];
  fig = figure();
  figpos = [1 1 1920 1080];
  fig.WindowStyle = plotParams.winStyle;
  fig.Position = figpos;
  connectDots = 0;
  if plotParams.plotAllSep == 0
    totRow = length(plotParams.plotRng2d);
  else
    totRow = 1;
  end
  subplot( totRow, 3, totRow * 3);
  counter = 1;
  for ii = plotParams.plotRng2d
    if plotParams.plotAllSep == 1
      subRow = 1;
    else
      subRow = counter;
    end
    if ii == 1
      masterD2plot = masterD_pos_bnd1;
      saveID = 'pos_bnd1';
      if plotParams.paperTitles 
        saveIDTog = 'figure07';
      else
        saveIDTog = '2d_slippery';
      end
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
        0, 0, saveID, plotParams.winStyle, plotParams.fontSize, plotParams.fileExt, subRow, totRow, plotParams.plotAllSep);
      leg1 = param.legcell;
      if plotParams.tempTitle; title('2D pos Slippery'); end;
    end
    if ii == 2
      masterD2plot = masterD_neg_bnd1;
      saveID = 'neg_bnd1';
      if plotParams.paperTitles 
        saveIDTog = 'figure07';
      else
        saveIDTog = '2d_slippery';
      end
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
        0,0, saveID, plotParams.winStyle, plotParams.fontSize, plotParams.fileExt, subRow, totRow, plotParams.plotAllSep)
      leg2 = param.legcell;
      if plotParams.tempTitle; title('2D neg Slippery'); end;
    end
    if ii == 3
      masterD2plot = masterD_pos_bnd0;
      saveID = 'pos_bnd0';
      if plotParams.paperTitles 
        saveIDTog = 'figure04';
      else
        saveIDTog = '2d_sticky';
      end
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
        0,0, saveID, plotParams.winStyle, plotParams.fontSize, plotParams.fileExt, subRow, totRow, plotParams.plotAllSep)
      leg1 = param.legcell;
      if plotParams.tempTitle; title('2D pos Sticky'); end;
    end
    if ii == 4
      masterD2plot = masterD_neg_bnd0;
      saveID = 'neg_bnd0';
      if plotParams.paperTitles 
        saveIDTog = 'figure04';
      else
        saveIDTog = '2d_sticky';
      end
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
        0,0, saveID, plotParams.winStyle, plotParams.fontSize, plotParams.fileExt, subRow, totRow, plotParams.plotAllSep)
      leg2 = param.legcell;
      if plotParams.tempTitle; title('2D neg Sticky'); end;
    end
    counter = counter + 1;
  end
  % stack em!
  if plotParams.plotAllSep == 0 && length(plotParams.plotRng2d) > 1
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
    if plotParams.saveMe
      savefig( gcf,  saveIDTog );
      saveas( fig, [ saveIDTog '.' plotParams.fileExt ], plotParams.fileExt );
    end
  end
end

%% Size
if plotParams.plotDsize
  varyParam = 'lobst';
  nuWant = [0.3 0.6];
  lWant = [1:23];
  connectDots = 1;
  plotThresLines.flag = 0;
  for ii = plotParams.plotRngSize
    if ii == 1
      masterD2plot = masterD_size_oe1_bnd1;
      beWant = [0 1 2 3 Inf];
      dDiffWant = 1;
      if plotParams.plotAllSep == 0
        if plotParams.paperTitles
          saveID = 'figure13';
        else
          saveID = 'size_slippery_oe1';
        end
        fig = figure();
        figpos = [1 1 1920 1080];
        fig.WindowStyle = plotParams.winStyle;
        fig.Position = figpos;
        totRow = length(plotParams.plotRng2d);
        subplot( totRow, 3, totRow * 3)
        nuWant = [0.3];
        [Dstruct, param] = ...
          diffMatParamExtact( masterD2plot, varyParam, lWant, dDiffWant, beWant, nuWant );
        plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, connectDots, ...
          0,plotParams.moveSaveMe, saveID, plotParams.winStyle, plotParams.fontSize, plotParams.fileExt, 1, 2, 0)
        if plotParams.tempTitle; title('2D Slip oe1 nu = 0.3'); end;
        nuWant = [0.6];
        [Dstruct, param] = ...
          diffMatParamExtact( masterD2plot, varyParam, lWant, dDiffWant, beWant, nuWant );
        plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, connectDots, ...
          0,plotParams.moveSaveMe, saveID, plotParams.winStyle, plotParams.fontSize, plotParams.fileExt, 2, 2, 0)
        % stack em
        axTemp{1} = subplot(totRow, 3, 3);
        stackPlots( fig, 3 )
        legH = legend( axTemp{1} , param.legcell );
        legH.Interpreter = 'latex';
        legH.Position = [0.9151 0.4398 0.0783 0.1642];
        %         keyboard
        if plotParams.saveMe
          savefig( gcf,  saveID );
          saveas( fig, [ saveID '.' plotParams.fileExt ], plotParams.fileExt );
        end
        if plotParams.tempTitle; title('2D Slip oe1 nu = 0.6'); end;
      else
        totRow = 1;
        saveID = 'sizeBd1_oe1';
        nuWant = [0.3 0.6];
        [Dstruct, param] = ...
          diffMatParamExtact( masterD2plot, varyParam, lWant, dDiffWant, beWant, nuWant );
        plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, connectDots, ...
          plotParams.saveMe,plotParams.moveSaveMe, saveID, plotParams.winStyle, plotParams.fontSize, plotParams.fileExt, 1, 1, 1)
        if plotParams.tempTitle; title('2D Slip oe1'); end;
      end
    end
    if ii == 2
      masterD2plot = masterD_size_oe1_bnd0;
      beWant = [0 1 2 3 Inf];
      dDiffWant = 0;
      if plotParams.plotAllSep == 0
        if plotParams.paperTitles
          saveID = 'figure12';
        else
          saveID = 'size_sticky_oe1';
        end
        fig = figure();
        fig.WindowStyle = plotParams.winStyle;
        figpos = [1 1 1920 1080];
        fig.Position = figpos;
        totRow = length(plotParams.plotRng2d);
        subplot( totRow, 3, totRow * 3)
        nuWant = [0.3];
        [Dstruct, param] = ...
          diffMatParamExtact( masterD2plot, varyParam, lWant, dDiffWant, beWant, nuWant );
        plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, connectDots, ...
          0,plotParams.moveSaveMe, saveID, plotParams.winStyle, plotParams.fontSize, plotParams.fileExt, 1, 2, 0)
        if plotParams.tempTitle; title('2D Sticky oe1 nu = 0.3'); end;
        nuWant = [0.6];
        [Dstruct, param] = ...
          diffMatParamExtact( masterD2plot, varyParam, lWant, dDiffWant, beWant, nuWant );
        plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, connectDots, ...
          0,plotParams.moveSaveMe, saveID, plotParams.winStyle, plotParams.fontSize, plotParams.fileExt, 2, 2, 0)
        % stack em
        axTemp{1} = subplot(totRow, 3, 3);
        stackPlots( fig, 3 )
        % Clean up legend
        legH = legend( axTemp{1} , param.legcell );
        legH.Interpreter = 'latex';
        legH.Position = [0.9151 0.4398 0.0783 0.1642];
        if plotParams.saveMe
          savefig( gcf,  saveID );
          saveas( fig, [ saveID '.' plotParams.fileExt ], plotParams.fileExt );
        end
        if plotParams.tempTitle; title('2D Sticky oe1 nu = 0.6'); end;
      else
        %         saveID = 'sizeBd0_oe1';
        nuWant = [0.3 0.6];
        [Dstruct, param] = ...
          diffMatParamExtact( masterD2plot, varyParam, lWant, dDiffWant, beWant, nuWant );
        plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, connectDots, ...
          plotParams.saveMe,plotParams.moveSaveMe, saveID, plotParams.winStyle, plotParams.fontSize, plotParams.fileExt, 1, 1, 1)
        if plotParams.tempTitle; title('2D Slip oe1'); end;
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
        plotParams.saveMe,plotParams.moveSaveMe, saveID, plotParams.winStyle, plotParams.fontSize, plotParams.fileExt, 1, 1, 1)
      if plotParams.tempTitle; title('2D Slip oe0'); end;
    end
    if ii == 4
      beWant = [1 2 3 Inf];
      masterD2plot = masterD_bnd0_oe0_size;
      saveID = 'sizeBd0_oe0';
      dDiffWant = 0;
      [Dstruct, param] = ...
        diffMatParamExtact( masterD2plot, varyParam, lWant, dDiffWant, beWant, nuWant );
      plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, connectDots, ...
        plotParams.saveMe,plotParams.moveSaveMe, saveID, plotParams.winStyle, plotParams.fontSize, plotParams.fileExt, 1, 1, 1)
      if plotParams.tempTitle; title('2D Sticky oe0'); end;
    end
  end
end

%% bnd diff
if plotParams.plotDbnddiff
  varyParam = 'bdiff';
  plotThresLines.flag = 0;
  connectDots = 1;
  masterD2plot = masterD_bnddiff;
  dDiffWant = [];
  lWant = [1];
  beWant = [1 2 3 Inf];
  if plotParams.paperTitles
    saveID = 'figure10';
  else
    saveID = 'bdiff';
  end
  if plotParams.plotAllSep == 0
    fig = figure();
    fig.WindowStyle = plotParams.winStyle;
    figpos = [1 1 1920 1080];
    fig.Position = figpos;
    totRow = length(plotParams.plotRng2d);
    subplot( totRow, 3, totRow * 3)
    nuWant = [0.3];
    [Dstruct, param] = ...
      diffMatParamExtact( masterD2plot, varyParam, dDiffWant, beWant, nuWant,lWant );
    plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, connectDots, ...
      0,plotParams.moveSaveMe, saveID, plotParams.winStyle, plotParams.fontSize, plotParams.fileExt, 1, 2, 0)
    if plotParams.tempTitle; title('Semi-Sticky nu = 0.3'); end;
    nuWant = [0.6];
    [Dstruct, param] = ...
      diffMatParamExtact( masterD2plot, varyParam, dDiffWant, beWant, nuWant,lWant );
    plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, connectDots, ...
      0,plotParams.moveSaveMe, saveID, plotParams.winStyle, plotParams.fontSize, plotParams.fileExt, 2, 2, 0)
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
    if plotParams.saveMe
      savefig( gcf,  saveID );
      saveas( fig, [ saveID '.' plotParams.fileExt ], plotParams.fileExt );
    end
    if plotParams.tempTitle; title('Semi-Sticky nu = 0.6'); end;
  else
    nuWant = [0.3 0.6];
    [Dstruct, param] = ...
      diffMatParamExtact( masterD2plot, varyParam, dDiffWant, beWant, nuWant,lWant );
    plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, connectDots, ...
      plotParams.saveMe,plotParams.moveSaveMe, saveID, plotParams.winStyle, plotParams.fontSize, plotParams.fileExt, 1, 1, 1)
    if plotParams.tempTitle; title('Semi-Sticky'); end;
  end
end

%% 3d
if plotParams.plot3d
  varyParam = 'nu'; % nu, lobst, bdiff
  sizeWant = [1];
  connectDots = 1;
  for ii = plotParams.plotRng3d
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
        plotParams.saveMe,plotParams.moveSaveMe, saveID, plotParams.winStyle, plotParams.fontSize, plotParams.fileExt, 1, 1, 1)
      if plotParams.tempTitle; title('2D Slippery'); end;
    end
    if ii == 2
      fig = figure();
      fig.WindowStyle = plotParams.winStyle;
      figpos = [1 1 1920 1080/2];
      fig.Position = figpos;
      masterD2plot = masterD_3d_bnd1;
      if plotParams.paperTitles
        saveID = 'figure08';
      else
        saveID = '3d_slippery';
      end
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
        plotParams.saveMe,plotParams.moveSaveMe, saveID, plotParams.winStyle, plotParams.fontSize, plotParams.fileExt, 1, 1, 0)
      % Clean up legend
      legH = legend(  param.legcell );
      legH.Interpreter = 'latex';
      legH.Position = [0.9100 0.3923 0.0838 0.3311];
      if plotParams.saveMe
        savefig( gcf,  saveID );
        saveas( fig, [ saveID '.' plotParams.fileExt ], plotParams.fileExt );
      end
      if plotParams.tempTitle; title('3D Slippery'); end;
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
        plotParams.saveMe,plotParams.moveSaveMe, saveID, plotParams.winStyle, plotParams.fontSize, plotParams.fileExt, 1, 1, 1)
      if plotParams.tempTitle; title('2D Sticky'); end;
    end
    if ii == 4
      fig = figure();
      fig.WindowStyle = plotParams.winStyle;
      figpos = [1 1 1920 1080/2];
      fig.Position = figpos;
      masterD2plot = masterD_3d_bnd0;
      if plotParams.paperTitles
        saveID = 'figure06';
      else
        saveID = '3d_sticky';
      end
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
        plotParams.saveMe,plotParams.moveSaveMe, saveID, plotParams.winStyle, plotParams.fontSize, plotParams.fileExt, 1, 1, 0)
      % legend
      legH = legend(  param.legcell );
      legH.Interpreter = 'latex';
      legH.Position = [0.9100 0.3923 0.0838 0.3311];
      if plotParams.saveMe
        savefig( gcf,  saveID );
        saveas( fig, [ saveID '.' plotParams.fileExt ], plotParams.fileExt );
      end
      if plotParams.tempTitle; title('3D Sticky'); end;
    end
  end
end

% plot the fit
if plotParams.plotShowFit == 1
  plotFitExmpl(plotParams.winStyle, plotParams.fontSize)
  if plotParams.saveMe
    saveID = 'figure03';
    savefig( gcf, 'figure03' );
    saveas( gcf, [ saveID '.' plotParams.fileExt ], plotParams.fileExt );
  end
end

%% Percolation no bound diff
if plotParams.plotPercBnd0
  connectDots = 1;
  varyParam = 'nu'; % nu, lobst, bdiff
  plotThresLines.flag = 1;
  plotThresLines.uppVal = 0.72;
  plotThresLines.lowVal = 0.4;
  dDiffWant = 0;
  beWant = [0 2 3 Inf];
  nuWant = [0.1:0.1:0.9];
  if plotParams.plotAllSep == 0
    fig = figure();
    fig.WindowStyle = plotParams.winStyle;
    figpos = [1 1 1920 1080];
    fig.Position = figpos;
    totRow = length(plotParams.plotPercRngBnd0);
    subplot( totRow, 3, totRow * 3)
    plotParams.saveMeTemp = 0;
  else
    plotParams.saveMeTemp = plotParams.saveMe;
    totRow = 1;
  end
  counter = 1;
  for ii = plotParams.plotPercRngBnd0
    if plotParams.plotAllSep == 1
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
        plotParams.saveMeTemp,plotParams.moveSaveMe, saveID, plotParams.winStyle, plotParams.fontSize, plotParams.fileExt,  subRow, totRow, plotParams.plotAllSep)
      if plotParams.tempTitle; title('sticky l=1 oe1'); end;
    end
    if ii == 2
      masterD2plot = masterD_l3_oe1_bnd0;
      sizeWant = [3];
      saveID = 'sticky_perc_l3_eo1';
      [Dstruct, param] = ...
        diffMatParamExtact( masterD2plot, varyParam, nuWant, dDiffWant, beWant, sizeWant );
      plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, connectDots, ...
        plotParams.saveMeTemp,plotParams.moveSaveMe, saveID, plotParams.winStyle, plotParams.fontSize, plotParams.fileExt,  subRow, totRow, plotParams.plotAllSep)
      if plotParams.tempTitle; title('sticky l=3 oe1'); end;
    end
    if ii == 3
      masterD2plot = masterD_l5_oe1_bnd0;
      sizeWant = [5];
      saveID = 'sticky_perc_l5_eo1';
      [Dstruct, param] = ...
        diffMatParamExtact( masterD2plot, varyParam, nuWant, dDiffWant, beWant, sizeWant );
      plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, connectDots, ...
        plotParams.saveMeTemp,plotParams.moveSaveMe, saveID, plotParams.winStyle, plotParams.fontSize, plotParams.fileExt,  subRow, totRow, plotParams.plotAllSep)
      if plotParams.tempTitle; title('sticky l=5 oe1'); end;
    end
    if ii == 4
      masterD2plot = masterD_l7_oe1_bnd0;
      sizeWant = [7];
      saveID = 'sticky_perc_l7_eo1';
      [Dstruct, param] = ...
        diffMatParamExtact( masterD2plot, varyParam, nuWant, dDiffWant, beWant, sizeWant );
      plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, connectDots, ...
        plotParams.saveMeTemp,plotParams.moveSaveMe, saveID, plotParams.winStyle, plotParams.fontSize, plotParams.fileExt,  subRow, totRow, plotParams.plotAllSep)
      if plotParams.tempTitle; title('sticky l=7 oe1'); end;
    end
    if ii == 5
      masterD2plot = masterD_l3_oe0;
      sizeWant = [3];
      saveID = 'sticky_perc_l3_eo0';
      [Dstruct, param] = ...
        diffMatParamExtact( masterD2plot, varyParam, nuWant, dDiffWant, beWant, sizeWant );
      plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, connectDots, ...
        plotParams.saveMeTemp,plotParams.moveSaveMe, saveID, plotParams.winStyle, plotParams.fontSize, plotParams.fileExt,  subRow, totRow, plotParams.plotAllSep)
      if plotParams.tempTitle; title('sticky l=3 oe0'); end;
    end
    if ii == 6
      masterD2plot = masterD_l5_oe0;
      sizeWant = [5];
      saveID = 'sticky_perc_l5_eo0';
      [Dstruct, param] = ...
        diffMatParamExtact( masterD2plot, varyParam, nuWant, dDiffWant, beWant, sizeWant );
      plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, connectDots, ...
        plotParams.saveMeTemp,plotParams.moveSaveMe, saveID, plotParams.winStyle, plotParams.fontSize, plotParams.fileExt,  subRow, totRow, plotParams.plotAllSep)
      if plotParams.tempTitle; title('sticky l=5 oe0'); end;
    end
    counter = counter + 1;
  end
  % Clean up legend and stack enm
  if plotParams.plotAllSep == 0
    saveID = 'perc_sticky';
    axTemp = cell(1,1);
    axTemp{1} = subplot(totRow, 3, 3);
    stackPlots( fig, 3 )
    legH = legend( axTemp{1} , param.legcell );
    legH.Interpreter = 'latex';
    legH.Position = [0.9119 0.4660 0.0783 0.1321];
    if plotParams.saveMe
      savefig( gcf,  saveID );
      saveas( fig, [ saveID '.' plotParams.fileExt ], plotParams.fileExt );
    end
  end
end

%% Percolation bound diff
if plotParams.plotPercBnd1
  connectDots = 1;
  varyParam = 'nu'; % nu, lobst, bdiff
  plotThresLines.flag = 1;
  plotThresLines.uppVal = 0.72;
  plotThresLines.lowVal = 0.4;
  dDiffWant = 1;
  beWant = [0 2 3 Inf];
  counter = 1;
  nuWant = [0.1:0.1:0.9];
  if plotParams.plotAllSep == 0
    fig = figure();
    fig.WindowStyle = plotParams.winStyle;
    figpos = [1 1 1920 1080];
    fig.Position = figpos;
    totRow = length(plotParams.plotPercRngBnd1);
    subplot( totRow, 3, totRow * 3)
    plotParams.saveMeTemp = 0;
  else
    plotParams.saveMeTemp = plotParams.saveMe;
    totRow = 1;
  end
  for ii = plotParams.plotPercRngBnd1
    if plotParams.plotAllSep == 1
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
        plotParams.saveMeTemp,plotParams.moveSaveMe, saveID, plotParams.winStyle, plotParams.fontSize, plotParams.fileExt, subRow, totRow, plotParams.plotAllSep)
      if plotParams.tempTitle; title('slip l=1 oe1'); end;
    end
    if ii == 2
      masterD2plot = masterD_l3_oe1_bnd1;
      sizeWant = [3];
      saveID = 'slip_perc_l3_eo1';
      [Dstruct, param] = ...
        diffMatParamExtact( masterD2plot, varyParam, nuWant, dDiffWant, beWant, sizeWant );
      plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, connectDots, ...
        plotParams.saveMeTemp,plotParams.moveSaveMe, saveID, plotParams.winStyle, plotParams.fontSize, plotParams.fileExt,  subRow, totRow, plotParams.plotAllSep)
      if plotParams.tempTitle; title('slip l=3 oe1'); end;
    end
    if ii == 3
      masterD2plot = masterD_l5_oe1_bnd1;
      sizeWant = [5];
      saveID = 'slip_perc_l5_eo1';
      [Dstruct, param] = ...
        diffMatParamExtact( masterD2plot, varyParam, nuWant, dDiffWant, beWant, sizeWant );
      plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, connectDots, ...
        plotParams.saveMeTemp,plotParams.moveSaveMe, saveID, plotParams.winStyle, plotParams.fontSize, plotParams.fileExt, subRow, totRow, plotParams.plotAllSep)
      if plotParams.tempTitle; title('slip l=5 oe1'); end;
    end
    if ii == 4
      masterD2plot = masterD_l7_oe1_bnd1;
      sizeWant = [7];
      saveID = 'slip_perc_l7_eo1';
      [Dstruct, param] = ...
        diffMatParamExtact( masterD2plot, varyParam, nuWant, dDiffWant, beWant, sizeWant );
      plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, connectDots, ...
        plotParams.saveMeTemp,plotParams.moveSaveMe, saveID, plotParams.winStyle, plotParams.fontSize, plotParams.fileExt, subRow, totRow, plotParams.plotAllSep)
      if plotParams.tempTitle; title('slip l=7 oe1'); end;
    end
    counter = counter + 1;
  end
  % Clean up legend and stack em
  if plotParams.plotAllSep == 0
    saveID = 'perc_slippery';
    axTemp = cell(1,1);
    axTemp{1} = subplot(totRow, 3, 3);
    stackPlots( fig, 3 )
    legH = legend( axTemp{1} , param.legcell );
    legH.Interpreter = 'latex';
    legH.Position = [0.9129 0.4530 0.0783 0.1321];
    if plotParams.saveMe
      savefig( gcf,  saveID );
      saveas( fig, [ saveID '.' plotParams.fileExt ], plotParams.fileExt );
    end
  end
end

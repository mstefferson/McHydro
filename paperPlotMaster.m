addpath('./src')
%%
saveMe = 0;
moveSaveMe = 0;
winStyle = 'normal';
tempTitle = 1;
connectDots = 1;
plotThresLines = 0;
% flags
plotDstickSlipp = 0;
plotDsize = 1;
plotDbnddiff = 0;
plot3d = 0;
plotPerc = 0;
% ranges
plotRng2d = 1; % 1: slip pos, 2: slip neg, 3: stick pos, 4: sticky neg
plotRng3d = 4; % 1: 2d slipp, 2: 3d slipp, 3: 2d sticky, 4: 3d sticky
plotRngSize = 2; % 1: slipp oe1, 2: sticky oe1 3: slipp oe0, 4: sticky oe0, 
%1: l = 1, oe = 1 ; %2: l = 3, oe = 1; 3: l = 5, oe = 1; 4: l = 7, oe = 1; 
%4: l = 3, oe = 0; 5: l = 5, oe = 0;
plotRngPerc = [4]; 
fileExt = 'png';
vertFlag = 0; % for Asym

% load it
if plotDstickSlipp
  if ( ~exist('masterD_bnd1_pos','var') ) && ( any(plotRng2 == 1) )
    load('./dataMasterD/masterD_bnd1_pos.mat')
  end
  if ( ~exist('masterD_bnd1_neg','var')  ) && ( any(plotRng2 == 2) )
    load('./dataMasterD/masterD_bnd1_neg.mat')
  end
  if ( ~exist('masterD_bnd0_pos','var') ) && ( any(plotRng2 == 3) )
    load('./dataMasterD/masterD_bnd0_pos.mat')
  end
  if ( ~exist('masterD_bnd0_neg','var') ) && ( any(plotRng2 == 4) )
    load('./dataMasterD/masterD_bnd0_neg.mat')
  end
end
if plot3d
  if ( ~exist('masterD_Bbar0_pos','var') ) && ( any(plotRng3d == 1) )
    load('./dataMasterD/masterD_Bbar0_pos.mat')
  end
  if ( ~exist('masterD_bnd0_3d','var') ) && ( any(plotRng3d == 2) )
    load('./dataMasterD/masterD_bnd0_3d.mat')
  end
  if ( ~exist('masterD_BbarInf_pos','var') ) && ( any(plotRng3d == 3) )
    load('./dataMasterD/masterD_BbarInf_pos.mat')
  end
  if ( ~exist('masterD_bnd1_3d','var') ) && ( any(plotRng3d == 4) )
    load('./dataMasterD/masterD_bnd1_3d.mat')
  end
end
if plotDbnddiff
  if ( ~exist('masterD_bnddiff','var') )
    load('./dataMasterD/masterD_bnddiff.mat')
  end
end
if plotDsize
  if ( ~exist('masterD_bnd1_oe1_size','var') ) && ( any(plotRngSize == 1) )
    load('./dataMasterD/masterD_bnd1_oe1_size.mat')
  end
  if ( ~exist('masterD_bnd0_oe1_size','var') ) && ( any(plotRngSize == 2) )
    load('./dataMasterD/masterD_bnd0_oe1_size.mat')
  end
  if ( ~exist('masterD_bnd1_oe0_size','var') ) && ( any(plotRngSize == 3) )
    load('./dataMasterD/masterD_bnd1_oe0_size.mat')
  end
  if ( ~exist('masterD_bnd0_oe0_size','var') ) && ( any(plotRngSize == 4) )
    load('./dataMasterD/masterD_bnd0_oe0_size.mat')
  end
end
if plotPerc
  if ( ~exist('masterD_l1_oe1','var') ) && ( any(plotRngPerc == 1) )
    load('./dataMasterD/masterD_l1_oe1.mat')
  end
  if ( ~exist('masterD_l3_oe1','var') ) && ( any(plotRngPerc == 2) )
    load('./dataMasterD/masterD_l3_oe1.mat')
  end
  if ( ~exist('masterD_l5_oe1','var') ) && ( any(plotRngPerc == 3) )
    load('./dataMasterD/masterD_l5_oe1.mat')
  end
  if ( ~exist('masterD_l7_oe1','var') ) && ( any(plotRngPerc == 4) )
    load('./dataMasterD/masterD_l7_oe1.mat')
  end
  if ( ~exist('masterD_l3_oe0','var') ) && ( any(plotRngPerc == 5) )
    load('./dataMasterD/masterD_l3_oe0.mat')
  end
  if ( ~exist('masterD_l5_oe0','var') ) && ( any(plotRngPerc == 6) )
    load('./dataMasterD/masterD_l5_oe0.mat')
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
  for ii = plotRng2d
    if ii == 1
      masterD2plot = masterD_bnd1_pos;
      saveID = 'bnd1_pos';
      dDiffWant = 1;
      beWant = [0 1 2 3 4 5 10];
      [Dstruct, param] = ...
        diffMatParamExtact( masterD2plot, varyParam, nuWant, dDiffWant, beWant, sizeWant );
      plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, connectDots, ...
        saveMe,moveSaveMe, saveID, winStyle,fileExt)
      if tempTitle; title('2D pos Slippery'); end;
    end
    if ii == 2
      masterD2plot = masterD_bnd1_neg;
      saveID = 'bnd1_neg';
      dDiffWant = 1;
      beWant = [0 -1 -2 -3 -4 -5 -10];
      [Dstruct, param] = ...
        diffMatParamExtact( masterD2plot, varyParam, nuWant, dDiffWant, beWant, sizeWant );
      plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, connectDots, ...
        saveMe,moveSaveMe, saveID, winStyle,fileExt)
      if tempTitle; title('2D neg Slippery'); end;
    end
    if ii == 3
      masterD2plot = masterD_bnd0_pos;
      saveID = 'bnd0_pos';
      if strcmp( varyParam, 'nu' )
        plotThresLines = 1;
      end
      dDiffWant = 0;
      beWant = [0 2 4 10 Inf];
      [Dstruct, param] = ...
        diffMatParamExtact( masterD2plot, varyParam, nuWant, dDiffWant, beWant, sizeWant );
      plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, connectDots, ...
        saveMe,moveSaveMe, saveID, winStyle,fileExt)
      if tempTitle; title('2D pos Sticky'); end;
    end
    if ii == 4
      masterD2plot = masterD_bnd1_neg;
      saveID = 'bnd0_neg';
      if strcmp( varyParam, 'nu' )
        plotThresLines = 1;
      end
      dDiffWant = 0;
      beWant = [0 -1 -2 -3 -4 -5];
      [Dstruct, param] = ...
        diffMatParamExtact( masterD2plot, varyParam, nuWant, dDiffWant, beWant, sizeWant );
      plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, connectDots, ...
        saveMe,moveSaveMe, saveID, winStyle,fileExt)
      if tempTitle; title('2D neg Sticky'); end;
    end
  end
end

%% Size
if plotDsize
  varyParam = 'lobst';
  nuWant = [0.3 0.6];
  lWant = [1:23];
  for ii = plotRngSize
    if ii == 1
      beWant = [1 2 3 Inf];
      masterD2plot = masterD_bnd1_oe1_size;
      saveID = 'sizeBd1_oe1';
      dDiffWant = 1;
      [Dstruct, param] = ...
        diffMatParamExtact( masterD2plot, varyParam, lWant, dDiffWant, beWant, nuWant );
      plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, connectDots, ...
        saveMe,moveSaveMe, saveID, winStyle,fileExt)
      if tempTitle; title('2D Slip oe1'); end;
    end
    if ii == 2
      beWant = [0 1 2 3 Inf];
      masterD2plot = masterD_bnd0_oe1_size;
      saveID = 'sizeBd0_oe1';
      dDiffWant = 0;
      [Dstruct, param] = ...
        diffMatParamExtact( masterD2plot, varyParam, lWant, dDiffWant, beWant, nuWant );
      plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, connectDots, ...
        saveMe,moveSaveMe, saveID, winStyle,fileExt)
      if tempTitle; title('2D Sticky oe1'); end;
    end
    if ii == 3
      beWant = [1 2 3 Inf];
      masterD2plot = masterD_bnd1_oe0_size;
      saveID = 'sizeBd1_oe0';
      dDiffWant = 1;
      [Dstruct, param] = ...
        diffMatParamExtact( masterD2plot, varyParam, lWant, dDiffWant, beWant, nuWant );
      plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, connectDots, ...
        saveMe,moveSaveMe, saveID, winStyle,fileExt)
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
        saveMe,moveSaveMe, saveID, winStyle,fileExt)
      if tempTitle; title('2D Sticky oe0'); end;
    end
  end
end

%% bnd diff
if plotDbnddiff
  varyParam = 'bdiff';
  %   masterD2plot = masterD_bnddiff_test;
  masterD2plot = masterD_bnddiff;
  saveID = 'bdiff';
  dDiffWant = [];
  beWant = [1 2 3 Inf];
  nuWant = [0.3 0.6];
  lWant = [1];
  [Dstruct, param] = ...
    diffMatParamExtact( masterD2plot, varyParam, dDiffWant, beWant, nuWant,lWant );
  plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, connectDots, ...
    saveMe,moveSaveMe, saveID, winStyle,fileExt)
  if tempTitle; title('Semi-Sticky'); end;
end

%% 3d
if plot3d
  varyParam = 'nu'; % nu, lobst, bdiff
  sizeWant = [1];
  for ii = plotRng3d
    if ii == 1
      masterD2plot = masterD_Bbar0_pos;
      saveID = 'bnd1_2d';
      dDiffWant = 1;
      beWant = [1 2 3 ];
      nuWant = [0.1 0.2 0.5 0.7 0.9];
      [Dstruct, param] = ...
        diffMatParamExtact( masterD2plot, varyParam, nuWant, dDiffWant, beWant, sizeWant );
      plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, connectDots, ...
        saveMe,moveSaveMe, saveID, winStyle,fileExt)
      if tempTitle; title('2D Slippery'); end;
    end
    if ii == 2
      masterD2plot = masterD_bnd1_3d;
      saveID = 'bnd1_3d';
      dDiffWant = 1;
      beWant = [1 2 3 ];
      nuWant = [0.1 0.2 0.5 0.7 0.9];
      [Dstruct, param] = ...
        diffMatParamExtact( masterD2plot, varyParam, nuWant, dDiffWant, beWant, sizeWant );
      plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, connectDots, ...
        saveMe,moveSaveMe, saveID, winStyle,fileExt)
      if tempTitle; title('3D Slippery'); end;
    end
    if ii == 3
      masterD2plot = masterD_BbarInf_pos;
      saveID = 'bnd0_2d';
      dDiffWant = 0;
      beWant = [1 2 3 Inf];
      nuWant = [0.1 0.3 0.5 0.7];
      if strcmp( varyParam, 'nu' )
        plotThresLines = 1;
      end
      [Dstruct, param] = ...
        diffMatParamExtact( masterD2plot, varyParam, nuWant, dDiffWant, beWant, sizeWant );
      plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, connectDots, ...
        saveMe,moveSaveMe, saveID, winStyle,fileExt)
      if tempTitle; title('2D Sticky'); end;
    end
    if ii == 4
      masterD2plot = masterD_bnd0_3d;
      saveID = 'bnd0_3d';
      dDiffWant = 0;
      beWant = [1 2 3 Inf];
      nuWant = [0.1 0.3 0.5 0.6 0.65 0.7 0.75 0.8 0.85 0.9];
      if strcmp( varyParam, 'nu' )
        plotThresLines = 1;
      end
      [Dstruct, param] = ...
        diffMatParamExtact( masterD2plot, varyParam, nuWant, dDiffWant, beWant, sizeWant );
      plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, connectDots, ...
        saveMe,moveSaveMe, saveID, winStyle,fileExt)
      if tempTitle; title('3D Sticky'); end;
    end
  end
end

%% Percolation
if plotPerc
  varyParam = 'nu'; % nu, lobst, bdiff
  dDiffWant = 0;
  beWant = [0 2 3];
  for ii = plotRngPerc
    if ii == 1
      masterD2plot = masterD_l1_oe1;
      sizeWant = [1];
      saveID = 'perc_l1_eo1';
      nuWant = [];
      [Dstruct, param] = ...
        diffMatParamExtact( masterD2plot, varyParam, nuWant, dDiffWant, beWant, sizeWant );
      plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, connectDots, ...
        saveMe,moveSaveMe, saveID, winStyle,fileExt)
      if tempTitle; title('l=1 oe1'); end;
    end
    if ii == 2
      masterD2plot = masterD_l3_oe1;
      sizeWant = [3];
      saveID = 'perc_l3_eo1';
      nuWant = [];
      [Dstruct, param] = ...
        diffMatParamExtact( masterD2plot, varyParam, nuWant, dDiffWant, beWant, sizeWant );
      plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, connectDots, ...
        saveMe,moveSaveMe, saveID, winStyle,fileExt)
      if tempTitle; title('l=3 oe1'); end;
    end
    if ii == 3
      masterD2plot = masterD_l5_oe1;
      sizeWant = [5];
      saveID = 'perc_l5_eo1';
      nuWant = [];
      [Dstruct, param] = ...
        diffMatParamExtact( masterD2plot, varyParam, nuWant, dDiffWant, beWant, sizeWant );
      plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, connectDots, ...
        saveMe,moveSaveMe, saveID, winStyle,fileExt)
      if tempTitle; title('l=5 oe1'); end;
    end
    if ii == 4
      masterD2plot = masterD_l7_oe1;
      sizeWant = [7];
      saveID = 'perc_l7_eo1';
      nuWant = [];
      [Dstruct, param] = ...
        diffMatParamExtact( masterD2plot, varyParam, nuWant, dDiffWant, beWant, sizeWant );
      plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, connectDots, ...
        saveMe,moveSaveMe, saveID, winStyle,fileExt)
      if tempTitle; title('l=7 oe1'); end;
    end
    if ii == 5
      masterD2plot = masterD_l3_oe0;
      sizeWant = [3];
      saveID = 'perc_l3_eo0';
      nuWant = [];
      [Dstruct, param] = ...
        diffMatParamExtact( masterD2plot, varyParam, nuWant, dDiffWant, beWant, sizeWant );
      plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, connectDots, ...
        saveMe,moveSaveMe, saveID, winStyle,fileExt)
      if tempTitle; title('l=3 oe0'); end;
    end
    if ii == 6
      masterD2plot = masterD_l5_oe0;
      sizeWant = [5];
      saveID = 'perc_l5_eo0';
      nuWant = [];
      [Dstruct, param] = ...
        diffMatParamExtact( masterD2plot, varyParam, nuWant, dDiffWant, beWant, sizeWant );
      plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, connectDots, ...
        saveMe,moveSaveMe, saveID, winStyle,fileExt)
      if tempTitle; title('l=5 oe0'); end;
    end
  end
end
%%
% plotDiffTaAll(masterD_Bbar0,masterD_BbarInf_neg,masterD_BbarInf_pos,plotRng2d,...
%   saveMe,moveSaveMe, winStyle,fileExt)
%%
%plotVarMSDfixedBe(saveMe,moveSaveMe, winStyle,fileExt)
%%
% plotCmprMotBndDTaAlpha(masterD_Bbar0,masterD_BbarInf_pos,saveMe,moveSaveMe, winStyle,fileExt)
%%
% plotCmprMotBndDTa(masterD_Bbar0,masterD_BbarInf_pos,saveMe,moveSaveMe, winStyle,fileExt)
%%
%plotMSD_MDBrequest(saveMe,moveSaveMe, winStyle,fileExt)

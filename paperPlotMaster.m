addpath('./src')
%%
saveMe = 0;
moveSaveMe = 0;
winStyle = 'normal';
plotDstickSlipp = 0;
plotDsize = 1;
plotDbnddiff = 0;
plot3d = 0;
plotRng2d = [1]; % 1: slip pos, 2: slip neg, 3: stick pos, 4: sticky neg
plotRng3d = [4]; % 1: 2d slipp, 2: 3d slipp, 3: 2d sticky, 4: 3d sticky
fileExt = 'eps';
vertFlag = 0; % for Asym

% load it
if ~exist('masterD_Bbar0_pos','var')
  load('masterD_Bbar0_pos.mat')
end
if ~exist('masterD_Bbar0_neg','var')
  load('masterD_Bbar0_neg.mat')
end
if ~exist('masterD_BbarInf_neg','var')
  load('masterD_BbarInf_neg.mat')
end
if ~exist('masterD_BbarInf_pos','var')
  load('masterD_BbarInf_pos.mat')
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
      masterD2plot = masterD_Bbar0_pos;
      %       masterD2plot = masterD_Bbar0_temp;
      saveID = 'Bbar0Pos';
      plotThresLines = 0;
      dDiffWant = 1;
      beWant = [0 1 2 3 4 5 10];
      [Dstruct, param] = ...
        diffMatParamExtact( masterD2plot, varyParam, nuWant, dDiffWant, beWant, sizeWant );
      plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, ...
        saveMe,moveSaveMe, saveID, winStyle,fileExt)
    end
    if ii == 2
      masterD2plot = masterD_Bbar0_neg;
      saveID = 'Bbar0Neg';
      plotThresLines = 0;
      dDiffWant = 1;
      beWant = [0 -1 -2 -3 -4 -5 -10];
      [Dstruct, param] = ...
        diffMatParamExtact( masterD2plot, varyParam, nuWant, dDiffWant, beWant, sizeWant );
      plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, ...
        saveMe,moveSaveMe, saveID, winStyle,fileExt)
    end
    if ii == 3
      masterD2plot = masterD_BbarInf_pos;
      %       masterD2plot = masterD_BbarInf_pos_temp;
      saveID = 'BbarInfPos';
      if strcmp( varyParam, 'nu' )
        plotThresLines = 1;
      else
        plotThresLines = 0;
      end
      dDiffWant = 0;
      beWant = [0 2 4 10 Inf];
      [Dstruct, param] = ...
        diffMatParamExtact( masterD2plot, varyParam, nuWant, dDiffWant, beWant, sizeWant );
      plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, ...
        saveMe,moveSaveMe, saveID, winStyle,fileExt)
    end
    if ii == 4
      masterD2plot = masterD_BbarInf_neg;
      %         masterD2plot = masterD_BbarInf_neg_temp;
      saveID = 'BbarInfNeg';
      if strcmp( varyParam, 'nu' )
        plotThresLines = 1;
      else
        plotThresLines = 0;
      end
      dDiffWant = 0;
      beWant = [0 -1 -2 -3 -4 -5];
      [Dstruct, param] = ...
        diffMatParamExtact( masterD2plot, varyParam, nuWant, dDiffWant, beWant, sizeWant );
      plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, ...
        saveMe,moveSaveMe, saveID, winStyle,fileExt)
    end
  end
end
%%
if plotDsize
  varyParam = 'lobst';
  nuWant = [0.3 0.6];
  lWant = [1:95];
  for ii = plotRng2d
    if ii == 1
      beWant = [1 2 3 Inf];
      masterD2plot = masterD_bnd1_size;
      saveID = 'sizeBd1';
      plotThresLines = 0;
      dDiffWant = 1;
      [Dstruct, param] = ...
        diffMatParamExtact( masterD2plot, varyParam, lWant, dDiffWant, beWant, nuWant );
      plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, ...
        saveMe,moveSaveMe, saveID, winStyle,fileExt)
    end
    if ii == 3
      beWant = [1 2 3 Inf];
      masterD2plot = masterD_bnd0_size;
      saveID = 'sizeBd0';
      plotThresLines = 0;
      dDiffWant = 0;
      [Dstruct, param] = ...
        diffMatParamExtact( masterD2plot, varyParam, lWant, dDiffWant, beWant, nuWant );
      plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, ...
        saveMe,moveSaveMe, saveID, winStyle,fileExt)
    end
  end
end

if plotDbnddiff
  varyParam = 'bdiff';
  %   masterD2plot = masterD_bnddiff_test;
  masterD2plot = masterD_bnddiff;
  saveID = 'bdiff';
  plotThresLines = 0;
  dDiffWant = [];
  beWant = [1 2 3 Inf];
  nuWant = [0.3 0.6];
  lWant = [1];
  [Dstruct, param] = ...
    diffMatParamExtact( masterD2plot, varyParam, dDiffWant, beWant, nuWant,lWant );
  plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, ...
    saveMe,moveSaveMe, saveID, winStyle,fileExt)
end

if plot3d
  varyParam = 'nu'; % nu, lobst, bdiff
  sizeWant = [1];
  for ii = plotRng3d
    if ii == 1
      masterD2plot = masterD_Bbar0_pos;
      %       masterD2plot = masterD_Bbar0_temp;
      saveID = 'bnd1_2d';
      plotThresLines = 0;
      dDiffWant = 1;
      beWant = [1 2 3 ];
      nuWant = [0.1 0.2 0.5 0.7 0.9];
      [Dstruct, param] = ...
        diffMatParamExtact( masterD2plot, varyParam, nuWant, dDiffWant, beWant, sizeWant );
      plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, ...
        saveMe,moveSaveMe, saveID, winStyle,fileExt)
    end
    if ii == 2
      masterD2plot = masterD_bnd1_3d;
      saveID = 'bnd1_3d';
      plotThresLines = 0;
      dDiffWant = 1;
      beWant = [1 2 3 ];
      nuWant = [0.1 0.2 0.5 0.7 0.9];
      [Dstruct, param] = ...
        diffMatParamExtact( masterD2plot, varyParam, nuWant, dDiffWant, beWant, sizeWant );
      plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, ...
        saveMe,moveSaveMe, saveID, winStyle,fileExt)
    end
    if ii == 3
      masterD2plot = masterD_BbarInf_pos;
      %       masterD2plot = masterD_BbarInf_pos_temp;
      saveID = 'bnd0_2d';
      plotThresLines = 0;
      dDiffWant = 0;
      beWant = [1 2 3 Inf];
      nuWant = [0.1 0.3 0.5 0.7];
      if strcmp( varyParam, 'nu' )
        plotThresLines = 1;
      else
        plotThresLines = 0;
      end
      [Dstruct, param] = ...
        diffMatParamExtact( masterD2plot, varyParam, nuWant, dDiffWant, beWant, sizeWant );
      plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, ...
        saveMe,moveSaveMe, saveID, winStyle,fileExt)
    end
    if ii == 4
      masterD2plot = masterD_bnd0_3d;
      saveID = 'bnd0_3d';
      plotThresLines = 0;
      dDiffWant = 0;
      beWant = [1 2 3 Inf];
      nuWant = [0.1 0.3 0.5 0.7 0.9];
      if strcmp( varyParam, 'nu' )
        plotThresLines = 1;
      else
        plotThresLines = 0;
      end
      [Dstruct, param] = ...
        diffMatParamExtact( masterD2plot, varyParam, nuWant, dDiffWant, beWant, sizeWant );
      plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, ...
        saveMe,moveSaveMe, saveID, winStyle,fileExt)
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

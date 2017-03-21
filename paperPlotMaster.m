addpath('./src')
%%
saveMe = 0;
moveSaveMe = 0;
winStyle = 'docked';
plotDstickSlipp = 0;
plotDsize = 0;
plotDbnddiff = 1;
plotRng = 1:2; % 1: slip pos, 2: slip neg, 3: stick pos, 4: sticky neg
fileExt = 'eps';
vertFlag = 0; % for Asym
varyParam = 'nu'; % nu, lobst, bdiff

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
  sizeWant = 1;
  nuWant = [];
  for ii = plotRng
    if ii == 1
      masterD2plot = masterD_Bbar0_pos;
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
  masterD2plot = masterD_size_bd0_test ;
  saveID = 'sizeBd0';
  plotThresLines = 0;
  dDiffWant = 0;
  beWant = [1 2 3 Inf];
  nuWant = [0.3 0.6];
  lWant = [1:23];
  [Dstruct, param] = ...
    diffMatParamExtact( masterD2plot, varyParam, lWant, dDiffWant, beWant, nuWant );
  plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, ...
    saveMe,moveSaveMe, saveID, winStyle,fileExt)
end

if plotDbnddiff
  varyParam = 'bdiff';
  masterD2plot = masterD_bnddiff_test;
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

%%
% plotDiffTaAll(masterD_Bbar0,masterD_BbarInf_neg,masterD_BbarInf_pos,plotRng,...
%   saveMe,moveSaveMe, winStyle,fileExt)
%%
%plotVarMSDfixedBe(saveMe,moveSaveMe, winStyle,fileExt)
%%
% plotCmprMotBndDTaAlpha(masterD_Bbar0,masterD_BbarInf_pos,saveMe,moveSaveMe, winStyle,fileExt)
%%
% plotCmprMotBndDTa(masterD_Bbar0,masterD_BbarInf_pos,saveMe,moveSaveMe, winStyle,fileExt)
%%
%plotMSD_MDBrequest(saveMe,moveSaveMe, winStyle,fileExt)

addpath('./src')
%%
saveMe = 0;
moveSaveMe = 0;
winStyle = 'docked';
plotRng = 1:4; % 1: slip pos, 2: slip neg, 3: stick pos, 4: sticky neg
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
for ii = plotRng
  if ii == 1
    masterD2plot = masterD_Bbar0_pos_new;
    saveID = 'Bbar0Pos';
    dDiffWant = 1;
    beWant = [0 1 2 3 4 5 10];
      plotThresLines = 0;
    sizeWant = 1;
    [Dstruct, param] = ...
      diffMatParamExtact( masterD2plot, varyParam, dDiffWant, beWant, sizeWant );
    %plotDiffTaAlpha(masterD2plot, be2plot, varyParam, plotThresLines, ...
      %saveMe,moveSaveMe, saveID, winStyle,fileExt)
    plotDiffTaAlphaStruct(Dstruct, param, plotThresLines, ...
      saveMe,moveSaveMe, saveID, winStyle,fileExt)
  end
  if ii == 2
    masterD2plot = masterD_Bbar0_neg;
    saveID = 'Bbar0Neg';
    beWant = [0 -1 -2 -3 -4 -5];
    plotThresLines = 0;
    plotDiffTaAlpha(masterD2plot, beWant, varyParam, plotThresLines, ...
      saveMe,moveSaveMe, saveID, winStyle,fileExt)
  end
  if ii == 3
    masterD2plot = masterD_BbarInf_pos;
    saveID = 'BbarInfPos';
    beWant = [0 2 4 10 Inf];
    if strcmp( varyParam, 'nu' ) 
      plotThresLines = 1;
    else
      plotThresLines = 0;
    end
    plotDiffTaAlpha(masterD2plot, beWant, varyParam, plotThresLines, ...
      saveMe,moveSaveMe, saveID, winStyle,fileExt)
  end
  if ii == 4
    masterD2plot = masterD_BbarInf_neg;
    saveID = 'BbarInfNeg';
    beWant = [0 -1 -2 -3 -4 -5];
    if strcmp( varyParam, 'nu' ) 
      plotThresLines = 1;
    else
      plotThresLines = 0;
    end
    plotDiffTaAlpha(masterD2plot, beWant, varyParam, plotThresLines, ...
      saveMe,moveSaveMe, saveID, winStyle,fileExt)
  end
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

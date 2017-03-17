addpath('./src')
%%
saveMe = 0;
moveSaveMe = 0;
winStyle = 'docked';
plotRng = 1:4; % 1: slip pos, 2: slip neg, 3: stick pos, 4: sticky neg
fileExt = 'eps';
vertFlag = 0; % for Asym
varyParam = 'bdiff'; % nu, lobst, bdiff

if ~exist('masterD_Bbar0','var')
  load('masterD_Bbar0.mat')
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
plotDiffTaAlpha(masterD_Bbar0,masterD_BbarInf_neg,masterD_BbarInf_pos,varyParam, ...
  plotRng,saveMe,moveSaveMe, winStyle,fileExt)
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


%%
plotParams.saveMe = 0;
plotParams.paperTitles = 1; % use paper titles
plotParams.moveSaveMe = 0;
plotParams.winStyle = 'normal';
plotParams.fileExt = 'png';
plotParams.fontSize = 20;
plotParams.tempTitle = 0;
plotParams.plotAllSep = 0; % plot everything seperately
plotParams.plotThresFlag = 1;
% flags
plotParams.plotDstickSlipp = 1;
plotParams.plotDsize = 0;
plotParams.plotDbnddiff = 0;
plotParams.plot3d = 0;
plotParams.plotShowFit = 0;
plotParams.plotPercBnd0 = 0;
plotParams.plotPercBnd1 = 0;

% ranges
plotParams.plotRng2d = [1]; % 1: slip pos, 2: slip neg, 3: stick pos, 4: sticky neg
plotParams.plotRngSize = 2; % 1: slipp oe1, 2: sticky oe1 3: slipp oe0, 4: sticky oe0,
plotParams.plotRng3d = [2 4]; % 1: 2d slipp, 2: 3d slipp, 3: 2d sticky, 4: 3d sticky
%1: l = 1, oe = 1 ; %2: l = 3, oe = 1; 3: l = 5, oe = 1; 4: l = 7, oe = 1; 4: l = 3, oe = 0; 5: l = 5, oe = 0;
plotParams.plotPercRngBnd0 = [1 2 4];
%1: l = 1, oe = 1 ; %2: l = 3, oe = 1; 3: l = 5; 3: l = 7,
plotParams.plotPercRngBnd1 = [1 2 4];

paperPlotMaster( plotParams )

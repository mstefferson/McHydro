function ax = initAnimation(grid)
clf
numTicks = 5;
ax=gca;
axis square;
ax.XGrid='on';
ax.YGrid='on';
ax.XLim=[0.5 grid.sizeV(1)+0.5];
ax.YLim=[0.5 grid.sizeV(2)+0.5];
tickAmountX = grid.sizeV(1) / numTicks;
tickAmountY = grid.sizeV(2) / numTicks;
ax.XTick=[0:tickAmountX:grid.sizeV(1)];
ax.YTick=[0:tickAmountY:grid.sizeV(2)];
ax.XLabel.String='$$ x $$ '; ax.YLabel.String='$$ y $$';
ax.FontSize=14;


%%
function plotLnMSDaveGrStructs( bind, bBar, ffo, parentpath, plotshifted, saveMe )

figure()
%
legffo = cell( length(ffo) , 1 );
legbind = cell( length(bind) , 1 );
for ii = 1:length(ffo)
  ffoTemp = ffo(ii);
  legffo{ii} = ['\nu = ' num2str( ffoTemp, '%.2f' ) ];
  for jj = 1:length(bind)
    bindTemp = bind(jj);
    legbind{jj} = cellstr( sprintf('G = %.2f', bindTemp) );
    fileId = [ 'aveGrid_msd_unBbar0_Bbar' num2str(bBar) ...
      '_bind' num2str(bind) '_fo' num2str(ffoTemp, '%.2f') '*'];
    file = dir( [parentpath fileId] );
    load( [parentpath file.name] );
    
    if plotshifted
      plot( log10( aveGrid.time ), log10( aveGrid.msdW ./ aveGrid.time ) - ...
        max( log10( aveGrid.msdW ./ aveGrid.time ) ) );
    else
      plot( log10( aveGrid.time ), log10( aveGrid.msdW ./ aveGrid.time ) )
    end
    %       keyboard
    ylabel( ' log_{10} ( \langle r^2  \rangle / t ) ' );
    xlabel( ' log_{10} (t) ' );
    hold(gca,'on')
    
  end
end

if length(bind) == 1
  legend( legffo,'location','best' );
  titstr = [ '\Delta G = ' num2str(bind) ' bBar = ' num2str(bBar) ];
else
  legend( legbind, 'location','best' );
  titstr = [ '\nu = ' num2str(ffo)  ' bBar = ' num2str(bBar)  ];
end
ax = gca;
title(titstr)
for ii = 1:length(ax.Children)
  ax.Children(ii).LineWidth = 3;
end

if saveMe
  if length(bind) == 1
    savestr = [ 'log' '_be' num2str(bind) '_hop' ...
      num2str(bBar) '_'  num2str(Id) '.fig'];
    savefig( gcf, savestr );
  else
    savestr = [ 'log' '_nu' num2str(ffo) '_hop' ...
      num2str(bBar) '_'  num2str(Id) '.fig'];
    savefig( gcf, savestr );
  end
end

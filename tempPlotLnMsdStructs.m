%%
plotfig = 0;
plotlog = 1;
plotshifted = 0;
olddata = 0;

bind = 10;
bBar = 0;
Id = 1;

% ffo =   [0.05:0.05:0.95];
ffo =   [0.05:0.05:0.6];

figure()
parentpath = '/home/mws/McHydro/gridAveMSDdata/';
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
    
    
    if plotfig
      plot( aveGrid.time(1:end), aveGrid.msd(1:end) )
      ttlstr = ['ff = ' num2str(ffoTemp) ' be = ' num2str(bindTemp) ' hop = ' num2str(bBar) ];
      title(ttlstr)
      ylabel( ' \langle r^2 \rangle ' );
      xlabel( ' t ' );
      savestr = [ 'msd' '_ff' num2str(ffoTemp) '_be' num2str(bindTemp) '_hop' ...
        num2str(bBar) '_'  num2str(Id) '.fig' ];
      savefig(gcf,savestr)
    end
    
    if plotlog
      
      inds = 1:length(aveGrid.time);
      %       logMSDplot( aveGrid.time(1:end), aveGrid.msd(1:end), ffoTemp, bindTemp, bBar, Id )
      
      if olddata
        if plotshifted
          plot( log10( aveGrid.time ), log10( aveGrid.msd ./ aveGrid.time ) - ...
            max( log10( aveGrid.msd ./ aveGrid.time ) ) );
        else
          plot( log10( aveGrid.time ), log10( aveGrid.msd ./ aveGrid.time ) )
        end
      else
        if plotshifted
          plot( log10( aveGrid.time ), log10( aveGrid.msdW ./ aveGrid.time ) - ...
            max( log10( aveGrid.msdW ./ aveGrid.time ) ) );
        else
          plot( log10( aveGrid.time ), log10( aveGrid.msdW ./ aveGrid.time ) )
        end
      end
      %       keyboard
      ylabel( ' log_{10} ( \langle r^2  \rangle / t ) ' );
      xlabel( ' log_{10} (t) ' );
      %       plot( aveGrid.time, aveGrid.msd )
      savestr = [ 'log' '_ff' num2str(ffoTemp) '_be' num2str(bindTemp) '_hop' ...
        num2str(bBar) '_'  num2str(Id) '.fig'];
      
      hold(gca,'on')
      %       keyboard
%       savefig(gcf,savestr)
    end
  end
end

if length(ffo) > length(bind)
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


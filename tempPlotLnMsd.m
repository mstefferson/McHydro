%%
plotfig = 0;
plotlog = 1;
ffo = [0.1:0.1:0.9];
bind = -10;
bBar = Inf;
Id = 1;

% load first out here

for ii = 1:length(ffo)
  ffoTemp = ffo(ii);
  fileId = [ 'msd_unBbar0_Bbar' num2str(bBar) ...
    '_bind' num2str(bind) '_fo' num2str(ffoTemp, '%.2f') '*'];
  files = dir(fileId);
  
  load( files(1).name );
  msdAve = msd(:,1);
  timeAve = dtime;
  errorAve = msd(:,2) ./ sqrt( msd(:,3) );
  
  for jj = 2:length(files)
    load( files(jj).name );
    msdAve =  msdAve + msd(:,1);
    timeAve = timeAve + dtime;
    errorAve = errorAve + msd(:,2) ./ sqrt( msd(:,3) );
  end
  
  msdAve = msdAve ./ length(files);
  timeAve = timeAve ./ length(files);
  
  if plotfig
    figure()
    plot( timeAve(1:end), msdAve(1:end) )
    ttlstr = ['ff = ' num2str(ffoTemp) ' be = ' num2str(bind) ' hop = ' num2str(bBar) ];
    title(ttlstr)
    ylabel( ' \langle r^2 \rangle ' );
    xlabel( ' t ' );
    savestr = [ 'msd' '_ff' num2str(ffoTemp) '_be' num2str(bind) '_hop' ...
      num2str(bBar) '_'  num2str(Id) '.fig' ];
    savefig(gcf,savestr)
  end
  
   if plotlog
    logMSDplot( timeAve(1:end), msdAve(1:end), ffoTemp, bind, bBar, Id )
    savestr = [ 'log' '_ff' num2str(ffoTemp) '_be' num2str(bind) '_hop' ...
      num2str(bBar) '_'  num2str(Id) '.fig'];
    savefig(gcf,savestr)
%     logMSDplot( timeAve(1:end), msdAve(1:end), ffoTemp, bind, bBar, Id, errorAve/100 )
%     savestr = [ 'log' '_ff' num2str(ffoTemp) '_be' num2str(bind) '_hop' ...
%       num2str(bBar) '_'  num2str(Id) '.fig'];
%     savefig(gcf,savestr)
  end
end
%%
% figure()
% nP = length(timeAve);
% inds = 1 : nP - 200;
% % inds = 1:nP-100;
% errorbar( timeAve(inds), msdAve(inds), errorAve(inds) )
%%
% logMSDplot( timeAve(1:end-100), msdAve(1:end-100), errorAve(1:end-100) )


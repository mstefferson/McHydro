function logMsdPlot(dtimeAveF, msdAveF, bindenM, ffoM, ParamList1, saveFlag)
 
  figure()
  % All points r^2 vs t
  Ha = subplot(1,2,1);
  loglog(dtimeAveF, msdAveF)
  axis square
  
  titstr = ['r^2 vs t' ParamList1];
  xlabel('t'); ylabel('r^2'); title( titstr );
  % Set-up axis
  base10Xstr = 0;  base10Xend = ceil( log10( dtimeAveF(end) ) );
  base10Ystr = 0;  base10Yend = ceil( log10( msdAveF(end) ) );
  
  if base10Yend == 0; base10Ystr = -1; end;
  
  Ha.XTick = 10 .^( base10Xstr:base10Xend) ;
  Ha.YTick = 10 .^( base10Ystr:base10Yend) ;
  Ha.XLim =  10 .^ [base10Xstr base10Xend];
  Ha.YLim =  10 .^ [base10Ystr base10Yend];
  Ha.YGrid = 'on'; Ha.XGrid = 'on';
  
  % All points r^2 / t vs t
  Ha = subplot(1,2,2);
  loglog(dtimeAveF, msdAveF ./ dtimeAveF)
  axis square
  titstr = ['r^2 / t vs t ' ParamList1];
  xlabel('t'); ylabel('r^2 / t'); title( titstr );
  
  base10Xstr = 0;  base10Xend = ceil( log10( dtimeAveF(end) ) );
  base10Ystr = floor( log10( msdAveF(end)./ dtimeAveF(end) ) ); 
  base10Yend = ceil( log10( msdAveF(end)./ dtimeAveF(end) ) );
  
  Ha.XTick = 10 .^( base10Xstr:base10Xend) ;
  Ha.YTick = 10 .^( base10Ystr:base10Yend) ;
  Ha.XLim =  10 .^ [base10Xstr base10Xend];
  Ha.YLim =  10 .^ [base10Ystr base10Yend];
  Ha.YGrid = 'on'; Ha.XGrid = 'on';
 
  % Save it
  if saveFlag
    savestr = sprintf('logbe%.1foff%.1f.fig', bindenM, ffoM);
    savefig( savestr );
  end
 
end

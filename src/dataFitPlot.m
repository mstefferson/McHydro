function dataFitPlot(dtimeAveF, coeffs, msd, bindenM, ffoM, ParamList1, saveFlag)

  % Get some parameters for axis
  tMax = dtimeAveF(end);
  
  % Parameters
  TitleStr1 = [ 'msd' ParamList1 ];
  
  %% Fig 1: scatter plot with fit and average vals with fit
  figure()
  subplot(1,2,1)
  plot(dtimeAveF, coeffs(1) + coeffs(2) .* dtimeAveF ...
    + coeffs(3) .* log(dtimeAveF), '--' );
  hold on
  plot(dtimeAveF, msd,'o')
  hold off
  axis square
  ax = gca;
  ax.XLim = [0 tMax];
  ax.YLim = [0 tMax];
  xlabel('time'); ylabel('r^2')
  title( TitleStr1 )
  legend('Fit','Data','location','best')
  
  subplot(1,2,2)
  plot(dtimeAveF, coeffs(1) + coeffs(2) .* dtimeAveF ...
    + coeffs(3) .* log(dtimeAveF), '--' );
  hold on
  plot(dtimeAveF, msd,'o')
  hold off
  axis square
  ax = gca;
  ax.XLim = [0 tMax];
  xlabel('time'); ylabel('r^2')
  title( TitleStr1 )
  legend('Fit','Data','location','best')  

  if saveFlag
    savestr = sprintf('fitbe%.1foff%.1f.fig', bindenM, ffoM);
    savefig( savestr );
  end


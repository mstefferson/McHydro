function logMSDplot( t, r2, ff, be, hop, Id, err )

%figure()
if nargin == 6
  plot( log10( t ), log10( r2 ./ t ) )
elseif nargin == 7
  errorbar( log10( t ), log10( r2 ./ t ), err ./ ( r2 ) )
end

ttlstr = ['ff = ' num2str(ff) ' be = ' num2str(be) ' hop = ' num2str(hop) ];
title(ttlstr)
ylabel( ' log_{10} ( \langle r^2  \rangle / t ) ' );
xlabel( ' log_{10} (t) ' );
ax = gca;
% if Id == 1
%   ax.YLim = [ min( log10( r2 ./ t ) )  max( log10( r2 ./ t ) )  ];
% else
%   ax.YLim = [ -1  0.1  ];
% end

end

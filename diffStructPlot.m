%% Load your stuff
function diffStructPlot( diffS )

ylab = 'D';
xlab = '\nu';
titstr = 'No motion while bound';

numD = length(diffS);

% legend 
infFlag = 0;
legcell = cell( 1, numD ) ;
legvar = '\Delta G';

figure()
hold on
for ii = 1:numD
  if ~isinf( diffS(ii).pConst )
    errorbar( diffS(ii).pVary, diffS(ii).D, diffS(ii).sig );
    legcell{ii} = [legvar ' = ' num2str( diffS(ii).pConst ) ];
  else
    infFlag = 1;
  end
end

if infFlag
  legcell = legcell(1:end-1);
end

legend( legcell, 'location', 'best' );


% labels
xlabel(xlab);
ylabel(ylab);
title(titstr);
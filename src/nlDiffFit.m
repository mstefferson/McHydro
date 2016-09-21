% Use matlab's fit function to find coefficients
% for non-linear diffusion equation r^2 = a + b t + c ln(t)
% Matlab's "confidence ranges" are mysterious and do not
% match my linear fit uncertainties

function [coeff, coeffsig] = nlDiffFit( t, r2, sig, guess )

% If no vector sig given, set all the weights equal
if length(sig) == 1
  sig = ones(length(t), 1);
end
% keyboard
% Set up fit object
nlft = fittype('a + b*t + c*log(t)',...
    'dependent',{'r2'},'independent',{'t'},...
    'coefficients',{'a','b','c'});
% nlft = fittype({'1','x','log(x)'});
if nargin == 4
  fitopts = fitoptions('Method','NonlinearLeastSquares', ...
    'Weights', 1 ./ sig .^ 2, 'StartPoint', guess );
else
  fitopts = fitoptions('Method','NonlinearLeastSquares',...
    'Weights', 1 ./ sig .^ 2);
end

fitobjw = fit( t, r2, nlft, fitopts );

% Assign coefficients
coeff(1) = fitobjw.a; coeff(2) = fitobjw.b; coeff(3) = fitobjw.c;

% Confidence intervals
ci = confint( fitobjw, 0.67 );
coeffsig = ci(2,:) - mean(ci,1);

end



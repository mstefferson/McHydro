% Use matlab's fit function to find coefficients
% for non-linear diffusion equation r^2 = a + b t + c ln(t)
% Matlab's "confidence ranges" are mysterious and do not
% match my linear fit uncertainties

function [coeff, coeffsig] = nlDiffFit( t, r2, sig )

% If no sig given, set all the weights equal
if nargin == 2
  sig = ones(length(t), 1);
end


  % Set up fit object
  nlft = fittype({'1','x','log(x)'});
  fitopt = fitoptions('Weights', 1 ./ sig .^ 2 );
  fitobjw = fit( t, r2, nlft, fitopt );

  % Assign coefficients
  coeff(1) = fitobjw.a; coeff(2) = fitobjw.b; coeff(3) = fitobjw.c;

  % Confidence intervals
  ci = confint( fitobjw, 0.67 );
  coeffsig = ci(2,:) - mean(ci,1);

end



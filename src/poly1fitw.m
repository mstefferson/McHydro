% x: dependent var
% y: indepent var
% yerr: uncertainty in y (Standard errror)
% alpha: confidence interval

function [p1, p1err, p2, p2err] =  poly1fitw( x, y, yerr, alpha )

% y =  p1 * x + p2
  % Set up fit type object
  ft = fittype( 'poly1' );
if nargin == 3
  alpha = 0.68;
  w = 1 ./ yerr .^ 2;
  fo = fitoptions( 'weights', w);
  [fitobject] = fit( x, y, ft, fo );
else
  [fitobject] = fit( x, y, ft );
end

  ci = confint( fitobject, alpha);

  p1 = ( ci(1,1) + ci(2,1) ) / 2;
  p1err = ci(2,1) - p1;

  p2 = ( ci(1,2) + ci(2,2) ) / 2;
  p2err = ci(2,2) - p2;

end

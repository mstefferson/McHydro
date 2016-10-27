% fitDiffSimThryIntrp( dinf, nuInf, dSim, sigSim, nuSim, beSim);
%
% Description: fits the binding diffusion simulation to a theory curve for D vs
% nu. The theory curve using linear interpolation of simulation diffusion 
% curve for the a no binding model with a effective filling fraction of
% obstacles based on binding. 
 
function fitDiffSimThryIntrp( dinf, nuInf, dSim, sigSim, nuSim, beSim, pFlag)

% Binding energy
G = beSim;
% Filling fraction of obstacles for interpn
nu = linspace(0,1,100); 
% Probabilities to block a hop and average tracers on obst/empty
Pbe2o = 1 - min( exp(-G) ,1 ); % Probability a hop empty to obst will be blocked
Pbo2e = 1 - min( exp(G) ,1);   % Probability a hop obst to empty will be blocked
ffte = (1 - c) ./ ( (1-c) + c .* exp(-G) );
ffto = ( c * exp(-G) ) ./ ( (1-c) + c .* exp(-G) );
% Use interpolation to build Diff for being on empty and obstacle site
% Make sure D for no binding spans to nu = 1
if max(nuInf) < 1
  dInf = [dInf 0];
  nuInf = [nuInf 1];
end
% Build diffusiion for on/off obstacle and average
Demp = interpn( nuInf, dInf, Pbe2o .* c );
Dobs = interpn( nuInf, dInf, Pbo2e .* (1-c) );
Dinterp = ffte .* Demp + ffto .* Dobs;
% bundle it for an output
output.dSim = dSim;
output.sigSim = sigSim;
output.nuSim = nuSim;
output.dFit = Dinterp;
output.nuFit = nu;

% Plot it
if pFlag
  figure()
  errorbar( nuSim, dSim, sigSim )
  hold on
  plot( nu, Dinterp )
  Ax = gca;
  Ax.YLim = [0 1.2];
  Ax.XLim = [0 1];
  ylab = 'D';
  xlab = '\nu';
  titstr = [ 'Theory vs Sim \Delta G = ' num2str(beSim) ];
  title(titstr)
  legend('sim','theory', 'location', 'best')
end


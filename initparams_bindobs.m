%initialize parameters here and save it to a Params.mat

%key parameters and constants
slide_barr_height=0;    %barrier height to sliding, in kT
bind_energy_vec = [1];
ffrac_obst_vec= [ 0.1 ];         %filling fraction of obstacles
ffrac_tracer=0.1;       %filling fraction of tracers

%declare a params struct for organization as well
params.slide_barr_height = slide_barr_height;
params.bind_energy_vec = bind_energy_vec;
params.ffrac_obst_vec = ffrac_obst_vec;
params.ffrac_tracer = ffrac_tracer;

%grid stuff
const.n_trials      = 1;
const.n_gridpoints  = 100;    % number of grid points, same in x and y
const.ntimesteps    = 1e2;    % number of timesteps NOte 1e5 gives errors on my laptop.
const.trec          = 10;      % time elapsed before recording
const.twait         = 1;      % time waited before recording
const.TrRecFlag     = 1;     % Flag to record tracers or not
const.ObsRecFlag    = 0;     % Flag to record obstacles or not

%trial master
trialmaster.tind       = 3;
trialmaster.runstrtind = 6;
trialmaster.nt         = const.n_trials;

%other constants and model options
const.size_obst=1;      %obstacle linear dimension, MUST BE odd integer
const.size_tracer=1;     %tracer linear dimension, MUST BE odd integer
modelopt.obst_excl=1;       %1 if obstacles sterically exclude each other, 0 if not
modelopt.tracer_excl=0;     %MUST BE 0 so tracers don't interact (ghosts)
modelopt.obst_trace_excl=0;  %1 if obstacles and tracers mutually exclude
modelopt.dimension=2; %system dimension, currently must be 2

const.nequil=0;           %number of timesteps for initial equilibration

%model stuff
modelopt.animate=0;          %1 to show animation, 0 for no animation
modelopt.tpause=0.0;         %pause time in animation, 0.1 s is fast, 1 s is slow
modelopt.movie=0;           %1 to record movie


% Fix time stuff and add some calculated things
if const.twait < 1; const.twait = 1; end;
const.ntimesteps = floor( const.ntimesteps / const.trec ) * const.trec; % fix ntimesteps
const.Nwait = ceil( const.twait / const.trec) - 1; % Number of recorded points we skip due to waiting
const.twait = (const.Nwait + 1) * const.trec; % fix wait time. Add 1 to start recording at twait
const.Nrec = const.ntimesteps / const.trec - const.Nwait; % Number of recorded points

save('Params')

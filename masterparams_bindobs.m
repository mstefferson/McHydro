% Initialize parameters here and save it to a Params.mat
% This is the tracked copy of the params. this should not be
% edited unless you are adding a new parameter. The parameter
% file that is called, initparams_bindobs, should be a copy of this.
% initparams_bindobs should not be tracked.

%key parameters and constants
slide_barr_height=0;    %barrier height to sliding, in kT
bind_energy_vec = [0];
ffrac_obst_vec= [ 0.1 ];         %filling fraction of obstacles
ffrac_tracer=0.1;       %filling fraction of tracers

%declare a params struct for organization as well
params.slide_barr_height = slide_barr_height;
params.bind_energy_vec = bind_energy_vec;
params.ffrac_obst_vec = ffrac_obst_vec;
params.ffrac_tracer = ffrac_tracer;

%grid stuff
const.n_trials      = 4;
const.n_gridpoints  = 100;    % number of grid points, same in x and y
const.ntimesteps    = 1e5;   % number of timesteps Note 1e5 gives errors on my laptop.
const.rec_interval  = 1e2;    % time elapsed before recording
const.rec_chunk     = 1e4;   % time elapsed before writing to file
const.twait         = 1;    % time waited before recording
const.TrRecFlag     = 1;     % Flag to record tracers or not
const.ObsRecFlag    = 0;     % Flag to record obstacles or not
const.size_obst     = 1;      %obstacle linear dimension, MUST BE odd integer
const.size_tracer   = 1;     %tracer linear dimension, MUST BE odd integer

%msd stuff
const.calcQuad      = 0;         % Flag for calculating quad
const.maxpts_msd    = 100;         % Flag for calculating quad

%trial master
trialmaster.tind       = 1;
trialmaster.runstrtind = 1;
trialmaster.nt         = const.n_trials;

%model stuff
modelopt.animate=0;          %1 to show animation, 0 for no animation
modelopt.tpause=0.0;         %pause time in animation, 0.1 s is fast, 1 s is slow
modelopt.movie=0;           %1 to record movie
modelopt.obst_excl=1;       %1 if obstacles sterically exclude each other, 0 if not
modelopt.tracer_excl=0;     %MUST BE 0 so tracers don't interact (ghosts)
modelopt.obst_trace_excl=0;  %1 if obstacles and tracers mutually exclude
modelopt.dimension=2;    %system dimension, currently must be 2

% Fix time stuff and add some calculated things
if const.twait < 1; const.twait = 1; end;
if const.rec_chunk > const.ntimesteps; const.rec_chunk = const.ntimesteps; end;
if const.rec_interval > const.rec_chunk; const.rec_interval = const.rec_chunk; end;

const.rec_chunk  = round( const.rec_chunk / const.rec_interval ) * const.rec_interval; % fix rec_chunk
const.NrecChunk  = const.rec_chunk / const.rec_interval; % Number of recorded points / chunk
const.ntimesteps = floor( const.ntimesteps / const.rec_chunk ) * const.rec_chunk; % fix ntimesteps
const.Nreclost   = ceil( const.twait / const.rec_interval) - 1; % Number of recorded points we skip due to waiting
const.Nchunklost = ceil( const.twait / const.rec_chunk) - 1; % Number of chunks we skip due to waiting
const.twait      = (const.Nreclost + 1) * const.rec_interval; % fix wait time. Add 1 to start recording at twait
const.NrecTot    = const.ntimesteps / const.rec_interval - const.Nreclost; % Number of recorded points
const.NchunkTot  = const.ntimesteps / const.rec_chunk - const.Nchunklost; % Number of recorded points

% Number of particles on the grid
const.num_tracer    = ffrac_tracer .* const.n_gridpoints ^ 2;


save('Params')% Fix time stuff and add some calculated things

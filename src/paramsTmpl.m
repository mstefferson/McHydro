% Initialize parameters here and save it to a Params.mat
% This is the tracked copy of the params. this should not be
% edited unless you are adding a new parameter. The parameter
% file that is called, initparams_bindobs, should be a copy of this.
% initparams_bindobs should not be tracked.

%grid stuff
const.dim = 2; % system dimension
const.n_gridpoints = 100; % number of grid points, same in x and y

%trial master
trialmaster.parforFlag = 0; % flag to use parfor or not
trialmaster.tind = 1; % trial indicator
trialmaster.runstrtind = 1; % run indicator
trialmaster.nt = 1; % number of trials
trialmaster.seedShift = 1; % seed shifter resolve cluster issues
trialmaster.verbose = 0; % print things

% obstacles cell of cells:
% {'rand', bndDiff, be, ffo, so, obstExclude, edgesPlace};
% {'wall', bndDiff, be, thickness, gapWidth, dim, loc};
% {'teleport', dim, loc, trackTeleNumFlag};
params.obst = { {'rand', 0, 1, 0.1, 1, 1, 0} };
params.num_tracer = 100; %filling fraction of tracers
params.tr_unbnd_diff = 1; % unbound diffusion

% time
const.ntimesteps = round( 10 ^ ( 3.0 ) ); % number of timesteps Note 1e5 gives errors on my laptop.
const.rec_interval = round( 10 ^ ( 1.0 ) ); % time elapsed before recording
const.write_interval = round( 10 ^ ( 2.0 ) ); % time elapsed before writing to file
const.twait = 0; % time waited before recording
const.trPosRecModFlag = 0; % Flag to record tracers or not. modulated
const.trPosRecNoModFlag = 1; % Flag to record tracer state. not modulated
const.trStateRecFlag = 0; % Flag to record tracer state
const.trackOcc = 1; % Flag to track occupancy
const.obsPosRecModFlag = 0; % Flag to record tracers or not. modulated
const.obsPosRecNoModFlag = 0; % Flag to record tracer state. not modulated
const.size_tracer = 1; %tracer linear dimension, MUST BE odd integer

%msd stuff
const.calcQuad = 0; % Flag for calculating quad
const.maxpts_msd = 100; % Flag for calculating quad
const.useStart = 1; % Using t=1 to start windows instead of t=end

% flux count { on/off, dim (1/2/3) , value }
const.fluxCountInpt = { 0, 1,  const.n_gridpoints };

%model stuff
modelopt.tracer_excl=0;     %MUST BE 0 so tracers don't interact (ghosts)
modelopt.place_tracers_obst=1; % If 0, don't place any tracers on obstacles
modelopt.animate=0;          %1 to show animation, 0 for no animation
modelopt.tpause=0.0;         %pause time in animation, 0.1 s is fast, 1 s is slow
modelopt.movie=0;           %1 to record movie
modelopt.movie_name='movieFile';  %file name
modelopt.movie_framerate = 1; % number of step to record
modelopt.movie_steps = 100; % number of step to record

% save something to const and modelopt 
params.num_obst_types = length( params.obst );
modelopt.dimension=const.dim; %system dimension
const.place_tracers_obst = modelopt.place_tracers_obst; %system dimension

% Fix time stuff and add some calculated things
if const.write_interval > const.ntimesteps; const.write_interval = const.ntimesteps; end
if const.rec_interval > const.write_interval; const.rec_interval = const.write_interval; end
const.twait = round( const.twait / const.rec_interval ) .* const.rec_interval;
const.write_interval  = round( const.write_interval / const.rec_interval ) * const.rec_interval; % fix write_interval
const.ntimesteps = round( const.ntimesteps / const.write_interval ) * const.write_interval; % fix ntimesteps
const.NrecLost   = const.twait / const.rec_interval; % Number of recorded points we skip due to waiting
const.NrecChunk  = const.write_interval / const.rec_interval; % Number of recorded points / chunk
const.NrecTot    = const.ntimesteps / const.rec_interval - const.NrecLost + 1; % Number of recorded points

% Store verbose
const.verbose = trialmaster.verbose;
% Save it
save('Params', 'const','params','trialmaster','modelopt');

function [msd,dtime]=computeMSD(x, maxpts_msd, quadFlag)
%takes array x (mxdxn array), t (1xn),
% calculates mean-squared and quartic displacements vs dt
% m is number of particles
% d is dimension, will work on any dimension vector
% n is number time points
%  msd is nx5 mean squared displacement array vs dt from 0 to n-1
%  msd(:,1)=msd
%  msd(:,2)=std(squared displacement)
%  msd(:,3)=n intervals(dt)
%  msd(:,4)=mean quartic displacement
%  msd(:,5)=std(quartic displacement)

number_timepnts = size(x,3);
number_delta_t  = number_timepnts - 1;
dtime= ( 1 : number_delta_t)' ;

if quadFlag
  msd=zeros(number_delta_t,5); %Store [mean, std, n]
else
  msd=zeros(number_delta_t,3); %Store [mean, std, n]
end

parfor dt = 1:number_delta_t
  % Make sure we have no otherlapping time windows
  NwMax = ceil( number_timepnts / dt ) - 1;
  nStartPoss = 1:dt:NwMax*dt;
  randInd = randperm( NwMax, min(NwMax,maxpts_msd) );
  index_start = nStartPoss( randInd );
  index_end = index_start + dt;
  delta_coords = x(:,:, index_end) - x(:,:,index_start);
  % calculate displacement ^ 2
  squared_dis = sum(delta_coords.^2,2); % dx^2+dy^2+...
  % calculate displacement ^ 4 if flag
  if quadFlag
    quartic_dis = sum(delta_coords.^4,2); % dx^4+dy^4+..
    msd(dt,:) = [mean(squared_dis(:)); ... % average
      std(squared_dis(:)); ...; % std
      length(squared_dis(:)); ... % n (how many points used to compute mean)
      mean(quartic_dis(:)); ... %average
      std(quartic_dis(:))]'; %std
  else
    msd(dt,:) = [mean(squared_dis(:)); ... % average
      std(squared_dis(:)); ...; % std
      length(squared_dis(:)) ]'
  end
end


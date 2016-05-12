% Function: fileclist.m
%
% Michael Stefferson
% 12-May-2016
%
% Description: Returns a cell list of all the file names (strings) in a directory

function [files] = filelist(DirStr,fileExt)

if nargin == 0
  DirStr = pwd;
  fileExt = '';
end

if nargin == 1
  fileExt = '';
end

% Get length of file extension for parsing purposes
extLength = length(fileExt);

% Grab everything in
files = dir( DirStr );
TotItems = length( files );

% Store things we want in a temp then extract what we want;
fileTemp  = cell( TotItems , 1 );
counter = 0;

% Note, converting a sturct field to a cell
for i = 1:TotItems
  if files(i).isdir == 0

    if extLength == 0
      counter  = counter + 1;
      fileTemp{counter} = files(i).name;
    elseif strcmp( files(i).name( end - extLength + 1:end), fileExt )
      counter  = counter + 1;
      fileTemp{counter} = files(i).name; 
    end
    
  end
end

files  = cell( counter , 1 );
for i = 1:counter
  files(i) = fileTemp(i);
end

end

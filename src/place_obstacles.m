%place obstacles on seperate lattice sites

function obj = place_obstacles( n_obj, ng )

% place obstacles. No overlap
obj.allpts = randperm( ng^2, n_obj )';
% convert it to x,y indices
[obj.center(:,1), obj.center(:,2) ] = ind2sub( [ng ng], obj.allpts );

end

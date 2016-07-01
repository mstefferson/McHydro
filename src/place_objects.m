function obj=place_objects(n_obj,len_obj,ngridpoints,modelopt,exclude_flag,existing_fig,obj_color,...
    obj_curv,placed_obj);
%see if structure of previously placed objects was passed
if nargin > 8 & any(placed_obj.allpts)
%     display('place_objects: previously placed objects found');
    use_placed=1;
else
    use_placed=0;
end

%model options
dim=modelopt.dimension;
animate=modelopt.animate;
tpause=modelopt.tpause;

%colors for plotting
grey=[0.5 0.5 0.5];
red=[1 0 0];
%pause time

%define unit vectors from center to all points on object
[x,y]=ind2sub([len_obj,len_obj],1:len_obj^dim);
obj.lattice=[x'-(len_obj+1)/2 y'-(len_obj+1)/2];

%make list of all possible lattice sites in random order
sites=[1:ngridpoints^dim];
if (use_placed && modelopt.obst_trace_excl)
    sites(placed_obj.allpts)=[]; %remove already occupied sites from list
end;
% % sample sites without replacement
% open_sites=sites(randperm(length(sites)));
% sample sites with replacment
open_sites=sites(randi(length(sites),1,10*length(sites)));
% initial guesses for random object positions
[x,y] = ind2sub([ngridpoints,ngridpoints],open_sites(1:n_obj));
obj.center=[x' y']; %center x,y positions of each object

%define box for plotting
if animate && ~existing_fig
    ax=gca;axis square;ax.XGrid='on';ax.YGrid='on';
    ax.XLim=[0.5 ngridpoints+0.5];ax.YLim=[0.5 ngridpoints+0.5];
    ax.XTick=[0:ceil(ngridpoints/20):ngridpoints];
    ax.YTick=ax.XTick;
    ax.XLabel.String='x position';ax.YLabel.String='y position';
    ax.FontSize=14; 
end;

%list of lattice index positions for all points inside objects
obj.allpts = zeros(1,len_obj^dim); 
%counter for objects that have been placed
obj_counter = n_obj+1;%+n.tracer
for i=1:n_obj %loop until get desired number of objects
    %create all points in object lattice, enforce periodic boundaries
    x_temp = mod(obj.center(i,1)+obj.lattice(:,1)'-1,ngridpoints)+1;
    y_temp = mod(obj.center(i,2)+obj.lattice(:,2)'-1,ngridpoints)+1;
    %convert to index positions
    try
      index_temp=sub2ind([ngridpoints ngridpoints], x_temp, y_temp);
    catch
      keyboard
    end
    %draw rectangle for current object, check periodic boundaries
    if animate
        obj=update_rectangle(obj,i,len_obj,ngridpoints,grey,obj_curv);
        pause(tpause);
    end
    
    %if current object overlaps with any already placed, try again
    if exclude_flag
        if (use_placed && modelopt.obst_trace_excl) %include already placed objects in the list
            occupied_sites=[placed_obj.allpts(:); obj.allpts(:)];
        else %include objects placed in this function only
            occupied_sites=obj.allpts;
        end
    else
        if (use_placed && modelopt.obst_trace_excl) %include already placed objects in the list
            occupied_sites=[placed_obj.allpts(:)];
        else %include objects placed in this function only
            occupied_sites=[];
        end
    end
    while any(ismember(index_temp,occupied_sites)) %overlap check
%         %error exit if all lattice sites have been checked already
%         if obj_counter>ngridpoints^dim
%             error('place_objects: unable to place all objects without overlaps');
%         end;
        %draw the object red
        if animate
            obj=update_rectangle(obj,i,len_obj,ngridpoints,red,obj_curv);
            pause(tpause);
        end
        %find center of new particle, store
        [x,y] = ind2sub([ngridpoints,ngridpoints],open_sites(obj_counter));
        obj.center(i,:)=[x y];
        obj_counter=obj_counter+1; %increment the counter
        %create all points in object lattice & enforce periodic boundaries
        x_temp = mod(x+obj.lattice(:,1)'-1,ngridpoints)+1;
        y_temp = mod(y+obj.lattice(:,2)'-1,ngridpoints)+1;
        %convert to index positions
        index_temp=sub2ind([ngridpoints ngridpoints], x_temp, y_temp);
        %draw rectangle for current object, check periodic boundaries
        if animate
            obj=update_rectangle(obj,i,len_obj,ngridpoints,grey,obj_curv);
            pause(tpause);
        end
        %print if needed
%         [obj_counter i x y]
    end
    %record locations of good objects
    obj.allpts(i,:) = index_temp;
    if use_placed
        obj.state(i)=sum(ismember(obj.allpts(i,:), placed_obj.allpts(:)));
    end
    %change color to input color
    if animate
        obj=update_rectangle(obj,i,len_obj,ngridpoints,obj_color,obj_curv);
        pause(tpause);
    end
end
end

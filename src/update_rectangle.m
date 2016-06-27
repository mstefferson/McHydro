function obj=update_rectangle(obj,i,len_obj,ngridpoints,color,curvature)

% i
% %turn off the main rectangle if it is present
if isfield(obj,'rect') %rectangle field is present
%     [i color]
    if length(obj.rect)>=i && ~isempty(fieldnames(get(obj.rect(i)))) %h rect is present
        obj.rect(i).Visible='off';
    end
end
%turn off the side rectangles if they are present
if isfield(obj,'rect_hor') %horizontal rectangles are present
    if length(obj.rect_hor)>=i && ~isempty(fieldnames(get(obj.rect_hor(i)))) %h rect is present
        %make the rectangle invisible
        obj.rect_hor(i).Visible='off';
    end
end
if isfield(obj,'rect_ver'); %vertical rectangles are present
    if length(obj.rect_ver)>=i && ~isempty(fieldnames(get(obj.rect_ver(i)))) %v rect is present
        %make the rectangle invisible
        obj.rect_ver(i).Visible='off';
    end
end

%draw the main rectangle
obj.rect(i)=rectangle('Position',[obj.center(i,1)-(len_obj)/2,obj.center(i,2)-...
    (len_obj)/2,len_obj,len_obj],'Curvature',[curvature,curvature],'FaceColor',color);

%draw the side rectangles if needed
if obj.center(i,1)+len_obj/2>ngridpoints %overlaps right edge
    obj.rect_hor(i)=rectangle('Position',[obj.center(i,1)-ngridpoints-...
        (len_obj)/2,obj.center(i,2)-...
        (len_obj)/2,len_obj,len_obj],'Curvature',[curvature,curvature],'FaceColor',color);
elseif obj.center(i,1)-len_obj/2<1; %left edge
    obj.rect_hor(i)=rectangle('Position',[obj.center(i,1)+ngridpoints-(len_obj)/2,obj.center(i,2)-...
        (len_obj)/2,len_obj,len_obj],'Curvature',[curvature,curvature],'FaceColor',color);
end
if obj.center(i,2)+len_obj/2>ngridpoints %top edge
    obj.rect_ver(i)=rectangle('Position',[obj.center(i,1)-...
        (len_obj)/2,obj.center(i,2)-ngridpoints-(len_obj)/2,...
        len_obj,len_obj],'Curvature',[curvature,curvature],'FaceColor',color);
elseif obj.center(i,2)-len_obj/2<1; %bottom edge
    obj.rect_ver(i)=rectangle('Position',[obj.center(i,1)-...
        (len_obj)/2,obj.center(i,2)+ngridpoints-(len_obj)/2,...
        len_obj,len_obj],'Curvature',[curvature,curvature],'FaceColor',color);
end
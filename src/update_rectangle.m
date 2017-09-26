function [drawRect] = update_rectangle(centers,drawRect, i,len_obj,ngridpoints,color,curvature);

% %turn off the main rectangle if it is present
if isfield(drawRect,'rect') %rectangle field is present
%     [i color]
    if length(drawRect.rect)>=i && ~isempty(fieldnames(get(drawRect.rect(i)))) %h rect is present
        drawRect.rect(i).Visible='off';
    end
end
%turn off the side rectangles if they are present
if isfield(drawRect,'rect_hor') %horizontal rectangles are present
    if length(drawRect.rect_hor)>=i && ~isempty(fieldnames(get(drawRect.rect_hor(i)))) %h rect is present
        %make the rectangle invisible
        drawRect.rect_hor(i).Visible='off';
    end
end
if isfield(drawRect,'rect_ver') %vertical rectangles are present
    if length(drawRect.rect_ver)>=i && ~isempty(fieldnames(get(drawRect.rect_ver(i)))) %v rect is present
        %make the rectangle invisible
        drawRect.rect_ver(i).Visible='off';
    end
end

%draw the main rectangle
drawRect.rect(i)=rectangle('Position',[centers(i,1)-(len_obj)/2,centers(i,2)-...
    (len_obj)/2,len_obj,len_obj],'Curvature',[curvature,curvature],'FaceColor',color);

%draw the side rectangles if needed
if centers(i,1)+len_obj/2>ngridpoints %overlaps right edge
    drawRect.rect_hor(i)=rectangle('Position',[centers(i,1)-ngridpoints-...
        (len_obj)/2,centers(i,2)-...
        (len_obj)/2,len_obj,len_obj],'Curvature',[curvature,curvature],'FaceColor',color);
elseif centers(i,1)-len_obj/2<1 %left edge
    drawRect.rect_hor(i)=rectangle('Position',[centers(i,1)+ngridpoints-(len_obj)/2,centers(i,2)-...
        (len_obj)/2,len_obj,len_obj],'Curvature',[curvature,curvature],'FaceColor',color);
end
if centers(i,2)+len_obj/2>ngridpoints %top edge
    drawRect.rect_ver(i)=rectangle('Position',[centers(i,1)-...
        (len_obj)/2,centers(i,2)-ngridpoints-(len_obj)/2,...
        len_obj,len_obj],'Curvature',[curvature,curvature],'FaceColor',color);
elseif centers(i,2)-len_obj/2<1 %bottom edge
    drawRect.rect_ver(i)=rectangle('Position',[centers(i,1)-...
        (len_obj)/2,centers(i,2)+ngridpoints-(len_obj)/2,...
        len_obj,len_obj],'Curvature',[curvature,curvature],'FaceColor',color);
end

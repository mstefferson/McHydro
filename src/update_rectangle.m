function [drawRec] = update_rectangle(centers,drawRec, i,len_obj,ngridpoints,color,curvature);

% %turn off the main rectangle if it is present
if isfield(drawRec,'rect') %rectangle field is present
%     [i color]
    if length(drawRec.rect)>=i && ~isempty(fieldnames(get(drawRec.rect(i)))) %h rect is present
        drawRec.rect(i).Visible='off';
    end
end
%turn off the side rectangles if they are present
if isfield(drawRec,'rect_hor') %horizontal rectangles are present
    if length(drawRec.rect_hor)>=i && ~isempty(fieldnames(get(drawRec.rect_hor(i)))) %h rect is present
        %make the rectangle invisible
        drawRec.rect_hor(i).Visible='off';
    end
end
if isfield(drawRec,'rect_ver'); %vertical rectangles are present
    if length(drawRec.rect_ver)>=i && ~isempty(fieldnames(get(drawRec.rect_ver(i)))) %v rect is present
        %make the rectangle invisible
        drawRec.rect_ver(i).Visible='off';
    end
end

%draw the main rectangle
drawRect.rect(i)=rectangle('Position',[centers(i,1)-(len_obj)/2,centers(i,2)-...
    (len_obj)/2,len_obj,len_obj],'Curvature',[curvature,curvature],'FaceColor',color);

%draw the side rectangles if needed
if centers(i,1)+len_obj/2>ngridpoints %overlaps right edge
    drawRec.rect_hor(i)=rectangle('Position',[centers(i,1)-ngridpoints-...
        (len_obj)/2,centers(i,2)-...
        (len_obj)/2,len_obj,len_obj],'Curvature',[curvature,curvature],'FaceColor',color);
elseif centers(i,1)-len_obj/2<1; %left edge
    drawRec.rect_hor(i)=rectangle('Position',[centers(i,1)+ngridpoints-(len_obj)/2,centers(i,2)-...
        (len_obj)/2,len_obj,len_obj],'Curvature',[curvature,curvature],'FaceColor',color);
end
if centers(i,2)+len_obj/2>ngridpoints %top edge
    drawRec.rect_ver(i)=rectangle('Position',[centers(i,1)-...
        (len_obj)/2,centers(i,2)-ngridpoints-(len_obj)/2,...
        len_obj,len_obj],'Curvature',[curvature,curvature],'FaceColor',color);
elseif centers(i,2)-len_obj/2<1; %bottom edge
    drawRec.rect_ver(i)=rectangle('Position',[centers(i,1)-...
        (len_obj)/2,centers(i,2)+ngridpoints-(len_obj)/2,...
        len_obj,len_obj],'Curvature',[curvature,curvature],'FaceColor',color);
end

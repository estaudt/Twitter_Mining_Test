function overlap = boxes_overlap( rectA, rectB )
%BOXES_OVERLAP 
%   Determines the percentage overlap of two boxes (row vectors) with
%   respect to the smaller of the two input boxes.
%
%   For reference, here are what each position in the boxes mean
%
%        xmin = rectX(1);
%        ymin = rectX(2);
%        xmax = rectX(3);
%        ymax = rectX(4);
%

% Check to see if the boxes do not overlap
if (rectA(3) < rectB(1))
    overlap = 0;
    return; % rectA is left of rectB
end
if (rectA(1) > rectB(3))
    overlap = 0;
    return; % rectA is right of rectB
end
if (rectA(4) < rectB(2))
    overlap = 0;
    return; % rectA is above rectB
end
if (rectA(2) > rectB(4))
    overlap = 0;
    return; % rectA is below rectB
end

% If we've gotten this far, the boxes must overlap.
% determine the limits of overlap.
rect = rectA;
if rectA(1) < rectB(1)
    rect(1) = rectB(1);
end
if rectA(2) < rectB(2)
    rect(2) = rectB(2);
end
if rectA(3) > rectB(3)
    rect(3) = rectB(3);
end
if rectA(4) > rectB(4)
    rect(4) = rectB(4);
end

areaA = (rectA(3)-rectA(1))*(rectA(4)-rectA(2));
areaB = (rectB(3)-rectB(1))*(rectB(4)-rectB(2));
area = (rect(3)-rect(1))*(rect(4)-rect(2));

overlap = area/areaA;
if area/areaB > overlap
    overlap = area/areaB;
end
return ; % boxes overlap

end


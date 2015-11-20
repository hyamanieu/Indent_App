function [ NewX,NewY ] = RotMat( X,Y )
%[ NewX,NewY ] = RotMat( X,Y ) rotate a coordinate matrix to work in its
%basis.
%   Rotates the coordinates in the grid defined by (X,Y) in order to work
%   in the basis defined by the grid, e.g. nodes and rows are aligned.
%
%   Released into the public domain
if ~or(length(nonzeros(X==max(X)))>1,length(nonzeros(Y==max(Y)))>1)
    Theta =  acos((max(X)-X(Y==0))/sqrt((max(X)-X(Y==0))^2+Y(X==max(X))^2));%rotationary angle
    Mrot=[cos(-Theta), -sin(-Theta);sin(-Theta),cos(-Theta)];%Rot matrix
    T = bsxfun(@(x,y) Mrot*x,[X';Y'],false(1,length(X)));
    NewX=T(1,:)';NewY=T(2,:)';%New vectors
    NewX=NewX-min(NewX);
    NewY=NewY-min(NewY);
else
    NewX=X;
    NewY=Y;
end

end


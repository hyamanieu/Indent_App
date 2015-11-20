function [ h ] = Plot3Dmeshed( X,Y,Z, step )
%Plot3Dmeshed makes a 3D surface passing by data point of (x,y,z)
%coordinates. X,Y and Z should be vectors of the same length. Step is
%optinal and defines how many dots in the mesh you want between two data
%points (default: 3)
%   made by Hugues-Yanis AMANIEU, CR/ARM1, Robert Bosch GmbH, Stuttgart.
%   version: 1.0
if nargin > 4
    error('myfuns:somefun2:TooManyInputs', ...
        'requires at most 1 optional input');
end

switch nargin
    case 3
        step = 3;
end


X=round(X*100)/100;%reduce the precision to 10nm
Y=round(Y*100)/100;
Xsort = unique(floor(X*10)/10);
Xstep = Xsort(2)-Xsort(1);
Ysort = unique(floor(Y*10)/10);
Ystep = Ysort(2)-Ysort(1);
NewX=min(X):Xstep/step:max(X);
NewY=min(Y):Ystep/step:max(Y);

[xq,yq] = meshgrid(round(NewX*100)/100,round(NewY*100)/100);
zq = griddata(X(~isnan(Z)),Y(~isnan(Z)),Z(~isnan(Z)),xq,yq);
s=surf(xq,yq,zq,'HitTest','off'); hold
h = plot3(X,Y,Z,'v', 'MarkerSize',10,'LineWidth',1.5,'MarkerEdgeColor',[.5 .5 .5]);
set(gca,'XLim',[min(X) max(X)],'YLim',[min(Y) max(Y)]);
hold off
end


function [ e,h ] = MapIndent( Sample,step )
%[ e,h ] = MapIndent(Sample,(step)) makes a 3D plot of your hardness (plot handle: h) and
%Emodulus(plot handle: e). step defines the number of mesh points between two
%data points (default=3).
%    Sample must be a N*4 matrix where the first column is the x-axis, the
%    second one the y-axis, the third the E-modulii and the fourth the
%    hardness. Pick a self-explanatory name for your sample matrix.
%    made by Hugues-Yanis AMANIEU, CR/ARM1, Robert Bosch GmbH, Stuttgart.
%    version: 1.0

if nargin > 2
    error('myfuns:somefun2:TooManyInputs', ...
        'requires at most 1 optional input');
end

switch nargin
    case 1
        step = 3;
end

X=Sample(:,1);
Y=Sample(:,2);
E=Sample(:,3);
H=Sample(:,4);
X=X-min(X);
Y=Y-min(Y);

%Check if the coordinate system is horizontal and makes it horizontal
[X,Y]=RotMat(X,Y);

figure;
e=subplot(1,2,1);
set(gcf, 'Name',[inputname(1),' E-modulus & Hardness']);
Plot3Dmeshed(X,Y,E, step);
title('Mapping of E-modulii','fontsize',24);
xlabel('X (µm)','fontsize',24);
ylabel('Y (µm)','fontsize',24);
zlabel('E-modul (GPa)','fontsize',24);
colorbar('fontsize',16)
%figure;
%set(gcf, 'Name',[inputname(1),' Hardness']);
h=subplot(1,2,2);
Plot3Dmeshed(X,Y,H, step);
title('Mapping of Hardness','fontsize',24);
xlabel('X (µm)','fontsize',24);
ylabel('Y (µm)','fontsize',24);
zlabel('Hardness (GPa)','fontsize',24);
colorbar('fontsize',16)
set([h e],'fontsize',24);
set(e,'Position',[0.05 0.05 0.4 0.9]);set(h,'Position',[0.55 0.05 0.4 0.9]);


%camera on top
set([e h],'View',[0.0 90.0]);


%orthonormal coordinate system
erat=get(e, 'DataAspectRatio');
erat=erat(3)/erat(1);
set(e,'DataAspectRatio',[1 1 erat]);
hrat=get(h, 'DataAspectRatio');
hrat=hrat(3)/hrat(1);
set(h,'DataAspectRatio',[1 1 hrat]);



end


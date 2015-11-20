function [ errSurf, alpha ] = SquareFitT( X, Y,Depthmin, Depthmax )
%[ errSurf, alpha ] = SquareFitT( X, Y,Depthmin, Depthmax ) Fits load vs displacement curve
%   Fits load (Y) vs displacement curve (X) with a quadratic polynomial
%   over the range Depthmin<X<Depthmax. errSurf returns the normalized surface between
%   the fitted curve and the measured data as calculated using Simpson's 
%   numerical integration (see simp function). alpha is a vector with the coefficients
%   of the polynomial function.
%
%   Copyright 2015 Hugues-Yanis Amanieu
%    Licensed under the Apache License, Version 2.0 (the "License");
%    you may not use this file except in compliance with the License.
%    You may obtain a copy of the License at
%
%      http://www.apache.org/licenses/LICENSE-2.0
%
%    Unless required by applicable law or agreed to in writing, software
%    distributed under the License is distributed on an "AS IS" BASIS,
%    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%    See the License for the specific language governing permissions and
%    limitations under the License.

if (Depthmax == 0)
    Depthmax = max(X)+1;
end
Y=Y/max(Y); %Normalization of the load (=doesn't change final values)
Xrange = (X<=Depthmax) & (X>=Depthmin); %depth range
Vlength=length(Xrange); %length of the vectors
id=find(Xrange,1,'last'); 
alpha =polyfit(X(Xrange),Y(Xrange),2); %fits with quadratic function
SimpleErr=Y(Xrange)-polyval(alpha,X(Xrange)); %simple difference between data and fit
Area1=NaN(1,Vlength);
% calculation of the surface using Simpson's numerical integration.
Area1(id)=sqrt(simps(X(Xrange),SimpleErr.^2))./((max(X(Xrange))-min(X(Xrange)))*((length(Y(Xrange))-2)^2));
while Vlength==length(Xrange)%Loop to find best fitting range.
    Xrange(find(Xrange,1,'last')+1)=1;%next range
    if Vlength~=length(Xrange)
        Xrange(end)=[];
        break
    end
    alpha =polyfit(X(Xrange),Y(Xrange),2);
    SimpleErr=Y(Xrange)-polyval(alpha,X(Xrange));
    i=i+1;
    Area1(i)=sqrt(simps(X(Xrange),SimpleErr.^2))./((max(X(Xrange))-min(X(Xrange)))*((length(Y(Xrange))-2)^3));
end
[~,j]=min(Area1);
Xrange= (X<=Depthmax) & (X>=Depthmin);
Xrange(find(Xrange,1,'last')+1:j)=1;
alpha=polyfit(X(Xrange),Y(Xrange),2);

%Normalized residual (Daniele's approach)
%errSurf=sum(((Y(X>=Depthmin)-polyval(alpha,X(X>=Depthmin)))./(Y(X>=Depthmin))).^2)./(length(Y(X>=Depthmin))-3);
%Areas
errSurf=trapz(X(X>=Depthmin)./max(X(X>=Depthmin)),abs(Y(X>=Depthmin)-polyval(alpha,X(X>=Depthmin))));
%old residual calculation
%errSurf=sqrt(sum((Y(X>=Depthmin)-polyval(alpha,X(X>=Depthmin))).^2))./(length(Y(X>=Depthmin))-3);
%disp(X(find(Xrange,1,'last')));
alpha=alpha*MaxY;%Adapt alpha to real Y's values before exporting
end


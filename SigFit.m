function [fitresult, gof] = SigFit(xData, nGauss)
%SigFit fits sorted cumulated data with nGauss number of gaussian sigmoids for deconvolution. 
%   [fitresult, gof] = SigFit(xData, nGauss) uses curve fitting toolbox. if
%   xData are sorted values, SigFit will deconvulate the entered data with
%   nGauss gaussian sigmoids. Outputs are the same as for the "fit"
%   function of the curve fitting toolbox.
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
%Check input data
if ~issorted(xData)
   errordlg('Please use a sorted vector');
   return
end
if ~any(nGauss==[2, 3, 4]) || ~isnumeric(nGauss)
   errordlg('nGauss must be equal to 2, 3 or 4.');
   return
end


N=length(xData);
i=1:N;
yData=i/N-1/(2*N);
[xData, yData] = prepareCurveData( xData, yData );


%Make the data regular for the fit.
[xb,yb] = stairs(xData,yData);
StepMin=1e-1;
k=1;
while k<=length(xb)-1
    if xb(k)==xb(k+1)
%         if xb(k)-xb(k-1)>StepMin
%             xb(k)=xb(k)-StepMin;
%             k=k+1;
%         else
            xb(k)=[];
            yb(k)=[];
%         end
    else
        k=k+1;
    end
end
xDataInt=zeros(size(xb));
xDataInt(1)=xb(1);
j=2;
for k=2:length(xb)
    if xb(k)-xb(k-1)<StepMin
        xDataInt(j)=xb(k);
        j=j+1;
    else
        nStep=floor((xb(k)-xb(k-1))./StepMin);
        xDataInt(j:j+nStep-1)=xb(k-1)+StepMin:(xb(k)-xb(k-1))/nStep:xb(k);
        j=j+nStep;
    end
end
yDataInt=interp1(xb,yb,xDataInt);


switch nGauss%Number of sigmoids to use.
    case 2
        %determined starting value (maxima in PDF)
        [out,xOut]=hist(xData,20);
        [maxtab, ~]=peakdet(out, 1, xOut);
        [~,IX]=sort(maxtab(:,2),'descend');xDataStart=maxtab(IX,1);
        if length(xDataStart)==0
            xDataStart=ones(2,1);
        elseif length(xDataStart)==1
            xDataStart(2)=mean([xDataStart(1) ceil(max(xData))]);
        end      
        xDataStart=sort(xDataStart(1:2));
        MaxOutput=ceil(max(xData));
        %Sum of 2 sigmoids. Only 1 constant K is defined because K1+K2 = 1
        ftKcons = fittype( '1/2*K1*(1+erf(real((x-m1)/(sqrt(2)*s1))))+1/2*(1-K1)*(1+erf(real((x-m2)/(sqrt(2)*s2))))', 'independent', 'x', 'dependent', 'y' );
        opts = fitoptions( ftKcons );
        opts.Display = 'Off';
        opts.Lower = [0 0 0 0 0];
        opts.StartPoint = [0.5 xDataStart(1) xDataStart(2) 1 1];
        opts.Upper = [1 MaxOutput MaxOutput Inf Inf];        
        [fitresult, gof] = fit( xDataInt, yDataInt, ftKcons, opts );
    case 3
        %determined starting value (maxima in PDF)
        [out,xOut]=hist(xData,20);
        [maxtab, ~]=peakdet(out, 0.5, xOut);
        [~,IX]=sort(maxtab(:,2),'descend');xDataStart=maxtab(IX,1);
        if length(xDataStart)==0
            xDataStart(1)=1;
            xDataStart(2)=mean([xDataStart(1) ceil(max(xData))]);
            xDataStart(3)=mean([xDataStart(2) ceil(max(xData))]);
        elseif length(xDataStart)==1
            xDataStart(2)=mean([xDataStart(1) ceil(max(xData))]);
            xDataStart(3)=mean([xDataStart(2) ceil(max(xData))]);
        elseif length(xDataStart)==2
            xDataStart(3)=mean([xDataStart(2) ceil(max(xData))]);
        end
        xDataStart=sort(xDataStart(1:3));
        MaxOutput=ceil(max(xData));
        %Sum of 3 sigmoids. Only 2 constants K are defined because K1+K2+K3 = 1
        ftKcons = fittype( '1/2*K1*(1+erf(real((x-m1)/(sqrt(2)*s1))))+1/2*K2*(1+erf(real((x-m2)/(sqrt(2)*s2))))+1/2*(1-K1-K2)*(1+erf(real((x-m3)/(sqrt(2)*s3))))', 'independent', 'x', 'dependent', 'y' );
        opts = fitoptions( ftKcons );
        opts.Display = 'Off';
        opts.Lower = [0 0 0 0 0 0 0 0];
        opts.StartPoint = [0.33 0.33 xDataStart(1) xDataStart(2) xDataStart(3) 1 1 1];
        opts.Upper = [1 1 MaxOutput MaxOutput MaxOutput Inf Inf Inf];
        
        [fitresult, gof] = fit( xDataInt, yDataInt, ftKcons, opts );

    case 4
        %determined starting value (maxima in PDF)
        [out,xOut]=hist(xData,20);
        [maxtab, ~]=peakdet(out, 0.5, xOut);
        MaxOutput=ceil(max(xData));
        [~,IX]=sort(maxtab(:,2),'descend');xDataStart=maxtab(IX,1);
        if length(xDataStart)==0
            xDataStart(1)=1;
            xDataStart(2)=mean([xDataStart(1) MaxOutput]);
            xDataStart(3)=mean([xDataStart(2) MaxOutput]);
            xDataStart(4)=mean([xDataStart(3) MaxOutput]);
        elseif length(xDataStart)==1
            xDataStart(2)=mean([xDataStart(1) MaxOutput]);
            xDataStart(3)=mean([xDataStart(2) MaxOutput]);
            xDataStart(4)=mean([xDataStart(3) MaxOutput]);
        elseif length(xDataStart)==2
            xDataStart(3)=mean([xDataStart(2) MaxOutput]);
            xDataStart(4)=mean([xDataStart(3) MaxOutput]);
        elseif length(xDataStart)==3
            xDataStart(4)=mean([xDataStart(3) MaxOutput]);
        end
        xDataStart=sort(xDataStart(1:4));
        %Sum of 4 sigmoids. Only 3 constants K are defined because K1+K2+K3+K4 = 1
        ftKcons = fittype( '1/2*K1*(1+erf(real((x-m1)/(sqrt(2)*s1))))+1/2*K2*(1+erf(real((x-m2)/(sqrt(2)*s2))))+1/2*K3*(1+erf(real((x-m3)/(sqrt(2)*s3))))+1/2*(1-K1-K2-K3)*(1+erf(real((x-m4)/(sqrt(2)*s4))))', 'independent', 'x', 'dependent', 'y' );
        opts = fitoptions( ftKcons );
        opts.Display = 'Off';
        opts.Lower = [0 0 0 0 0 0 0 0 0 0 0];
        opts.StartPoint = [0.25 0.25 0.25 xDataStart(1) xDataStart(2) xDataStart(3) xDataStart(4) 1 1 1 1];
        opts.Upper = [1 1 1 MaxOutput MaxOutput MaxOutput MaxOutput Inf Inf Inf Inf];
        
        [fitresult, gof] = fit( xDataInt, yDataInt, ftKcons, opts );

        
end


end


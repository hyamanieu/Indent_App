function [itemstring, hf]=ReadSigFit(fitresult, xData)
%PlotSigFit plots output from SigFit and give a txt version of the results.
%   [itemstring, hf]=ReadSigFit(fitresult, xData) uses curve fitting toolbox. It
%   is used to plot the data and extract text version of the result. hf
%   returns the handle of the figure.
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

if ~issorted(xData)
   errordlg('Please use a sorted vector');
   return
end
if ~isa(fitresult,'cfit')
    errordlg('fitresult must be a cfit method from the curve fitting toolbox');
    return;
end

if nargout>2
        errordlg('You cannot use more than 2 output arguments');
        return;
end


N=length(xData);
i=1:N;
yData=i/N-1/(2*N);
[xData, yData] = prepareCurveData( xData, yData );
MaxOutput=ceil(max(xData));

%Check type of sigmoid and calculate last K coeff.
FitForm=formula(fittype(fitresult));
if strfind(FitForm,'m4')
    nGauss=4;
    try
        K1=fitresult.K1;
        K2=fitresult.K2;
        K3=fitresult.K3;
        K4=1-fitresult.K1-fitresult.K2-fitresult.K3;
    catch
        errordlg('Your fitresult doesn''t seem to be a sum of sigmoid gaussians (no m2, m3 or m4 coeff)')
        return;
    end
elseif strfind(FitForm,'m3')
    nGauss=3;
    try
        K1=fitresult.K1;
        K2=fitresult.K2;
        K3=1-fitresult.K1-fitresult.K2;
    catch
        errordlg('Your fitresult doesn''t seem to be a sum of sigmoid gaussians (no m2, m3 or m4 coeff)')
        return;
    end
elseif strfind(FitForm,'m2')
    nGauss=2;
    try
        K1=fitresult.K1;
        K2=1-fitresult.K1;
    catch
        errordlg('Your fitresult doesn''t seem to be a sum of sigmoid gaussians (no m2, m3 or m4 coeff)')
        return;
    end
else
    errordlg('Your fitresult doesn''t seem to be a sum of sigmoid gaussians (no m2, m3 or m4 coeff)')
    return;
end


%Create string
Coeffn=coeffnames(fitresult);
Coeff=coeffvalues(fitresult);
CoeffNumb=length(Coeffn);
itemstring=cell(CoeffNumb,1);
for i=1:CoeffNumb
    itemstring{i}=sprintf([Coeffn{i},'=%4.2f'],Coeff(i));
end
if nargout == 1%If only 1 argument, only the string is returned.
    return
end

%If 0 or 2 argument parameters, plot the function.
hf=figure( 'Name', 'Plot of SigFit' );
h = plot( fitresult, xData, yData );
hold all;
fSigmoid=@(K,m,s,x) (1/2*K*(1+erf(real((x-m)/(sqrt(2)*s)))));
hS=zeros(nGauss,1);
leg={'CDF experimental data', 'Sigmoid fit'};
for i=1:nGauss
    hS(i)=eval(['ezplot(@(x) fSigmoid(K',num2str(i),',fitresult.m',num2str(i),',fitresult.s',num2str(i),',x),[0 MaxOutput]);']);
    leg{2+i}=['Sig',num2str(i)];
end
set(hS, 'Color', 'g');	
legend( leg, 'Location', 'NorthEast' );
% Label axes
xlabel( 'Mechanical property (GPa)','FontSize',24);
ylabel( 'CDF','FontSize',24);
set(get(h(1),'Parent'),'YLim',[0 1],'XLim',[0 MaxOutput]);

set(h,'MarkerSize',15);
set(h,'LineWidth',3);
title(gca,['Fit of ',num2str(nGauss),' gaussian Sigmoids']);
set(hS,'LineWidth',3);

uistack(h,'top');
set(gca,'FontSize',24);
text(5,0.5,itemstring,'FontSize',20);


end
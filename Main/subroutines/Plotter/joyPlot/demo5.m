% demo5
clc;close all; clear all;
X1=normrnd(2,2,1,50);
X2=[normrnd(4,4,1,50),normrnd(5,2,1,50)];
X3=[normrnd(6,2,1,50),normrnd(8,4,1,50)];
X4=[normrnd(12,1,1,50),normrnd(12,4,1,50)];
X5=[normrnd(10,2,1,50),normrnd(10,4,1,50)];
X6=[normrnd(7,2,1,50),normrnd(7,4,1,50)];
X7=[normrnd(4,2,1,50),normrnd(4,4,1,50)];

Data={X1,X2,X3,X4,X5,X6,X7};

% JP=joyPlot(Data,'ColorMode','Qt','MedLine','on','Quantiles',[.1,.9]);
JP=joyPlot(Data,'ColorMode','Qt','MedLine','on','Quantiles',[.1,.25,.75,.9],'ColorList',turbo(5),'QtLine','on');
JP=JP.draw();

% legendHdl=JP.getLegendHdl();
% legend(legendHdl)

legendHdl=JP.getLegendHdl();
legend(legendHdl,{'0~0.1','0.1~0.25','0.25~0.75','0.75~0.9','0.9~1'})

% 修改配色
JP.setPatchColor(bone(6))


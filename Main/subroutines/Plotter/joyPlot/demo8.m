% demo8
clc;close all; clear all;
X1=normrnd(2,2,1,50);
X2=[normrnd(4,4,1,50),normrnd(5,2,1,50)];
X3=[normrnd(6,2,1,50),normrnd(8,4,1,50)];
X4=[normrnd(12,1,1,50),normrnd(12,4,1,50)];
X5=[normrnd(10,2,1,50),normrnd(10,4,1,50)];
X6=[normrnd(7,2,1,50),normrnd(7,4,1,50)];
X7=[normrnd(4,2,1,50),normrnd(4,4,1,50)];

Data={X1,X2,X3,X4,X5,X6,X7};

JP=joyPlot(Data,'ColorMode','Order','Scatter','on','QtLine','on','MedLine','on','Sep',1/5);
JP=JP.draw();

legendHdl=JP.getLegendHdl();
legend(legendHdl)

for i=1:length(Data)
    JP.setRidgePatch(i,'FaceColor',[1,1,1]./length(Data).*i,'FaceAlpha',.5)
    JP.setRidgeLine(i,'Color',[0,0,.8],'LineWidth',1)
    JP.setScatter(i,'Color',[0,0,0,.4])
    JP.setMedLine(i,'Color',[0,0,.8])
    JP.setQtLine(i,'Color',[0,0,.8])
end
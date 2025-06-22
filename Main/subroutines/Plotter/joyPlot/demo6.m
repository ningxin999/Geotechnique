% demo6
clc;close all; clear all;
X1_1=normrnd(-15,2,1,20);
X1_2=[normrnd(4,4,1,10),normrnd(5,2,1,10)];
X1_3=[normrnd(6,2,1,10),normrnd(8,4,1,10)];
X1_4=[normrnd(12,1,1,10),normrnd(12,4,1,10)];
X1_5=[normrnd(-7,2,1,10),normrnd(2,4,1,10)];
X1_6=[normrnd(-7,2,1,10),normrnd(-7,4,1,10)];
Data1={X1_1,X1_2,X1_3,X1_4,X1_5,X1_6};
X2_1=normrnd(-8,2,1,20);
X2_2=[normrnd(2,4,1,10),normrnd(2,2,1,10)];
X2_3=[normrnd(18,2,1,10),normrnd(18,4,1,10)];
X2_4=[normrnd(18,1,1,10),normrnd(18,4,1,10)];
X2_5=[normrnd(5,2,1,10),normrnd(5,4,1,10)];
X2_6=[normrnd(-20,2,1,10),normrnd(-20,4,1,10)];
Data2={X2_1,X2_2,X2_3,X2_4,X2_5,X2_6};

JP1=joyPlot(Data1,'ColorMode','Order','ColorList',[12,165,154]./255,'MedLine','on','Scatter','on');
JP1=JP1.draw();

JP2=joyPlot(Data2,'ColorMode','Order','ColorList',[151,220,71]./255,'MedLine','on','Scatter','on');
JP2=JP2.draw();


% 设置中位线颜色
for i=1:length(Data1)
    JP1.setMedLine(i,'Color',[12,165,154]./255)
end
for i=1:length(Data2)
    JP2.setMedLine(i,'Color',[151,220,71]./255)
end

% 绘制图例
legendHdl1=JP1.getLegendHdl();
legendHdl2=JP2.getLegendHdl();
legend([legendHdl1(1),legendHdl2(1)],{'AAAAA','BBBBB'})

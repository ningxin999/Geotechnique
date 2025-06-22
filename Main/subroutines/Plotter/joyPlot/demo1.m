% demo1
figure
X1=normrnd(2,2,1,50);
X2=[normrnd(4,4,1,50),normrnd(5,2,1,50)];
X3=[normrnd(6,2,1,50),normrnd(8,4,1,50)];
X4=[normrnd(12,1,1,50),normrnd(12,4,1,50)];
X5=[normrnd(10,2,1,50),normrnd(10,4,1,50)];
X6=[normrnd(7,2,1,50),normrnd(7,4,1,50)];
X7=[normrnd(4,2,1,50),normrnd(4,4,1,50)];

Data={X1,X2,X3,X4,X5,X6,X7};

% JP=joyPlot(Data,'ColorMode','Order','Scatter','on');
JP=joyPlot(Data,'ColorMode','Order');
JP=JP.draw();

legendHdl=JP.getLegendHdl();
legend(legendHdl)


% % 设置山脊颜色
% newColorList=[0.1059    0.6196    0.4667
%     0.8510    0.3725    0.0078
%     0.4588    0.4392    0.7020
%     0.6529    0.4059    0.3294
%     0.9020    0.6706    0.0078
%     0.6510    0.4627    0.1137
%     0.4000    0.4000    0.4000];
% JP.setPatchColor(newColorList)
% % 设置线条颜色
% for i=1:length(Data)
%     JP.setRidgeLine(i,'Color',[0,0,.8])
% end

% 添加X轴Y轴标签及标题
% ax=gca;
% ax.FontSize=12;
% ax.XLabel.String='XXXXX Label';
% ax.YLabel.String='YYYYY Label';
% ax.XLabel.FontSize=15;
% ax.YLabel.FontSize=15;
% title('joy plot by slandarer','FontSize',16)
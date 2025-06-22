classdef joyPlot
% @author : slandarer
% 公众号  : slandarer随笔 
    properties
        ax,arginList={'ColorMode','ColorList','Sep','Scatter','MedLine','Quantiles','QtLine'}
        ColorMode='Order'   % 上色模式'Order'/'X'/'GlobalX'/'Kdensity'/'Qt'
        ColorList
        defaultColorList1=[0.3725    0.2745    0.5647;    0.1137    0.4118    0.5882;    0.2196    0.6510    0.6471;    0.0588    0.5216    0.3294
                           0.4510    0.6863    0.2824;    0.9294    0.6784    0.0314;    0.8824    0.4863    0.0196;    0.8000    0.3137    0.2431
                           0.5804    0.2039    0.4314;    0.4353    0.2510    0.4392];
        defaultColorList2=[0.0015    0.0005    0.0139;    0.0143    0.0122    0.0705;    0.0415    0.0323    0.1373;    0.0773    0.0535    0.2088;    
                           0.1179    0.0664    0.2854;    0.1661    0.0678    0.3630;    0.2209    0.0609    0.4276;    0.2758    0.0616    0.4677;    
                           0.3279    0.0755    0.4889;    0.3784    0.0954    0.5001;    0.4284    0.1160    0.5058;    0.4788    0.1357    0.5080;    
                           0.5297    0.1541    0.5070;    0.5814    0.1715    0.5028;    0.6338    0.1882    0.4951;    0.6867    0.2051    0.4836;    
                           0.7395    0.2231    0.4679;    0.7914    0.2438    0.4480;    0.8410    0.2692    0.4245;    0.8861    0.3019    0.3992;    
                           0.9240    0.3441    0.3761;    0.9524    0.3958    0.3617;    0.9715    0.4540    0.3610;    0.9837    0.5147    0.3747;    
                           0.9912    0.5758    0.4003;    0.9954    0.6364    0.4350;    0.9972    0.6964    0.4765;    0.9971    0.7559    0.5234;    
                           0.9956    0.8150    0.5747;    0.9930    0.8739    0.6300;    0.9899    0.9327    0.6886;    0.9871    0.9914    0.7495];
        defaultColorList3=[255,153,154;220,220,220;153,153,253]./255;
        Sep=1/8;          % 两个山脊间距离
        Scatter='off';    % 是否绘制竖线状散点
        MedLine='off';
        QtLine='off';
        Quantiles=[.25,.75];QtX,QtY
        ridgeNum,Data,minX,maxX,maxY,XiSet,FSet
        ridgePatchHdl,ridgeLineHdl
        medLineHdl,scatterHdl;QtLineHdl;QtLegendHdl
    end

    methods
        function obj=joyPlot(Data,varargin)
            obj.Data=Data;
            obj.ridgeNum=length(obj.Data);

           for i=1:2:(length(varargin)-1)
                tid=ismember(obj.arginList,varargin{i});
                if any(tid)
                    obj.(obj.arginList{tid})=varargin{i+1};
                end
            end
            if isempty(intersect(obj.ColorMode,{'Order','X','GlobalX','Kdensity','Qt'}))
                error('The ColorMode should be one of the following: Order \ X \ GlobalX \ Kdensity \ Qt')
            end
            switch obj.ColorMode
                case 'Order',obj.ColorList=obj.defaultColorList1;
                case 'X',obj.ColorList=obj.defaultColorList2;
                case 'GlobalX',obj.ColorList=obj.defaultColorList2;
                case 'Kdensity',obj.ColorList=obj.defaultColorList2;
                case 'Qt',obj.ColorList=obj.defaultColorList3;
            end
            for i=1:2:(length(varargin)-1)
                tid=ismember(obj.arginList,varargin{i});
                if any(tid)
                    obj.(obj.arginList{tid})=varargin{i+1};
                end
            end
            obj.minX=min(obj.Data{1});
            obj.maxX=max(obj.Data{1});
            for i=1:obj.ridgeNum
                obj.minX=min(obj.minX,min(obj.Data{i}));
                obj.maxX=max(obj.maxX,max(obj.Data{i}));
            end
        end
        function obj=draw(obj)
            obj.ax=gca;hold on;
            obj.ax.LineWidth=1;
            obj.ax.YTick=(1:obj.ridgeNum).*obj.Sep;
            obj.ax.FontName='Cambria';
            obj.ax.FontSize=13;
            obj.ax.YGrid='on';
            % obj.ax.Box='on';
            obj.ax.TickDir='out';
            tYLabel{obj.ridgeNum}='';
            for i=1:obj.ridgeNum
                tYLabel{i}=['Stage-',num2str(i-1)];
            end
            obj.ax.YTickLabel=tYLabel;

            % 调整初始界面大小
            fig=obj.ax.Parent;
            fig.Color=[1,1,1];
            if max(fig.Position(3:4))<690
                fig.Position(3:4)=1.2.*fig.Position(3:4);
                fig.Position(1:2)=fig.Position(1:2)./2;
            end

            % 绘制patch图像
            obj.minX=min(obj.Data{1});
            obj.maxX=max(obj.Data{1});
            obj.maxY=0;
            for i=1:obj.ridgeNum
                tX=obj.Data{i};tX=tX(:)';
                [F,Xi]=ksdensity(tX);
                %F = F / max(F) *0.2;% normalized  F
                obj.minX=min(obj.minX,min(Xi));
                obj.maxX=max(obj.maxX,max(Xi));
                obj.maxY=max(obj.maxY,max(F));
            end
            for i=obj.ridgeNum:-1:1
                tX=obj.Data{i};tX=tX(:)';
                [F,Xi]=ksdensity(tX);
                OXi=Xi;
                Xi=linspace(min(Xi),max(Xi),1000);
                F=interp1(OXi,F,Xi);
                %F = F / max(F)*0.2;% normalized  F
                obj.XiSet{i}=Xi;
                obj.FSet{i}=F;
                % 绘制竖线散点
                tXX=[tX;tX;tX.*nan];
                tYY=[tX.*0+obj.Sep.*i-obj.Sep./10;tX.*0+obj.Sep.*i-obj.Sep./2.5;tX.*nan];
                if isequal(obj.ColorMode,'Order')
                    obj.scatterHdl(i)=plot(tXX(:),tYY(:),'Color',[obj.ColorList(mod(i-1,size(obj.ColorList,1))+1,:),.5],'LineWidth',.8,'Visible','off');
                else
                    obj.scatterHdl(i)=plot(tXX(:),tYY(:),'Color',[0,0,0,.5],'LineWidth',.8,'Visible','off');
                end
                if isequal(obj.Scatter,'on'),set(obj.scatterHdl(i),'Visible','on');end
                % 计算分位线
                for j=1:length(obj.Quantiles)
                    obj.QtX(i,j+1)=quantile(tX,obj.Quantiles(j));
                    obj.QtY(i,j)=interp1(Xi,F,quantile(tX,obj.Quantiles(j)));
                end
                obj.QtX(i,1)=min(Xi)-inf;
                obj.QtX(i,length(obj.Quantiles)+2)=max(Xi)+inf;
                switch obj.ColorMode
                    case 'Order'
                        obj.ridgePatchHdl(i)=fill([Xi(1),Xi,Xi(end)],[0,F,0]+obj.Sep.*(i).*ones(1,length(F)+2),...
                            obj.ColorList(mod(i-1,size(obj.ColorList,1))+1,:),'EdgeColor','none','FaceAlpha',.5);
                        obj.ridgeLineHdl(i)=plot([Xi(1),Xi,Xi(end)],[0,F,0]+obj.Sep.*(i).*ones(1,length(F)+2),...
                            'Color',obj.ColorList(mod(i-1,size(obj.ColorList,1))+1,:),'LineWidth',.8);
                        colormap(obj.ColorList);
                        try caxis([1,obj.ridgeNum]),catch,end
                        try clim([1,obj.ridgeNum]),catch,end
                    case 'X'
                        tTi=[Xi(1),Xi,Xi(end),Xi(end:-1:1)]-min(Xi);tTi=tTi./max(tTi);
                        tT=linspace(0,1,size(obj.ColorList,1));
                        tC=cat(3,interp1(tT,obj.ColorList(:,1),tTi),interp1(tT,obj.ColorList(:,2),tTi),interp1(tT,obj.ColorList(:,3),tTi));
                        obj.ridgePatchHdl(i)=fill([Xi(1),Xi,Xi(end),Xi(end:-1:1)],[0,F,0,F.*0]+obj.Sep.*(i).*ones(1,length(F)*2+2),...
                            tC,'EdgeColor','none','FaceAlpha',.9,'FaceColor','interp');
                        obj.ridgeLineHdl(i)=plot([Xi(1),Xi,Xi(end)],[0,F,0]+obj.Sep.*(i).*ones(1,length(F)+2),...
                            'Color',[0,0,0,.9],'LineWidth',.8);
                        colormap(obj.ColorList);
                        try caxis([-1,1]),catch,end
                        try clim([-1,1]),catch,end
                    case 'GlobalX'
                        tTi=[Xi(1),Xi,Xi(end),Xi(end:-1:1)]-obj.minX;
                        tTi=tTi./(obj.maxX-obj.minX);
                        tT=linspace(0,1,size(obj.ColorList,1));
                        tC=cat(3,interp1(tT,obj.ColorList(:,1),tTi),interp1(tT,obj.ColorList(:,2),tTi),interp1(tT,obj.ColorList(:,3),tTi));
                        obj.ridgePatchHdl(i)=fill([Xi(1),Xi,Xi(end),Xi(end:-1:1)],[0,F,0,F.*0]+obj.Sep.*(i).*ones(1,length(F)*2+2),...
                            tC,'EdgeColor','none','FaceAlpha',.9,'FaceColor','interp');
                        obj.ridgeLineHdl(i)=plot([Xi(1),Xi,Xi(end)],[0,F,0]+obj.Sep.*(i).*ones(1,length(F)+2),...
                            'Color',[0,0,0,.9],'LineWidth',.8);
                        colormap(obj.ColorList);
                        try caxis([obj.minX,obj.maxX]),catch,end
                        try clim([obj.minX,obj.maxX]),catch,end
                    case 'Kdensity'
                        tTi=[0,F,0,F(end:-1:1)];
                        tTi=tTi./obj.maxY;
                        tT=linspace(0,1,size(obj.ColorList,1));
                        tC=cat(3,interp1(tT,obj.ColorList(:,1),tTi),interp1(tT,obj.ColorList(:,2),tTi),interp1(tT,obj.ColorList(:,3),tTi));
                        obj.ridgePatchHdl(i)=fill([Xi(1),Xi,Xi(end),Xi(end:-1:1)],[0,F,0,F.*0]+obj.Sep.*(i).*ones(1,length(F)*2+2),...
                            tC,'EdgeColor','none','FaceAlpha',.9,'FaceColor','interp');
                        obj.ridgeLineHdl(i)=plot([Xi(1),Xi,Xi(end)],[0,F,0]+obj.Sep.*(i).*ones(1,length(F)+2),...
                            'Color',[0,0,0,.9],'LineWidth',.8);
                        colormap(obj.ColorList);
                        try caxis([0,obj.maxY]),catch,end
                        try clim([0,obj.maxY]),catch,end
                    case 'Qt'
                        tTi=[Xi(1),Xi,Xi(end),Xi(end:-1:1)];
                        tR=tTi.*0;tG=tTi.*0;tB=tTi.*0;
                        for j=1:size(obj.QtX,2)-1
                            tR(tTi>=obj.QtX(i,j)&tTi<obj.QtX(i,j+1))=obj.ColorList(mod(j-1,size(obj.ColorList,1))+1,1);
                            tG(tTi>=obj.QtX(i,j)&tTi<obj.QtX(i,j+1))=obj.ColorList(mod(j-1,size(obj.ColorList,1))+1,2);
                            tB(tTi>=obj.QtX(i,j)&tTi<obj.QtX(i,j+1))=obj.ColorList(mod(j-1,size(obj.ColorList,1))+1,3);
                        end
                        tC=cat(3,tR,tG,tB);
                        obj.ridgePatchHdl(i)=fill([Xi(1),Xi,Xi(end),Xi(end:-1:1)],[0,F,0,F.*0]+obj.Sep.*(i).*ones(1,length(F)*2+2),...
                            tC,'EdgeColor','none','FaceAlpha',.9,'FaceColor','interp');
                        obj.ridgeLineHdl(i)=plot([Xi(1),Xi,Xi(end)],[0,F,0]+obj.Sep.*(i).*ones(1,length(F)+2),...
                            'Color',[0,0,0,.9],'LineWidth',.8);
                        colormap(obj.ColorList);
                        try caxis([-1,1]),catch,end
                        try clim([-1,1]),catch,end
                end
                % 绘制中位线
                tMedX=median(tX);
                tMedY=interp1(Xi,F,tMedX);
                obj.medLineHdl(i)=plot([tMedX,tMedX],[0,tMedY]++obj.Sep.*[i,i],'LineStyle','--','LineWidth',1,'Color',[0,0,0],'Visible','off'); 
                if isequal(obj.MedLine,'on'),set(obj.medLineHdl(i),'Visible','on');end
                % 绘制分位线
                tQtY=[obj.QtY(i,:);obj.QtY(i,:).*0;obj.QtY(i,:).*nan]+obj.Sep.*i;
                tQtX=[obj.QtX(i,2:end-1);obj.QtX(i,2:end-1);obj.QtX(i,2:end-1).*nan];
                obj.QtLineHdl(i)=plot(tQtX(:),tQtY(:),'LineWidth',1,'Color',[0,0,0,.8],'Visible','off');
                if isequal(obj.QtLine,'on'),set(obj.QtLineHdl(i),'Visible','on');end
                % % 绘制25，75分位线
                % tQt25X=quantile(tX,0.25);
                % tQt75X=quantile(tX,0.75);
                % tQt25Y=interp1(Xi,F,tQt25X);
                % tQt75Y=interp1(Xi,F,tQt75X);
                % obj.qt25LineHdl(i)=plot([tQt25X,tQt25X],[0,tQt25Y]+obj.Sep.*[i,i],'LineWidth',1,'Color',[1,1,1,.8],'Visible','off');
                % obj.qt75LineHdl(i)=plot([tQt75X,tQt75X],[0,tQt75Y]+obj.Sep.*[i,i],'LineWidth',1,'Color',[1,1,1,.8],'Visible','off');
                % if isequal(obj.QT25Line,'on'),set(obj.qt25LineHdl(i),'Visible','on');end
                % if isequal(obj.QT75Line,'on'),set(obj.qt75LineHdl(i),'Visible','on');end
            end
            axis tight
            obj.ax.YLim(1)=obj.Sep/2;
            for i=1:size(obj.QtX,2)-1
                obj.QtLegendHdl(i)=fill(mean(obj.ax.XLim).*[1,1,1,1],mean(obj.ax.YLim).*[1,1,1,1],...
                    obj.ColorList(mod(i-1,size(obj.ColorList,1))+1,:),'EdgeColor','none','FaceAlpha',.9);
            end
        end
        % 获取绘制图例对象
        function legendHdl=getLegendHdl(obj)
            if isequal(obj.ColorMode,'Qt')
                legendHdl=obj.QtLegendHdl;
            else
                legendHdl=obj.ridgePatchHdl;
            end
        end
        % 颜色重设置
        function obj=setPatchColor(obj,ColorList)
            obj.ColorList=ColorList;
            colormap(obj.ColorList);
            for i=obj.ridgeNum:-1:1
                Xi=obj.XiSet{i};
                F=obj.FSet{i};
                switch obj.ColorMode
                    case 'Order'
                        set(obj.ridgePatchHdl(i),'FaceColor',obj.ColorList(mod(i-1,size(obj.ColorList,1))+1,:));
                    case 'X'
                        tTi=[Xi(1),Xi,Xi(end),Xi(end:-1:1)]-min(Xi);tTi=tTi./max(tTi);
                        tT=linspace(0,1,size(obj.ColorList,1));
                        tC=cat(3,interp1(tT,obj.ColorList(:,1),tTi),interp1(tT,obj.ColorList(:,2),tTi),interp1(tT,obj.ColorList(:,3),tTi));
                        set(obj.ridgePatchHdl(i),'CData',tC);
                    case 'GlobalX'
                        tTi=[Xi(1),Xi,Xi(end),Xi(end:-1:1)]-obj.minX;
                        tTi=tTi./(obj.maxX-obj.minX);
                        tT=linspace(0,1,size(obj.ColorList,1));
                        tC=cat(3,interp1(tT,obj.ColorList(:,1),tTi),interp1(tT,obj.ColorList(:,2),tTi),interp1(tT,obj.ColorList(:,3),tTi));
                        set(obj.ridgePatchHdl(i),'CData',tC);
                    case 'Kdensity'
                        tTi=[0,F,0,F(end:-1:1)];
                        tTi=tTi./obj.maxY;
                        tT=linspace(0,1,size(obj.ColorList,1));
                        tC=cat(3,interp1(tT,obj.ColorList(:,1),tTi),interp1(tT,obj.ColorList(:,2),tTi),interp1(tT,obj.ColorList(:,3),tTi));
                        set(obj.ridgePatchHdl(i),'CData',tC);
                    case 'Qt'
                        tTi=[Xi(1),Xi,Xi(end),Xi(end:-1:1)];
                        tR=tTi.*0;tG=tTi.*0;tB=tTi.*0;
                        for j=1:size(obj.QtX,2)-1
                            tR(tTi>=obj.QtX(i,j)&tTi<obj.QtX(i,j+1))=obj.ColorList(mod(j-1,size(obj.ColorList,1))+1,1);
                            tG(tTi>=obj.QtX(i,j)&tTi<obj.QtX(i,j+1))=obj.ColorList(mod(j-1,size(obj.ColorList,1))+1,2);
                            tB(tTi>=obj.QtX(i,j)&tTi<obj.QtX(i,j+1))=obj.ColorList(mod(j-1,size(obj.ColorList,1))+1,3);
                        end
                        tC=cat(3,tR,tG,tB);
                        set(obj.ridgePatchHdl(i),'CData',tC);
                end
            end
            for i=1:size(obj.QtX,2)-1
                set(obj.QtLegendHdl(i),'FaceColor',obj.ColorList(mod(i-1,size(obj.ColorList,1))+1,:));
            end
        end
        % 设置Patch及Line对象其他属性
        function setRidgePatch(obj,n,varargin)
            set(obj.ridgePatchHdl(n),varargin{:})
        end
        function setRidgeLine(obj,n,varargin)
            set(obj.ridgeLineHdl(n),varargin{:})
        end
        % 设置各个分位线属性
        function setMedLine(obj,n,varargin)
            set(obj.medLineHdl(n),varargin{:})
        end
        function setQtLine(obj,n,varargin)
            set(obj.QtLineHdl(n),varargin{:})
        end
        % 设置scatter属性
        function setScatter(obj,n,varargin)
            set(obj.scatterHdl(n),varargin{:})
        end
    end
% @author : slandarer
% 公众号  : slandarer随笔 
end
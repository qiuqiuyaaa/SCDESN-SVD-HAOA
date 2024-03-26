    close all
    clear 
    clc

% rng(1);  % For reproducibility
x1 = normrnd(1.13E-03,1.18E-07,100,1);
x2 = normrnd(7.8E-04,3.51E-08,100,1);
x3 = normrnd(7.3E-05,8.13E-09,100,1);
x4 = normrnd(3.91E-07,1.35E-14,100,1);
x5 = normrnd(5.06E-04,3.68E-08,100,1);
x6 = normrnd(3.45E-08,1.19E-15,100,1);

figure
boxplot([x1,x2,x3,x4,x5,x6],'Symbol','o','OutlierSize',3)


 % 坐标区域属性设置
ax=gca;hold on;
ax.LineWidth=1.1;
ax.FontSize=14;
% ax.FontName='SimHei';
ax.XTickLabelRotation=0;
ax.XTickLabel={'DRPedESN','DHESN','PRESN','EESN','ESN','SDESN'};
ax.YLabel.String='log(value)';
ax.Title.String=('Boxplot');
ax.Title.FontSize=14;
% 写入excel
% wexcel(Y,Function_name);

% 修改线条粗细
lineObj=findobj(gca,'Type','Line');
for i=1:length(lineObj)
    lineObj(i).LineWidth=1.5;
    lineObj(i).MarkerFaceColor=[1,1,1].*.3;
    lineObj(i).MarkerEdgeColor=[1,1,1].*.3;
end


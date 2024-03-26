% Demo script
warning off             % 关闭报警信息
close all               % 关闭开启的图窗
clear                   % 清空变量
clc                     % 清空命令行
tic
%% 输入数据 
data = load('PM.mat');  

data = data.PM;

%  数据归一化
% [data, DATA] = mapminmax(data1, 0, 1);

% inputData = cell2mat(data(1:end-1))'; 
% targetData = cell2mat(data(2:end))';


inputData = data(1:end-1)'; 
targetData = data(2:end)';

washout = 100; 


%% 划分训练集和测试集
trlen = 600; tslen = 200; 
trX{1} = inputData(1:trlen);
tsX{1} = inputData(trlen+1:trlen+tslen);
% Remove initial points from target!
trY = targetData(1+washout:trlen);

tsY = targetData(trlen+1+washout:trlen+tslen);
M = size(tsY, 1);
%% Pre-AOA
disp(' ')
disp('normal_ESN:')
esn = ESN(50, 'leakRate', 0.3, 'spectralRadius', 0.5, 'regularization', 1e-8);

esn.train(trX, trY, washout);
toc
tic
output = esn.predict(tsX, washout);

%  数据反归一化
% output = mapminmax('reverse', Output, DATA);

% 计算误差

%  均方根误差MSE
error1 = immse(output, tsY);
%  均方根误差 RMSE
RMSE1 = sqrt(sum((output' - tsY').^2)./M);
%  平均绝对误差MAE
MAE1 = mean(abs(tsY' - output'));
%  平均绝对百分比误差MAPE
MAPE1 = mean(abs((tsY' - output')./tsY'));

fprintf('ESN Test error: %g\n', error1);
toc
%% AOA-ESN
disp(' ')
disp('AOA_ESN:')
tic
% 初始化ESN参数
esn0 = RESN(50, 'leakRate', 0.3, 'spectralRadius', 0.5, 'regularization', 1e-8);

% 初始化AOA参数
N=20; %Number of search solutions
M_Iter=50;    %Maximum number of iterations
dim=esn0.Nr;   %自变量个数
lb=repmat(-10,1,dim);
ub=repmat(10,1,dim);

Best_P=zeros(1,dim);
Best_FF=inf;
Conv_curve=zeros(1,M_Iter);

%超立方抽样初始化种群位置
X=LSSinitialization(N,dim,ub,lb);
Xnew=X;
Ffun=zeros(1,size(X,1));% (fitness values)
Ffun_new=zeros(1,size(Xnew,1));% (fitness values)

MOP_Max=1;
MOP_Min=0.2;
C_Iter=1;
Alpha=5;
Mu=0.499;

% 计算初始适应度值
for i=1:size(X,1)
    Ffun(i)=fitness(X(i,:), esn0, trX, trY, washout);
  %Calculate the fitness values of solutions
    if Ffun(1,i)<Best_FF
        Best_FF=Ffun(1,i);
        Best_P=X(i,:);
    end
end

% 开始优化
while C_Iter<M_Iter+1  %Main loop
    MOP=1-((C_Iter)^(1/Alpha)/(M_Iter)^(1/Alpha));   % Probability Ratio 
    MOA=MOP_Min+C_Iter*((MOP_Max-MOP_Min)/M_Iter); %Accelerated function
   
    %Update the Position of solutions
    for i=1:size(X,1)   
        for j=1:size(X,2)
           r1=rand();
            if (size(lb,2)==1)    % if each of the UB and LB has a just value
                if r1<MOA  %全局探索
                    r2=rand();
                    if r2>0.5
                        Xnew(i,j)=Best_P(1,j)/(MOP+eps)*((ub-lb)*Mu+lb); %应用除法运算
                    else
                        Xnew(i,j)=Best_P(1,j)*MOP*((ub-lb)*Mu+lb);  %应用乘法运算
                    end
                else   %局部开发
                    r3=rand();
                    if r3>0.5
                        Xnew(i,j)=Best_P(1,j)-MOP*((ub-lb)*Mu+lb);  %应用减法运算
                    else
                        Xnew(i,j)=Best_P(1,j)+MOP*((ub-lb)*Mu+lb);  %应用加法运算
                    end
                end               
            end
            
           
            if (size(lb,2)~=1)   % if each of the UB and LB has more than one value 
                r1=rand();
                if r1<MOA
                    r2=rand();
                    if r2>0.5
                        Xnew(i,j)=Best_P(1,j)/(MOP+eps)*((ub(j)-lb(j))*Mu+lb(j));
                    else
                        Xnew(i,j)=Best_P(1,j)*MOP*((ub(j)-lb(j))*Mu+lb(j));
                    end
                else
                    r3=rand();
                    if r3>0.5
                        Xnew(i,j)=Best_P(1,j)-MOP*((ub(j)-lb(j))*Mu+lb(j));
                    else
                        Xnew(i,j)=Best_P(1,j)+MOP*((ub(j)-lb(j))*Mu+lb(j));
                    end
                end               
            end
            
        end
        
        Flag_UB=Xnew(i,:)>ub; % check if they exceed (up) the boundaries
        Flag_LB=Xnew(i,:)<lb; % check if they exceed (down) the boundaries
        Xnew(i,:)=(Xnew(i,:).*(~(Flag_UB+Flag_LB)))+ub.*Flag_UB+lb.*Flag_LB;
 
        Ffun_new(1,i)=fitness(Xnew(i,:),esn0, trX, trY, washout);
  % calculate Fitness function 
        if Ffun_new(1,i)<Ffun(1,i)
            X(i,:)=Xnew(i,:);
            Ffun(1,i)=Ffun_new(1,i);
        end
        if Ffun(1,i)<Best_FF
        Best_FF=Ffun(1,i);
        Best_P=X(i,:);
        end
       
    end
    

    %Update the convergence curve
    Conv_curve(C_Iter)=Best_FF;   
    C_Iter=C_Iter+1;  % incremental iteration
   
end
esn0.Wout =Best_P;
Best_score = Conv_curve(end);


% 绘制AOA优化曲线
% figure
% plot(Conv_curve,'r-','LineWidth',2)
% title('Improved  AOA Convergence curve')
% xlabel('Iteration');
% ylabel('Best fitness function');
% axis tight
%legend('LSS-AOA')

%优化后的ESN训练
esn0.train(trX, trY, washout);
toc
tic
%优化后的ESN测试
output0 = esn0.predict(tsX, washout);

%  数据反归一化
% output0 = mapminmax('reverse', Output0, DATA);

% 计算误差

%  均方根误差MSE
error2 = immse(output0, tsY);
%  均方根误差 RMSE
RMSE2 = sqrt(sum((output0' - tsY').^2)./M);
%  平均绝对误差MAE
MAE2 = mean(abs(tsY' - output0'));
%  平均绝对百分比误差MAPE
MAPE2 = mean(abs((tsY' - output0')./tsY'));

fprintf('AOA-ESN Test error: %g\n', error2);
toc
%% plot
figure
plot(1:length(output), output,'b-*','LineWidth',1.5)
hold on
plot(1:length(output0), output0,'rp-','LineWidth',1.5)
hold on
plot(1:length(tsY), tsY,'go-','LineWidth',1.5);
legend('ESN-output', 'AOA-ESN-output', 'Target');
xlabel('测试样本')
ylabel('值')
title('ESN和AOA-ESN预测值与真实值对比图')

%% 生成子图
% hold on
% axes('Position',[0.4,0.5,0.3,0.3]); % 生成子图                                                                           
% plot(1:length(output), output, 1:length(tsY), tsY);% 绘制局部曲线图                                                                                                                
% xlim([650,700]); % 设置坐标轴范围 

% disp(['-----------------------ESN误差计算--------------------------'])
% disp(['评价结果如下所示：'])
% disp(['均方误差MSE为：       ',num2str(error1)])
% disp(['平均绝对误差MAE为：',num2str(MAE1)])
% disp(['均方根误差RMSE为：  ',num2str(RMSE1)])
% disp(['平均绝对百分比误差MAPE为：  ',num2str(MAPE1)])
% 
% disp(['-----------------------AOA-ESN误差计算--------------------------'])
% disp(['评价结果如下所示：'])
% disp(['均方误差MSE为：       ',num2str(error2)])
% disp(['平均绝对误差MAE为：',num2str(MAE2)])
% disp(['均方根误差RMSE为：  ',num2str(RMSE2)])
% disp(['平均绝对百分比误差MAPE为：  ',num2str(MAPE2)])










